import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// QR Scanner Screen — For receptionist/manager to scan booking check-in QR codes.
/// On successful scan, calls checkInBooking Cloud Function to start the session.
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  bool _scanned = false;
  String? _resultMessage;
  bool _isSuccess = false;
  Map<String, dynamic>? _bookingDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null) return;

    // Parse the QR data
    Map<String, dynamic>? qrData;
    try {
      qrData = jsonDecode(rawValue) as Map<String, dynamic>;
    } catch (_) {
      setState(() {
        _resultMessage = 'Invalid QR code format';
        _isSuccess = false;
        _scanned = true;
      });
      return;
    }

    if (qrData['type'] != 'onyx_checkin' || qrData['token'] == null) {
      setState(() {
        _resultMessage = 'Not a valid ONYX check-in QR';
        _isSuccess = false;
        _scanned = true;
      });
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('checkInBooking')
          .call({
        'checkInToken': qrData['token'],
        'bookingId': qrData['bookingId'],
      });

      final data = result.data as Map<String, dynamic>;
      setState(() {
        _isProcessing = false;
        _scanned = true;
        _isSuccess = true;
        _resultMessage = 'Session Started!';
        _bookingDetails = data;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _scanned = true;
        _isSuccess = false;
        _resultMessage = e.toString().contains('already')
            ? 'Already checked in'
            : 'Check-in failed: ${e.toString().split(']').last.trim()}';
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _scanned = false;
      _isProcessing = false;
      _resultMessage = null;
      _bookingDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Check-In', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: Icon(_controller.torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded, size: 20),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Camera View ───────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scanner
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),

                // Scan overlay frame
                Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _scanned
                          ? (_isSuccess ? AppColors.success : AppColors.error)
                          : AppColors.accent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                // Corner accents
                ..._buildCorners(),

                // Processing indicator
                if (_isProcessing)
                  Container(
                    width: 250, height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
                    ),
                  ),
              ],
            ),
          ),

          // ── Result Panel ──────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: _scanned ? _buildResult() : _buildInstructions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_scanner_rounded, size: 40, color: AppColors.accent.withValues(alpha: 0.6)),
        const SizedBox(height: 16),
        Text('Scan Booking QR', style: AppTypography.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Point the camera at the member\'s booking QR code to check them in and start the session timer.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        // Status icon
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: (_isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: _isSuccess ? AppColors.success : AppColors.error,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(_resultMessage ?? '', style: AppTypography.titleMedium),
        const SizedBox(height: 4),

        // Booking details on success
        if (_isSuccess && _bookingDetails != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Facility', value: _bookingDetails!['facilityName'] ?? '—'),
                _InfoRow(label: 'Time', value: '${_bookingDetails!['startTime'] ?? ''} — ${_bookingDetails!['endTime'] ?? ''}'),
                _InfoRow(label: 'Duration', value: '${_bookingDetails!['durationMinutes'] ?? '60'} min'),
              ],
            ),
          ),
        ],

        const Spacer(),

        // Action button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _isSuccess ? () => Navigator.pop(context) : _resetScanner,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSuccess ? AppColors.success : AppColors.accent,
            ),
            child: Text(_isSuccess ? 'Done' : 'Scan Again'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorners() {
    const size = 20.0;
    const offset = 103.0; // (250/2) - size + border
    final color = _scanned
        ? (_isSuccess ? AppColors.success : AppColors.error)
        : AppColors.accent;

    return [
      Positioned(left: MediaQuery.of(context).size.width / 2 - offset, top: MediaQuery.of(context).size.height * 0.3 - offset,
        child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: 3), left: BorderSide(color: color, width: 3)), borderRadius: const BorderRadius.only(topLeft: Radius.circular(8))))),
      Positioned(right: MediaQuery.of(context).size.width / 2 - offset, top: MediaQuery.of(context).size.height * 0.3 - offset,
        child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: 3), right: BorderSide(color: color, width: 3)), borderRadius: const BorderRadius.only(topRight: Radius.circular(8))))),
      Positioned(left: MediaQuery.of(context).size.width / 2 - offset, bottom: MediaQuery.of(context).size.height * 0.3 - offset,
        child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 3), left: BorderSide(color: color, width: 3)), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8))))),
      Positioned(right: MediaQuery.of(context).size.width / 2 - offset, bottom: MediaQuery.of(context).size.height * 0.3 - offset,
        child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: 3), right: BorderSide(color: color, width: 3)), borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8))))),
    ];
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
    );
  }
}
