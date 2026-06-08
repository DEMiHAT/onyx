import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/auth_service.dart';
import '../../models/models.dart';

/// Leaderboard Screen — Activity-based rankings (NOT win-based).
/// LeetCode-style table: Rank | Player | Sessions | Hours
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard', style: AppTypography.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Most Active'),
            Tab(text: 'Most Hours'),
            Tab(text: 'Longest Streak'),
            Tab(text: 'By Facility'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardTable(sortBy: 'sessions'),
          _LeaderboardTable(sortBy: 'hours'),
          _LeaderboardTable(sortBy: 'streak'),
          _FacilityLeaderboard(),
        ],
      ),
    );
  }
}

class _LeaderboardTable extends StatelessWidget {
  final String sortBy;
  const _LeaderboardTable({required this.sortBy});

  @override
  Widget build(BuildContext context) {
    final entries = <LeaderboardEntry>[]; // TODO: Fetch from Firestore

    // Sort based on tab
    if (sortBy == 'hours') {
      entries.sort((a, b) => b.hours.compareTo(a.hours));
    } else if (sortBy == 'streak') {
      entries.sort((a, b) => b.streak.compareTo(a.streak));
    }

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              SizedBox(width: 36, child: Text('#', style: AppTypography.overline)),
              Expanded(flex: 4, child: Text('PLAYER', style: AppTypography.overline)),
              Expanded(flex: 2, child: Text('SESSIONS', style: AppTypography.overline, textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text('HOURS', style: AppTypography.overline, textAlign: TextAlign.right)),
              if (sortBy == 'streak')
                Expanded(flex: 2, child: Text('STREAK', style: AppTypography.overline, textAlign: TextAlign.right)),
            ],
          ),
        ),
        // Table rows
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final userName = AuthService.instance.displayName;
              final isCurrentUser = entry.playerName == userName;
              final displayRank = index + 1;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser ? AppColors.accentSubtle : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$displayRank',
                        style: AppTypography.mono.copyWith(
                          color: displayRank <= 3 ? AppColors.warning : AppColors.textTertiary,
                          fontWeight: displayRank <= 3 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.surfaceSecondary,
                            child: Text(
                              entry.playerName[0],
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.playerName,
                              style: AppTypography.bodyLarge.copyWith(
                                color: isCurrentUser ? AppColors.accent : AppColors.textPrimary,
                                fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${entry.sessions}',
                        style: AppTypography.mono,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${entry.hours}',
                        style: AppTypography.mono,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    if (sortBy == 'streak')
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.streak}d',
                          style: AppTypography.mono.copyWith(
                            color: entry.streak > 20 ? AppColors.success : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FacilityLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Facility', style: AppTypography.labelMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _FacilityChip(label: 'Badminton', icon: Icons.sports_tennis_rounded, selected: true),
              _FacilityChip(label: 'Cricket Turf', icon: Icons.sports_cricket_rounded, selected: false),
              _FacilityChip(label: 'Cricket Nets', icon: Icons.sports_baseball_rounded, selected: false),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _LeaderboardTable(sortBy: 'sessions'),
          ),
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _FacilityChip({required this.label, required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.accentSubtle : AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: selected ? AppColors.accent : AppColors.textTertiary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
