import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Session Timer Screen — Full-screen countdown timer for active bookings.
/// Shows remaining time with color transitions: Green → Yellow → Red.
class SessionTimerScreen extends StatefulWidget {
  final String facilityName;
  final String? courtNumber;
  final String startTime;
  final String endTime;
  final int totalMinutes;
  final DateTime sessionStart;

  const SessionTimerScreen({
    super.key,
    required this.facilityName,
    this.courtNumber,
    required this.startTime,
    required this.endTime,
    required this.totalMinutes,
    required this.sessionStart,
  });

  @override
  State<SessionTimerScreen> createState() => _SessionTimerScreenState();
}

class _SessionTimerScreenState extends State<SessionTimerScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulse;
  int _remainingSeconds = 0;
  bool _isOver = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final endAt = widget.sessionStart.add(Duration(minutes: widget.totalMinutes));
    final now = DateTime.now();
    final diff = endAt.difference(now).inSeconds;
    setState(() {
      _remainingSeconds = diff > 0 ? diff : 0;
      _isOver = diff <= 0;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  double get _progress {
    final total = widget.totalMinutes * 60;
    if (total == 0) return 0;
    return (_remainingSeconds / total).clamp(0.0, 1.0);
  }

  Color get _timerColor {
    if (_progress > 0.5) return AppColors.success;
    if (_progress > 0.1) return AppColors.warning;
    return AppColors.error;
  }

  String get _timeDisplay {
    if (_isOver) return '00:00';
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _statusLabel {
    if (_isOver) return 'SESSION OVER';
    if (_progress > 0.5) return 'IN PROGRESS';
    if (_progress > 0.1) return 'HALF TIME';
    return 'ENDING SOON';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Session Timer', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Facility Info ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _timerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.sports_tennis_rounded, size: 20, color: _timerColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.facilityName, style: AppTypography.titleSmall),
                        Text(
                          '${widget.courtNumber != null ? '${widget.courtNumber} · ' : ''}${widget.startTime} — ${widget.endTime}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _timerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusLabel,
                      style: AppTypography.labelSmall.copyWith(color: _timerColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Circular Timer ───────────────────────────────
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                return Transform.scale(
                  scale: _isOver ? 1.0 : _pulse.value,
                  child: SizedBox(
                    width: 260, height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox(
                          width: 260, height: 260,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 8,
                            color: AppColors.border.withValues(alpha: 0.3),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Progress ring
                        SizedBox(
                          width: 260, height: 260,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi), // flip so it goes clockwise
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 8,
                              color: _timerColor,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        // Glow
                        Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _timerColor.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Time text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _timeDisplay,
                              style: AppTypography.displayLarge.copyWith(
                                fontSize: 52,
                                fontWeight: FontWeight.w300,
                                color: _timerColor,
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'remaining',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // ── Progress Bar ─────────────────────────────────
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Elapsed', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                    Text('${((1 - _progress) * 100).toInt()}%', style: AppTypography.mono.copyWith(color: _timerColor)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1 - _progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border.withValues(alpha: 0.3),
                    color: _timerColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── End Session Button ───────────────────────────
            if (_isOver)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Session Ended — Go Back'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Minimize'),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
