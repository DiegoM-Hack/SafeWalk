const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

/**
 * Función callable: busca si un correo pertenece a un usuario
 * registrado en SafeWalk, sin exponer el resto de su perfil.
 *
 * El cliente Flutter la invoca así:
 *   final callable = FirebaseFunctions.instance.httpsCallable('findUserByEmail');
 *   final result = await callable.call({'email': email});
 *   final uid = result.data['uid']; // null si no existe
 */
exports.findUserByEmail = onCall(async (request) => {
  // Solo usuarios autenticados pueden llamar esta función.
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Debes iniciar sesión para usar esta función."
    );
  }

  const email = (request.data.email || "").trim().toLowerCase();

  if (!email) {
    throw new HttpsError("invalid-argument", "El correo es obligatorio.");
  }

  const snapshot = await db
    .collection("users")
    .where("email", "==", email)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return { exists: false, uid: null };
  }

  return { exists: true, uid: snapshot.docs[0].id };
});

/**
 * Trigger: se ejecuta automáticamente cada vez que se crea un
 * documento en emergency_alerts (es decir, cuando alguien presiona
 * el botón SOS). Busca los contactos de emergencia del usuario que
 * ya estén vinculados a una cuenta de SafeWalk, y les manda una
 * notificación push con la ubicación.
 */
exports.onEmergencyAlertCreated = onDocumentCreated(
  "emergency_alerts/{alertId}",
  async (event) => {
    const alert = event.data.data();
    const alertId = event.params.alertId;

    if (!alert || !alert.uid) {
      logger.warn(`Alerta ${alertId} sin uid, se ignora.`);
      return;
    }

    // 1. Obtener el nombre del usuario que envió la alerta.
    const senderDoc = await db.collection("users").doc(alert.uid).get();
    const senderName = senderDoc.exists
      ? senderDoc.data().name || "Alguien"
      : "Alguien";

    // 2. Buscar sus contactos de emergencia vinculados a una cuenta.
    const contactsSnapshot = await db
      .collection("users")
      .doc(alert.uid)
      .collection("contacts")
      .where("linkedUserId", "!=", null)
      .get();

    if (contactsSnapshot.empty) {
      logger.info(
        `Alerta ${alertId}: ${senderName} no tiene contactos vinculados a SafeWalk.`
      );
      return;
    }

    // 3. Obtener el token FCM de cada contacto vinculado.
    const linkedUserIds = contactsSnapshot.docs
      .map((doc) => doc.data().linkedUserId)
      .filter(Boolean);

    const tokens = [];

    for (const linkedUserId of linkedUserIds) {
      const userDoc = await db.collection("users").doc(linkedUserId).get();
      const token = userDoc.exists ? userDoc.data().fcmToken : null;

      if (token) {
        tokens.push(token);
      }
    }

    if (tokens.length === 0) {
      logger.info(
        `Alerta ${alertId}: ningún contacto vinculado tiene token FCM disponible.`
      );
      return;
    }

    // 4. Enviar la notificación push a todos los tokens encontrados.
    const message = {
      notification: {
        title: "🚨 Alerta SOS",
        body: `${senderName} necesita ayuda. Toca para ver su ubicación.`,
      },
      data: {
        type: "sos_alert",
        alertId: alertId,
        senderUid: alert.uid,
      },
      tokens: tokens,
    };

    const response = await messaging.sendEachForMulticast(message);

    logger.info(
      `Alerta ${alertId}: notificaciones enviadas. Éxitos: ${response.successCount}, fallos: ${response.failureCount}`
    );
  }
);