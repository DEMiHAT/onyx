/**
 * ONYX — Push Notification Cloud Functions (FCM)
 *
 * Handles sending Firebase Cloud Messaging push notifications
 * to individual devices and topic-based broadcasts.
 *
 * Works alongside the WhatsApp module for multi-channel delivery.
 */

const { getMessaging } = require("firebase-admin/messaging");
const { getFirestore } = require("firebase-admin/firestore");

// Lazy — only resolve after initializeApp() has been called in index.js
function db() { return getFirestore(); }

// ════════════════════════════════════════════════════════════════
// INDIVIDUAL PUSH NOTIFICATION
// ════════════════════════════════════════════════════════════════

/**
 * Send a push notification to a specific user's devices.
 * @param {string} userId - Firestore user ID
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {object} data - Custom data payload for routing
 * @returns {object} Result
 */
async function sendPushToUser(userId, title, body, data = {}) {
  try {
    const userDoc = await db().collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.warn(`[FCM] User ${userId} not found`);
      return { success: false, error: "User not found" };
    }

    const userData = userDoc.data();
    const tokens = userData.fcmTokens || [];

    if (tokens.length === 0) {
      console.warn(`[FCM] No tokens for user ${userId}`);
      return { success: false, error: "No FCM tokens" };
    }

    const message = {
      notification: { title, body },
      data: {
        ...data,
        type: data.type || "general",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "onyx_default",
          icon: "ic_notification",
          color: "#00E5FF",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
            "content-available": 1,
          },
        },
      },
    };

    // Send to all registered tokens
    const response = await getMessaging().sendEachForMulticast({
      tokens,
      ...message,
    });

    // Clean up invalid tokens
    const invalidTokens = [];
    response.responses.forEach((resp, idx) => {
      if (resp.error) {
        const code = resp.error.code;
        if (
          code === "messaging/invalid-registration-token" ||
          code === "messaging/registration-token-not-registered"
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    if (invalidTokens.length > 0) {
      const { FieldValue } = require("firebase-admin/firestore");
      await db().collection("users").doc(userId).update({
        fcmTokens: FieldValue.arrayRemove(...invalidTokens),
      });
      console.log(`[FCM] Cleaned ${invalidTokens.length} invalid tokens for ${userId}`);
    }

    console.log(`[FCM] Sent to ${userId}: ${response.successCount}/${tokens.length}`);
    return {
      success: response.successCount > 0,
      sent: response.successCount,
      failed: response.failureCount,
    };
  } catch (error) {
    console.error(`[FCM] Error sending to ${userId}: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// ════════════════════════════════════════════════════════════════
// TOPIC BROADCAST
// ════════════════════════════════════════════════════════════════

/**
 * Send a push notification to a topic (e.g., 'all_users', 'coaches').
 * @param {string} topic - FCM topic name
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {object} data - Custom data payload
 * @returns {object} Result
 */
async function sendPushToTopic(topic, title, body, data = {}) {
  try {
    const message = {
      topic,
      notification: { title, body },
      data: {
        ...data,
        type: data.type || "general",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "onyx_default",
          icon: "ic_notification",
          color: "#00E5FF",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    const messageId = await getMessaging().send(message);
    console.log(`[FCM] Topic '${topic}' sent: ${messageId}`);
    return { success: true, messageId };
  } catch (error) {
    console.error(`[FCM] Topic '${topic}' error: ${error.message}`);
    return { success: false, error: error.message };
  }
}

// ════════════════════════════════════════════════════════════════
// MULTI-CHANNEL NOTIFICATION (FCM + WhatsApp)
// ════════════════════════════════════════════════════════════════

/**
 * Send notification via all available channels (Firestore, FCM, WhatsApp).
 * @param {object} options
 * @param {string} options.userId - Target user ID
 * @param {string} options.type - Notification type (booking, payment, etc.)
 * @param {string} options.title - Title
 * @param {string} options.body - Body text
 * @param {string} [options.whatsappTemplate] - WhatsApp template key (if WhatsApp should be sent)
 * @param {object} [options.whatsappParams] - WhatsApp template parameters
 * @param {object} [options.data] - Extra data payload
 */
async function sendMultiChannelNotification({
  userId,
  type,
  title,
  body,
  whatsappTemplate,
  whatsappParams,
  data = {},
}) {
  const { FieldValue } = require("firebase-admin/firestore");

  // 1. Store in Firestore (in-app notification feed)
  await db().collection("notifications").add({
    userId,
    type,
    title,
    body,
    data,
    isRead: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  // 2. Send FCM push notification
  await sendPushToUser(userId, title, body, { type, ...data });

  // 3. Send WhatsApp (if template provided and user is opted in)
  if (whatsappTemplate) {
    const userDoc = await db().collection("users").doc(userId).get();
    if (userDoc.exists) {
      const userData = userDoc.data();
      const phone = userData.phone;
      const whatsappOptIn = userData.whatsappOptIn !== false; // default opted in

      if (phone && whatsappOptIn) {
        const { sendTemplateMessage, normalizePhoneNumber } = require("./whatsapp");
        const normalizedPhone = normalizePhoneNumber(phone);
        if (normalizedPhone) {
          await sendTemplateMessage(normalizedPhone, whatsappTemplate, whatsappParams || {});
        }
      }
    }
  }
}

module.exports = {
  sendPushToUser,
  sendPushToTopic,
  sendMultiChannelNotification,
};
