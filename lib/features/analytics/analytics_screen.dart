import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';


/// Analytics Screen — Player activity analytics with charts.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder analytics data
    const totalSessions = 42;
    const totalHours = 65.5;
    const favoriteFacility = 'Badminton';
    const mostActiveDay = 'Saturday';
    const currentStreak = 5;

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: AppTypography.titleLarge),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Last 30 Days', style: AppTypography.labelSmall),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Overview Stats ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: StatCard(label: 'Total Sessions', value: '$totalSessions', trend: '+12 this month', icon: Icons.sports_tennis_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: StatCard(label: 'Hours Played', value: '$totalHours', trend: '+18h this month', icon: Icons.timer_rounded)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: StatCard(label: 'Favorite Facility', value: favoriteFacility, icon: Icons.favorite_rounded)),
                      const SizedBox(width: 8),
                      Expanded(child: StatCard(label: 'Most Active Day', value: mostActiveDay, icon: Icons.calendar_today_rounded)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Monthly Activity Chart (Simulated) ─────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Monthly Activity', padding: EdgeInsets.fromLTRB(16, 8, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Bar chart simulation
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _BarItem(label: 'Jan', value: 0.4),
                        _BarItem(label: 'Feb', value: 0.6),
                        _BarItem(label: 'Mar', value: 0.55),
                        _BarItem(label: 'Apr', value: 0.75),
                        _BarItem(label: 'May', value: 0.85),
                        _BarItem(label: 'Jun', value: 0.65, isCurrent: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Facility Breakdown ─────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Facility Breakdown', padding: EdgeInsets.fromLTRB(16, 24, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _FacilityBreakdownRow(name: 'Badminton Courts', sessions: 98, hours: 147, percentage: 0.69, color: AppColors.badminton),
                  _FacilityBreakdownRow(name: 'Cricket Turf', sessions: 28, hours: 42, percentage: 0.20, color: AppColors.cricketTurf),
                  _FacilityBreakdownRow(name: 'Cricket Nets', sessions: 16, hours: 24, percentage: 0.11, color: AppColors.cricketNets, isLast: true),
                ],
              ),
            ),
          ),

          // ── Attendance Trend ───────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Weekly Trend', padding: EdgeInsets.fromLTRB(16, 24, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _DayDot(day: 'M', active: true),
                  _DayDot(day: 'T', active: true),
                  _DayDot(day: 'W', active: true),
                  _DayDot(day: 'T', active: false),
                  _DayDot(day: 'F', active: true),
                  _DayDot(day: 'S', active: true),
                  _DayDot(day: 'S', active: false, isCurrent: true),
                ],
              ),
            ),
          ),

          // ── Streaks ────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Streaks', padding: EdgeInsets.fromLTRB(16, 24, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Row(
                children: [
                  Expanded(child: StatCard(label: 'Current', value: '${currentStreak}d', icon: Icons.local_fire_department_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Best', value: '21d', icon: Icons.emoji_events_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'This Month', value: '18d', icon: Icons.calendar_month_rounded)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double value; // 0 to 1
  final bool isCurrent;

  const _BarItem({required this.label, required this.value, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${(value * 30).toInt()}',
              style: AppTypography.monoSmall.copyWith(
                color: isCurrent ? AppColors.accent : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: value * 100,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.accent : AppColors.surfaceSecondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                border: Border.all(
                  color: isCurrent ? AppColors.accent : AppColors.border,
                  width: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _FacilityBreakdownRow extends StatelessWidget {
  final String name;
  final int sessions;
  final int hours;
  final double percentage;
  final Color color;
  final bool isLast;

  const _FacilityBreakdownRow({
    required this.name, required this.sessions, required this.hours,
    required this.percentage, required this.color, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: AppTypography.titleSmall)),
              Text('$sessions sessions · ${hours}h', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String day;
  final bool active;
  final bool isCurrent;

  const _DayDot({required this.day, required this.active, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.success.withValues(alpha: 0.15)
                : isCurrent
                    ? AppColors.surfaceSecondary
                    : Colors.transparent,
            border: Border.all(
              color: active ? AppColors.success : isCurrent ? AppColors.border : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: active
              ? const Icon(Icons.check_rounded, size: 14, color: AppColors.success)
              : null,
        ),
        const SizedBox(height: 4),
        Text(day, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}
