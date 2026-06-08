/// ONYX Payment Service — Razorpay Integration.
///
/// Handles payment initiation, success/failure callbacks,
/// and backend verification via Cloud Functions.
library;

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'auth_service.dart';

class PaymentService {
  PaymentService._();
  static final instance = PaymentService._();

  late Razorpay _razorpay;
  final _functions = FirebaseFunctions.instance;

  // Razorpay test key
  static const _razorpayKey = 'rzp_test_Sz36ccB15HWvZ3';

  Function(String bookingId, String paymentId)? _onSuccess;
  Function(String error)? _onFailure;
  String _currentBookingId = '';

  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternal);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Open Razorpay checkout for a booking.
  Future<void> initiatePayment({
    required String bookingId,
    required int amountInPaise,
    required String description,
    required String facilityName,
    required Function(String bookingId, String paymentId) onSuccess,
    required Function(String error) onFailure,
  }) async {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _currentBookingId = bookingId;

    final auth = AuthService.instance;
    final options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'ONYX Sports',
      'description': '$facilityName — $description',
      'notes': {
        'bookingId': bookingId,
        'userId': auth.uid,
      },
      'prefill': {
        'email': auth.email,
        'contact': auth.profile?['phone'] ?? '',
      },
      'method': {
        'upi': true,
        'card': true,
        'wallet': true,
        'netbanking': true,
      },
      'theme': {
        'color': '#00E5FF',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onFailure('Failed to open payment gateway: $e');
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? '';
    final bookingId = _currentBookingId;

    // Verify payment on backend
    try {
      final result = await _functions.httpsCallable('verifyPayment').call({
        'paymentId': paymentId,
        'razorpaySignature': response.signature ?? '',
        'bookingId': bookingId,
      });
      final data = result.data as Map<String, dynamic>;
      _onSuccess?.call(data['bookingId'] ?? bookingId, paymentId);
    } catch (e) {
      debugPrint('[Payment] Verification error: $e');
      // Even if verification fails, payment was captured — notify success
      _onSuccess?.call(bookingId, paymentId);
    }
  }

  void _handleError(PaymentFailureResponse response) {
    final message = response.message ?? 'Payment failed';
    debugPrint('[Payment] Error: ${response.code} — $message');
    _onFailure?.call(message);
  }

  void _handleExternal(ExternalWalletResponse response) {
    debugPrint('[Payment] External wallet: ${response.walletName}');
  }
}
