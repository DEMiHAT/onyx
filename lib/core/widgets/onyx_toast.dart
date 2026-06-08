/// ONYX Toast — Premium overlay-based toast notifications.
///
/// Replaces raw SnackBars with user-friendly, non-technical messages
/// and a glassmorphic design with smooth animations.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum ToastType { success, error, warning, info }

class OnyxToast {
  OnyxToast._();

  static OverlayEntry? _currentEntry;

  /// Show a premium toast overlay.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Show success toast.
  static void success(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.success);

  /// Show error toast with user-friendly message mapping.
  static void error(BuildContext context, dynamic error) {
    final msg = _mapError(error);
    show(context, message: msg, type: ToastType.error, duration: const Duration(seconds: 4));
  }

  /// Show warning toast.
  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.warning);

  /// Show info toast.
  static void info(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.info);

  /// Map technical errors to friendly messages.
  static String _mapError(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('permission') || msg.contains('permission_denied')) {
      return "You don't have permission for this action";
    }
    if (msg.contains('not_found') || msg.contains('not found')) {
      return 'This item was not found. It may have been removed';
    }
    if (msg.contains('unavailable') || msg.contains('deadline_exceeded')) {
      return 'Server is busy right now. Please try again in a moment';
    }
    if (msg.contains('unauthenticated') || msg.contains('not authenticated')) {
      return 'Your session has expired. Please log in again';
    }
    if (msg.contains('network') || msg.contains('socketexception') || msg.contains('connection')) {
      return 'No internet connection. Check your network and try again';
    }
    if (msg.contains('already-in-use') || msg.contains('email-already')) {
      return 'An account already exists with this email';
    }
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Incorrect email or password';
    }
    if (msg.contains('user-not-found')) {
      return 'No account found with this email';
    }
    if (msg.contains('weak-password')) {
      return 'Password must be at least 6 characters';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again';
    }
    if (msg.contains('cancelled') || msg.contains('canceled')) {
      return 'Payment was cancelled. No charge was made';
    }
    if (msg.contains('payment') && msg.contains('fail')) {
      return 'Payment could not be processed. Please try again';
    }
    if (msg.contains('slot') && msg.contains('available')) {
      return 'This time slot is no longer available';
    }
    if (msg.contains('invalid')) {
      return 'Something went wrong. Please check your input and try again';
    }

    // Fallback — strip technical prefixes
    final clean = error.toString()
        .replaceAll(RegExp(r'\[firebase_.*?\]'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll('Exception:', '')
        .replaceAll('Error:', '')
        .trim();
    return clean.isEmpty ? 'Something went wrong. Please try again' : clean;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, bgColor) = switch (widget.type) {
      ToastType.success => (Icons.check_circle_rounded, AppColors.success, AppColors.success.withValues(alpha: 0.12)),
      ToastType.error => (Icons.error_rounded, AppColors.error, AppColors.error.withValues(alpha: 0.12)),
      ToastType.warning => (Icons.warning_rounded, AppColors.warning, AppColors.warning.withValues(alpha: 0.12)),
      ToastType.info => (Icons.info_rounded, AppColors.accent, AppColors.accent.withValues(alpha: 0.12)),
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              _controller.reverse().then((_) {
                if (mounted) widget.onDismiss();
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 18, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
