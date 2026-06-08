/// ONYX WhatsApp Service — Client-side interface to WhatsApp Business API.
///
/// All actual API calls are routed through Cloud Functions for security.
/// This service provides typed methods for Flutter screens to trigger
/// WhatsApp messages without exposing API keys.
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class WhatsAppService {
  WhatsAppService._();
  static final instance = WhatsAppService._();

  final _functions = FirebaseFunctions.instance;

  // ── Booking Notifications ───────────────────────────────────────

  /// Send booking confirmation via WhatsApp.
  Future<bool> sendBookingConfirmation({
    required String phoneNumber,
    required String customerName,
    required String facilityName,
    required String date,
    required String time,
    required String bookingId,
  }) async {
    return _callWhatsApp('sendWhatsAppBookingConfirmation', {
      'phoneNumber': phoneNumber,
      'customerName': customerName,
      'facilityName': facilityName,
      'date': date,
      'time': time,
      'bookingId': bookingId,
    });
  }

  /// Send booking reminder (1 hour before).
  Future<bool> sendBookingReminder({
    required String phoneNumber,
    required String customerName,
    required String facilityName,
    required String date,
    required String time,
  }) async {
    return _callWhatsApp('sendWhatsAppBookingReminder', {
      'phoneNumber': phoneNumber,
      'customerName': customerName,
      'facilityName': facilityName,
      'date': date,
      'time': time,
    });
  }

  /// Send booking cancellation notice.
  Future<bool> sendBookingCancellation({
    required String phoneNumber,
    required String customerName,
    required String facilityName,
    required String date,
    required String time,
    String? reason,
  }) async {
    return _callWhatsApp('sendWhatsAppBookingCancellation', {
      'phoneNumber': phoneNumber,
      'customerName': customerName,
      'facilityName': facilityName,
      'date': date,
      'time': time,
      'reason': reason ?? '',
    });
  }

  // ── Payment Notifications ──────────────────────────────────────

  /// Send payment receipt via WhatsApp.
  Future<bool> sendPaymentReceipt({
    required String phoneNumber,
    required String customerName,
    required double amount,
    required String description,
    required String paymentId,
  }) async {
    return _callWhatsApp('sendWhatsAppPaymentReceipt', {
      'phoneNumber': phoneNumber,
      'customerName': customerName,
      'amount': amount,
      'description': description,
      'paymentId': paymentId,
    });
  }

  // ── Membership Notifications ───────────────────────────────────

  /// Send membership activation confirmation.
  Future<bool> sendMembershipActivation({
    required String phoneNumber,
    required String customerName,
    required String planName,
    required String expiryDate,
  }) async {
    return _callWhatsApp('sendWhatsAppMembershipActivation', {
      'phoneNumber': phoneNumber,
      'customerName': customerName,
      'planName': planName,
      'expiryDate': expiryDate,
    });
  }

  /// Send membership expiry reminder.
  Future<bool> sendMembershipExpiry({
    required String phoneNumber,
    required String customerName,
    required String planName,
    required int daysRemaining,
  }) async {
    return _callWhatsApp('sendWhatsAppMembershipExpiry', {
      'phoneNumber': phoneNumber,
      'customerName': customerName,
      'planName': planName,
      'daysRemaining': daysRemaining,
    });
  }

  // ── Coaching Notifications ─────────────────────────────────────

  /// Send session cancellation notice to students.
  Future<bool> sendSessionCancellation({
    required String phoneNumber,
    required String studentName,
    required String batchName,
    required String date,
    required String reason,
  }) async {
    return _callWhatsApp('sendWhatsAppSessionCancellation', {
      'phoneNumber': phoneNumber,
      'studentName': studentName,
      'batchName': batchName,
      'date': date,
      'reason': reason,
    });
  }

  // ── Advertisements & Broadcasts ────────────────────────────────

  /// Broadcast a promotional message to all opted-in users.
  Future<bool> sendPromotion({
    required String title,
    required String body,
    String? imageUrl,
    String? ctaUrl,
    required String targetAudience, // 'all', 'members', 'guests', 'coaching'
  }) async {
    return _callWhatsApp('sendWhatsAppPromotion', {
      'title': title,
      'body': body,
      'imageUrl': imageUrl ?? '',
      'ctaUrl': ctaUrl ?? '',
      'targetAudience': targetAudience,
    });
  }

  /// Send tournament announcement to all users.
  Future<bool> sendTournamentAnnouncement({
    required String tournamentName,
    required String date,
    required String sport,
    required int spotsLeft,
    String? registrationUrl,
  }) async {
    return _callWhatsApp('sendWhatsAppTournamentAnnouncement', {
      'tournamentName': tournamentName,
      'date': date,
      'sport': sport,
      'spotsLeft': spotsLeft,
      'registrationUrl': registrationUrl ?? '',
    });
  }

  // ── Opt-in / Opt-out ───────────────────────────────────────────

  /// Record user's WhatsApp opt-in preference.
  Future<bool> updateOptIn({
    required String phoneNumber,
    required bool optIn,
  }) async {
    return _callWhatsApp('updateWhatsAppOptIn', {
      'phoneNumber': phoneNumber,
      'optIn': optIn,
    });
  }

  // ── Private Helpers ────────────────────────────────────────────

  Future<bool> _callWhatsApp(String functionName, Map<String, dynamic> data) async {
    try {
      final result = await _functions.httpsCallable(functionName).call(data);
      final success = result.data['success'] == true;
      debugPrint('[WhatsApp] $functionName: ${success ? 'sent' : 'failed'}');
      return success;
    } catch (e) {
      debugPrint('[WhatsApp] $functionName error: $e');
      return false;
    }
  }
}
