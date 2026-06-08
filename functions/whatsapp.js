/**
 * ONYX — WhatsApp Business API Cloud Functions
 *
 * Handles all WhatsApp Business API interactions via Meta's Cloud API.
 * Uses pre-approved message templates for transactional messages
 * and marketing templates for promotions/advertisements.
 *
 * Setup:
 *   1. Create a Meta Business account at business.facebook.com
 *   2. Set up WhatsApp Business API in Meta for Developers
 *   3. Get your Phone Number ID and Access Token
 *   4. Create message templates and get them approved
 *   5. Store credentials in Firebase config:
 *      firebase functions:config:set whatsapp.phone_id="YOUR_PHONE_NUMBER_ID"
 *      firebase functions:config:set whatsapp.token="YOUR_ACCESS_TOKEN"
 *      firebase functions:config:set whatsapp.business_id="YOUR_BUSINESS_ACCOUNT_ID"
 *
 * Or use environment variables in .env for v2 functions:
 *   WHATSAPP_PHONE_ID, WHATSAPP_TOKEN, WHATSAPP_BUSINESS_ID
 */

const axios = require("axios");

const WHATSAPP_API_URL = "https://graph.facebook.com/v21.0";

// ════════════════════════════════════════════════════════════════
// CONFIGURATION
// ════════════════════════════════════════════════════════════════

function getWhatsAppConfig() {
  return {
    phoneNumberId: process.env.WHATSAPP_PHONE_ID || "",
    accessToken: process.env.WHATSAPP_TOKEN || "",
    businessAccountId: process.env.WHATSAPP_BUSINESS_ID || "",
  };
}

// ════════════════════════════════════════════════════════════════
// META CLOUD API — Core Sender
// ════════════════════════════════════════════════════════════════

/**
 * Send a WhatsApp message using Meta's Cloud API.
 * @param {string} to - Recipient phone number (with country code, e.g., "919876543210")
 * @param {object} messagePayload - The message object (template, text, media, etc.)
 * @returns {object} API response data
 */
