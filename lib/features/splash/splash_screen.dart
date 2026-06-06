import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/login_screen.dart';

/// Splash Screen — Dramatic cinematic ONYX intro with multi-phase animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  // Phase 1: Dark void → accent glow emerges
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;

  // Phase 2: Logo icon punches in
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;

  // Phase 3: Letters reveal one-by-one
  late Animation<double> _lettersProgress;

  // Phase 4: Divider sweeps
  late Animation<double> _lineWidth;

  // Phase 5: Tagline + facilities slide up
  late Animation<double> _taglineSlide;
  late Animation<double> _taglineOpacity;

  // Phase 6: Particle burst
  late Animation<double> _particleBurst;

  // Pulse for logo glow
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Phase 1: Glow (0% → 25%)
    _glowScale = Tween<double>(begin: 0, end: 1.2).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.25, curve: Curves.easeOutCubic)),
    );
    _glowOpacity = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.20, curve: Curves.easeOut)),
    );

    // Phase 2: Logo punch (15% → 40%)
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.15, 0.40, curve: Curves.elasticOut)),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.15, 0.30, curve: Curves.easeOut)),
    );
    _logoRotation = Tween<double>(begin: -0.1, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.15, 0.40, curve: Curves.elasticOut)),
    );

    // Phase 3: Letters (35% → 60%)
    _lettersProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.35, 0.60, curve: Curves.easeOutCubic)),
    );

    // Phase 4: Line (50% → 70%)
    _lineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.50, 0.70, curve: Curves.easeInOutCubic)),
    );

    // Phase 5: Tagline (65% → 85%)
    _taglineSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.65, 0.85, curve: Curves.easeOutCubic)),
    );
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.65, 0.80, curve: Curves.easeOut)),
    );

    // Phase 6: Particle burst (40% → 65%)
    _particleBurst = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.40, 0.65, curve: Curves.easeOut)),
    );

    // Pulse
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Start pulse after logo appears
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });

    // Navigate
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['O', 'N', 'Y', 'X'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _pulseController]),
        builder: (context, _) {
          return Stack(
            children: [
              // ── Background Glow ──────────────────────────────
              Center(
                child: Opacity(
                  opacity: _glowOpacity.value,
                  child: Transform.scale(
                    scale: _glowScale.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.3),
                            AppColors.accent.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Particles ────────────────────────────────────
              if (_particleBurst.value > 0)
                ...List.generate(12, (i) {
                  final angle = (i / 12) * 2 * math.pi;
                  final radius = _particleBurst.value * 120;
                  final particleOpacity = (1 - _particleBurst.value).clamp(0.0, 1.0);
                  final size = 3.0 + (i % 3) * 1.5;
                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + math.cos(angle) * radius - size / 2,
                    top: MediaQuery.of(context).size.height / 2 - 30 + math.sin(angle) * radius - size / 2,
                    child: Opacity(
                      opacity: particleOpacity * 0.7,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: i % 3 == 0 ? AppColors.accent : i % 3 == 1 ? AppColors.badminton : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

              // ── Main Content ─────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo icon with pulse glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse ring
                        if (_logoOpacity.value > 0.5)
                          Transform.scale(
                            scale: _pulse.value * _logoScale.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accent.withValues(alpha: ((_pulse.value - 0.85) / 0.3).clamp(0.0, 0.3)),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                        // Logo
                        Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Transform.rotate(
                              angle: _logoRotation.value,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(alpha: 0.4 * _logoOpacity.value),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'O',
                                    style: AppTypography.displayLarge.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Letter-by-letter ONYX ───────────────────
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(4, (i) {
                        final letterProgress = ((_lettersProgress.value * 4) - i).clamp(0.0, 1.0);
                        return Opacity(
                          opacity: letterProgress,
                          child: Transform.translate(
                            offset: Offset(0, (1 - letterProgress) * -20),
                            child: Transform.scale(
                              scale: 0.5 + letterProgress * 0.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Text(
                                  letters[i],
                                  style: AppTypography.displayLarge.copyWith(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 6,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // ── Sweeping Divider ─────────────────────────
                    SizedBox(
                      width: 200,
                      child: Stack(
                        children: [
                          // Track
                          Container(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
                          // Active line
                          FractionallySizedBox(
                            widthFactor: _lineWidth.value,
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.8),
                                    AppColors.accent,
                                    AppColors.accent.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Tagline ──────────────────────────────────
                    Opacity(
                      opacity: _taglineOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _taglineSlide.value),
                        child: Text(
                          'PREMIUM SPORTS FACILITY',
                          style: AppTypography.overline.copyWith(
                            letterSpacing: 4,
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Facility icons ───────────────────────────
                    Opacity(
                      opacity: _taglineOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _taglineSlide.value),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _FacilityIcon(icon: Icons.sports_tennis_rounded, delay: 0, progress: _taglineOpacity.value, color: AppColors.badminton),
                            _FacilityDot(progress: _taglineOpacity.value),
                            _FacilityIcon(icon: Icons.sports_cricket_rounded, delay: 0.1, progress: _taglineOpacity.value, color: AppColors.cricketTurf),
                            _FacilityDot(progress: _taglineOpacity.value),
                            _FacilityIcon(icon: Icons.sports_baseball_rounded, delay: 0.2, progress: _taglineOpacity.value, color: AppColors.cricketNets),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom Branding ──────────────────────────────
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _taglineOpacity.value,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 16, height: 1, color: AppColors.border.withValues(alpha: 0.4)),
                          const SizedBox(width: 8),
                          Text('EST. 2024', style: AppTypography.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 2, fontSize: 9)),
                          const SizedBox(width: 8),
                          Container(width: 16, height: 1, color: AppColors.border.withValues(alpha: 0.4)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FacilityIcon extends StatelessWidget {
  final IconData icon;
  final double delay;
  final double progress;
  final Color color;
  const _FacilityIcon({required this.icon, required this.delay, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(icon, size: 16, color: color.withValues(alpha: progress)),
    );
  }
}

class _FacilityDot extends StatelessWidget {
  final double progress;
  const _FacilityDot({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.textDisabled.withValues(alpha: progress),
        shape: BoxShape.circle,
      ),
    );
  }
}
