const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

exports.sendSosNotification = onDocumentCreated(
  "notifications/{docId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const { receiverUid, senderUid, alertId } = snap.data();

    try {
      // 1. Buscar el token FCM del contacto que debe recibir la alerta
      const receiverDoc = await db.collection("users").doc(receiverUid).get();
      const fcmToken = receiverDoc.data()?.fcmToken;

      if (!fcmToken) {
        await snap.ref.update({ status: "error", error: "no_fcm_token" });
        return;
      }

      // 2. Traer los datos de la alerta para armar un mensaje claro
      const alertDoc = await db.collection("emergency_alerts").doc(alertId).get();
      const alertData = alertDoc.data() || {};
      const userName = alertData.userName || "Un contacto";
      const lat = alertData.latitude;
      const lng = alertData.longitude;

      // 3. Armar y enviar el mensaje FCM
      const message = {
        token: fcmToken,
        notification: {
          title: `🚨 SOS de ${userName}`,
          body: "Necesita ayuda urgente. Toca para ver el chat y su ubicación.",
        },
        data: {
          type: "sos_alert",
          alertId: alertId,
          senderUid: senderUid,
          latitude: lat ? String(lat) : "",
          longitude: lng ? String(lng) : "",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: { sound: "default", contentAvailable: true },
          },
        },
      };

      await messaging.send(message);
      await snap.ref.update({ status: "sent", sentAt: new Date() });
    } catch (err) {
      console.error("Error enviando SOS push:", err);
      await snap.ref.update({ status: "error", error: String(err) });
    }
  }
);