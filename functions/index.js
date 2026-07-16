/**
 * OPCIONAL — Fase 2 de la propuesta.
 *
 * Sin este Cloud Function, el flujo ya funciona mientras la app está
 * abierta (el listener de Firestore en LocationShareProvider muestra el
 * diálogo igual). Esta función es la que permite que la notificación
 * llegue como push real aunque la app de B esté cerrada o en segundo
 * plano.
 *
 * Requiere:
 *   npm install firebase-admin firebase-functions
 * y desplegar con:
 *   firebase deploy --only functions
 */
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

exports.onLocationShareRequestCreated = onDocumentCreated(
  "location_shares/{shareId}",
  async (event) => {
    const data = event.data?.data();
    if (!data || data.status !== "pending") return;

    const db = getFirestore();
    const toUserSnap = await db.collection("users").doc(data.toUid).get();
    const fcmToken = toUserSnap.data()?.fcmToken;

    if (!fcmToken) {
      console.log(`Usuario ${data.toUid} no tiene fcmToken registrado.`);
      return;
    }

    await getMessaging().send({
      token: fcmToken,
      notification: {
        title: "SafeWalk",
        body: `📍 ${data.fromName} quiere compartir su ubicación contigo.`,
      },
      data: {
        type: "location_share_request",
        shareId: event.params.shareId,
      },
      android: { priority: "high" },
      apns: { headers: { "apns-priority": "10" } },
    });
  }
);
