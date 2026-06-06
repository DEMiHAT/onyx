import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/constants/mock_data.dart';

class TournamentOrganizerScreen extends StatelessWidget {
  const TournamentOrganizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(children: [
              Icon(Icons.emoji_events_rounded, size: 20, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Tournament Organizer', style: AppTypography.titleLarge),
            ]),
            actions: [
              IconButton(icon: const Icon(Icons.add_rounded, size: 22), onPressed: () {}),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: const [
                Expanded(child: StatCard(label: 'Active', value: '2', icon: Icons.play_circle_rounded)),
                SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Registrations', value: '48', icon: Icons.people_rounded)),
                SizedBox(width: 8),
                Expanded(child: StatCard(label: 'Revenue', value: '₹24K', icon: Icons.payments_rounded)),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Active Tournaments', padding: EdgeInsets.fromLTRB(16, 4, 16, 8))),
          SliverToBoxAdapter(
            child: Column(
              children: MockData.tournaments.map((t) => Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(t.name, style: AppTypography.titleMedium)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: (t.status == 'ongoing' ? AppColors.success : AppColors.accent).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                      child: Text(t.status.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: t.status == 'ongoing' ? AppColors.success : AppColors.accent, fontSize: 10)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text('${t.date} · ${t.participants}/${t.maxParticipants} players · ₹${t.prizePool.toInt()} pool', style: AppTypography.bodySmall),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Fixtures'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Results'))),
                  ]),
                ]),
              )).toList(),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Actions', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                _Item(icon: Icons.add_circle_outline_rounded, label: 'Create Tournament', color: AppColors.accent),
                _Item(icon: Icons.app_registration_rounded, label: 'Manage Registrations', color: AppColors.success),
                _Item(icon: Icons.account_tree_rounded, label: 'Generate Brackets', color: AppColors.warning),
                _Item(icon: Icons.publish_rounded, label: 'Publish Winners', color: AppColors.success),
                _Item(icon: Icons.notifications_active_rounded, label: 'Send Notifications', color: AppColors.warning, isLast: true),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon; final String label; final Color color; final bool isLast;
  const _Item({required this.icon, required this.label, required this.color, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.bodyLarge)),
          Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}