async function sendWhatsAppMessage(to, messagePayload) {
  const config = getWhatsAppConfig();

  if (!config.phoneNumberId || !config.accessToken) {
    console.warn("[WhatsApp] API credentials not configured. Skipping send.");
    return { success: false, error: "WhatsApp API not configured" };
  }

  try {
    const response = await axios.post(
      `${WHATSAPP_API_URL}/${config.phoneNumberId}/messages`,
      {
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to,
        ...messagePayload,
      },
      {
        headers: {
          Authorization: `Bearer ${config.accessToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    console.log(`[WhatsApp] Sent to ${to}: ${response.data.messages?.[0]?.id}`);
    return { success: true, messageId: response.data.messages?.[0]?.id };
  } catch (error) {
    const errMsg = error.response?.data?.error?.message || error.message;
    console.error(`[WhatsApp] Error sending to ${to}: ${errMsg}`);
    return { success: false, error: errMsg };
  }
}

// ════════════════════════════════════════════════════════════════
// TEMPLATE MESSAGES
// ════════════════════════════════════════════════════════════════

/**
 * Message template definitions.
 * These MUST be pre-approved in Meta Business Manager before use.
 *
 * Template naming convention: onyx_{category}_{action}
 * Language: en (English), hi (Hindi) — add per your approval.
 */
const TEMPLATES = {
  // ── Booking Templates ────────────────────────────────────────
  bookingConfirmation: {
    name: "onyx_booking_confirmed",
    language: "en",
    // Parameters: [customerName, facilityName, date, time, bookingId]
    buildComponents: ({ customerName, facilityName, date, time, bookingId }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: customerName },
          { type: "text", text: facilityName },
          { type: "text", text: date },
          { type: "text", text: time },
          { type: "text", text: bookingId },
        ],
      },
    ],
  },

  bookingReminder: {
    name: "onyx_booking_reminder",
    language: "en",
    // Parameters: [customerName, facilityName, date, time]
    buildComponents: ({ customerName, facilityName, date, time }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: customerName },
          { type: "text", text: facilityName },
          { type: "text", text: date },
          { type: "text", text: time },
        ],
      },
    ],
  },

  bookingCancellation: {
    name: "onyx_booking_cancelled",
    language: "en",
    // Parameters: [customerName, facilityName, date, time, reason]
    buildComponents: ({ customerName, facilityName, date, time, reason }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: customerName },
          { type: "text", text: facilityName },
          { type: "text", text: date },
          { type: "text", text: time },
          { type: "text", text: reason || "No reason provided" },
        ],
      },
    ],
  },

  // ── Payment Templates ────────────────────────────────────────
  paymentReceipt: {
    name: "onyx_payment_receipt",
    language: "en",
    // Parameters: [customerName, amount, description, paymentId]
    buildComponents: ({ customerName, amount, description, paymentId }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: customerName },
          { type: "text", text: `₹${amount}` },
          { type: "text", text: description },
          { type: "text", text: paymentId },
        ],
      },
    ],
  },

  // ── Membership Templates ─────────────────────────────────────
  membershipActivation: {
    name: "onyx_membership_activated",
    language: "en",
    // Parameters: [customerName, planName, expiryDate]
    buildComponents: ({ customerName, planName, expiryDate }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: customerName },
          { type: "text", text: planName },
          { type: "text", text: expiryDate },
        ],
      },
    ],
  },

  membershipExpiry: {
    name: "onyx_membership_expiry",
    language: "en",
    // Parameters: [customerName, planName, daysRemaining]
    buildComponents: ({ customerName, planName, daysRemaining }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: customerName },
          { type: "text", text: planName },
          { type: "text", text: `${daysRemaining}` },
        ],
      },
    ],
  },

  // ── Coaching Templates ───────────────────────────────────────
  sessionCancellation: {
    name: "onyx_session_cancelled",
    language: "en",
    // Parameters: [studentName, batchName, date, reason]
    buildComponents: ({ studentName, batchName, date, reason }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: studentName },
          { type: "text", text: batchName },
          { type: "text", text: date },
          { type: "text", text: reason },
        ],
      },
    ],
  },

  // ── Marketing Templates ──────────────────────────────────────
  promotion: {
    name: "onyx_promotion",
    language: "en",
    // Parameters: [title, body]
    buildComponents: ({ title, body }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: title },
          { type: "text", text: body },
        ],
      },
    ],
    // Optional header image
    buildHeaderImage: (imageUrl) =>
      imageUrl
        ? [
            {
              type: "header",
              parameters: [{ type: "image", image: { link: imageUrl } }],
            },
          ]
        : [],
  },

  tournamentAnnouncement: {
    name: "onyx_tournament_announcement",
    language: "en",
    // Parameters: [tournamentName, date, sport, spotsLeft]
    buildComponents: ({ tournamentName, date, sport, spotsLeft }) => [
      {
        type: "body",
        parameters: [
          { type: "text", text: tournamentName },
          { type: "text", text: date },
          { type: "text", text: sport },
          { type: "text", text: `${spotsLeft}` },
        ],
      },
    ],
  },
};

// ════════════════════════════════════════════════════════════════
// TEMPLATE SENDER — Builds & sends template messages
// ════════════════════════════════════════════════════════════════

/**
 * Send a pre-approved template message.
 * @param {string} to - Phone number with country code
 * @param {string} templateKey - Key from TEMPLATES object
 * @param {object} params - Template parameters
 * @returns {object} Result
 */
async function sendTemplateMessage(to, templateKey, params) {
  const template = TEMPLATES[templateKey];
  if (!template) {
    console.error(`[WhatsApp] Unknown template: ${templateKey}`);
    return { success: false, error: `Unknown template: ${templateKey}` };
  }

  const components = template.buildComponents(params);

  // Add header image for marketing templates if available
  if (template.buildHeaderImage && params.imageUrl) {
    components.unshift(...template.buildHeaderImage(params.imageUrl));
  }

  return sendWhatsAppMessage(to, {
    type: "template",
    template: {
      name: template.name,
      language: { code: template.language },
      components,
    },
  });
}

// ════════════════════════════════════════════════════════════════
// BROADCAST — Send to multiple users
// ════════════════════════════════════════════════════════════════

/**
 * Send a template message to multiple phone numbers.
 * Respects WhatsApp rate limits (80 messages/second for tier 1).
 * @param {string[]} phoneNumbers - Array of phone numbers
 * @param {string} templateKey - Template key
 * @param {object} params - Template parameters
 * @param {number} delayMs - Delay between messages (default 50ms)
 * @returns {object} Results summary
 */
async function broadcastTemplate(phoneNumbers, templateKey, params, delayMs = 50) {
  const results = { sent: 0, failed: 0, errors: [] };

  for (const phone of phoneNumbers) {
    const result = await sendTemplateMessage(phone, templateKey, params);
    if (result.success) {
      results.sent++;
    } else {
      results.failed++;
      results.errors.push({ phone, error: result.error });
    }

    // Rate limiting delay
    if (delayMs > 0) {
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }

  console.log(`[WhatsApp] Broadcast ${templateKey}: ${results.sent} sent, ${results.failed} failed`);
  return results;
}

// ════════════════════════════════════════════════════════════════
// UTILITY — Phone number formatting
// ════════════════════════════════════════════════════════════════

/**
 * Normalize Indian phone numbers to E.164 format.
 * "9876543210" → "919876543210"
 * "+919876543210" → "919876543210"
 * "09876543210" → "919876543210"
 */
function normalizePhoneNumber(phone) {
  if (!phone) return null;
  let cleaned = phone.replace(/[\s\-\(\)\+]/g, "");
  if (cleaned.startsWith("0")) cleaned = cleaned.substring(1);
  if (cleaned.length === 10) cleaned = "91" + cleaned;
  return cleaned;
}

module.exports = {
  sendWhatsAppMessage,
  sendTemplateMessage,
  broadcastTemplate,
  normalizePhoneNumber,
  TEMPLATES,
};
