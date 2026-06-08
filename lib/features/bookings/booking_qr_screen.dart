import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Booking QR Screen — Shown after successful payment.
/// Displays a QR code encoding the check-in token for receptionist scanning.
class BookingQRScreen extends StatelessWidget {
  final String bookingId;
  final String checkInToken;
  final String facilityName;
  final String date;
  final String timeSlot;
  final double amount;
  final String? courtNumber;

  const BookingQRScreen({
    super.key,
    required this.bookingId,
    required this.checkInToken,
    required this.facilityName,
    required this.date,
    required this.timeSlot,
    required this.amount,
    this.courtNumber,
  });

  @override
  Widget build(BuildContext context) {
    // QR data is a JSON payload with the token and booking ID
    final qrData = jsonEncode({
      'type': 'onyx_checkin',
      'token': checkInToken,
      'bookingId': bookingId,
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmed', style: AppTypography.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Success Header ──────────────────────────────
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 12),
            Text('Payment Successful', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text('Show this QR at the front desk', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // ── QR Code Card ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF111111),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Booking #${bookingId.substring(0, bookingId.length > 8 ? 8 : bookingId.length).toUpperCase()}',
                    style: AppTypography.mono.copyWith(fontSize: 11, color: const Color(0xFF666666)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Booking Details ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Facility', value: facilityName),
                  if (courtNumber != null)
                    _DetailRow(label: 'Court', value: courtNumber!),
                  _DetailRow(label: 'Date', value: date),
                  _DetailRow(label: 'Time', value: timeSlot),
                  const Divider(color: AppColors.border, height: 20),
                  _DetailRow(
                    label: 'Amount Paid',
                    value: '₹${amount.toInt()}',
                    valueStyle: AppTypography.titleMedium.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Info Banner ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The receptionist will scan this QR to start your session timer.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Done Button ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _DetailRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: valueStyle ?? AppTypography.titleSmall),
        ],
      ),
    );
  }
}
