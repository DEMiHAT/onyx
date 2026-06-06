import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../models/models.dart';

/// Tournament Detail Screen — Full tournament info, rules, schedule, bracket.
class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;
  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name, style: AppTypography.titleLarge),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded, size: 20), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Header Banner ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tournament.status == 'ongoing'
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tournament.status.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: tournament.status == 'ongoing' ? AppColors.success : AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        tournament.sport == SportType.badminton ? '🏸 Badminton' : '🏏 Cricket',
                        style: AppTypography.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _TourneyField(label: 'DATE', value: tournament.date)),
                      Expanded(child: _TourneyField(label: 'ENTRY FEE', value: '₹${tournament.entryFee.toInt()}')),
                      Expanded(child: _TourneyField(label: 'PRIZE POOL', value: '₹${tournament.prizePool.toInt()}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Participants progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Participants', style: AppTypography.labelSmall),
                                Text(
                                  '${tournament.participants}/${tournament.maxParticipants}',
                                  style: AppTypography.mono.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: tournament.participants / tournament.maxParticipants,
                                backgroundColor: AppColors.surfaceSecondary,
                                valueColor: AlwaysStoppedAnimation(
                                  tournament.participants >= tournament.maxParticipants
                                      ? AppColors.error
                                      : AppColors.accent,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Rules ──────────────────────────────────────────────
          if (tournament.rules.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Rules', padding: EdgeInsets.fromLTRB(16, 8, 16, 8)),
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
                child: Text(tournament.rules, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ),
            ),
          ],

          // ── Schedule ───────────────────────────────────────────
          if (tournament.schedule.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Schedule', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                  children: tournament.schedule.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: index < tournament.schedule.length - 1
                            ? const Border(bottom: BorderSide(color: AppColors.border))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTypography.monoSmall.copyWith(color: AppColors.textTertiary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item, style: AppTypography.bodyLarge),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          // ── Bracket (Placeholder) ──────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Bracket', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_tree_rounded, size: 36, color: AppColors.textDisabled),
                  const SizedBox(height: 8),
                  Text('Bracket will be available\nafter registration closes', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),

          // ── Hall of Fame ───────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Hall of Fame', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
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
                children: const [
                  _ChampionRow(tournament: 'Spring Open 2026', winner: 'Vikram Patel', date: 'Mar 2026'),
                  _ChampionRow(tournament: 'Winter Classic 2025', winner: 'Ananya Desai', date: 'Dec 2025'),
                  _ChampionRow(tournament: 'ONYX Founders Cup', winner: 'Rohan Iyer', date: 'Oct 2025', isLast: true),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      bottomNavigationBar: tournament.status == 'upcoming'
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Entry Fee', style: AppTypography.labelSmall),
                          Text('₹${tournament.entryFee.toInt()}', style: AppTypography.headlineMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Register (${tournament.maxParticipants - tournament.participants} spots)'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _TourneyField extends StatelessWidget {
  final String label;
  final String value;
  const _TourneyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.overline.copyWith(fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.titleSmall),
      ],
    );
  }
}

class _ChampionRow extends StatelessWidget {
  final String tournament;
  final String winner;
  final String date;
  final bool isLast;

  const _ChampionRow({required this.tournament, required this.winner, required this.date, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tournament, style: AppTypography.titleSmall),
                const SizedBox(height: 2),
                Text('Winner: $winner', style: AppTypography.bodySmall),
              ],
            ),
          ),
          Text(date, style: AppTypography.monoSmall),
        ],
      ),
    );
  }
}
