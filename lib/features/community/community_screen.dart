import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

import '../../models/models.dart';

/// Community Screen — Open Play, Find Players, Tournaments, Activity Feed
/// Vibrant, social, visual design with cards, avatars, and interaction.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() { super.initState(); _tabController = TabController(length: 4, vsync: this); }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community', style: AppTypography.titleLarge),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, size: 22), onPressed: () {}),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Open Play'),
            Tab(text: 'Find Players'),
            Tab(text: 'Tournaments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActivityFeed(),
          _OpenPlayList(),
          _FindPlayers(),
          _TournamentsList(),
        ],
      ),
    );
  }
}

// ── Activity Feed ──────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live now banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.success.withValues(alpha: 0.15), AppColors.success.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.5), blurRadius: 6)]),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('3 Players Active Now', style: AppTypography.titleSmall.copyWith(color: AppColors.success)),
              Text('Court 1 & 2 in use · Turf available', style: AppTypography.bodySmall),
            ])),
            Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.success),
          ]),
        ),
        const SizedBox(height: 16),

        // Recent activity items
        _FeedCard(
          avatar: 'A', name: 'Arjun K.', time: '2h ago', color: AppColors.badminton,
          content: 'Won a doubles match against Rahul & Priya',
          icon: Icons.emoji_events_rounded, iconColor: AppColors.warning,
          likes: 12, comments: 3,
        ),
        _FeedCard(
          avatar: 'S', name: 'Sneha R.', time: '4h ago', color: AppColors.accent,
          content: 'Looking for a singles partner this Saturday evening. Intermediate level preferred!',
          icon: Icons.sports_tennis_rounded, iconColor: AppColors.badminton,
          likes: 8, comments: 5, hasAction: true, actionLabel: 'Join',
        ),
        _FeedCard(
          avatar: 'M', name: 'Mohan V.', time: '5h ago', color: AppColors.cricketTurf,
          content: 'Great cricket session today! Hit 4 sixes in the nets 🏏',
          icon: Icons.sports_cricket_rounded, iconColor: AppColors.cricketTurf,
          likes: 23, comments: 7,
        ),
        _FeedCard(
          avatar: 'P', name: 'Priya M.', time: '1d ago', color: AppColors.success,
          content: 'Completed 30-day streak! 🔥 Thanks Coach Rajesh for the motivation',
          icon: Icons.local_fire_department_rounded, iconColor: AppColors.warning,
          likes: 45, comments: 12,
        ),
        _FeedCard(
          avatar: 'R', name: 'ONYX', time: '1d ago', color: AppColors.accent,
          content: '🏆 Summer Smash 2026 registrations closing soon! 4 spots left for doubles category.',
          icon: Icons.campaign_rounded, iconColor: AppColors.accent,
          likes: 67, comments: 18, hasAction: true, actionLabel: 'Register',
        ),
      ],
    );
  }
}

class _FeedCard extends StatelessWidget {
  final String avatar, name, time, content;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final int likes, comments;
  final bool hasAction;
  final String actionLabel;

  const _FeedCard({required this.avatar, required this.name, required this.time, required this.content, required this.color, required this.icon, required this.iconColor, required this.likes, required this.comments, this.hasAction = false, this.actionLabel = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.15), child: Text(avatar, style: AppTypography.labelMedium.copyWith(color: color))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppTypography.titleSmall),
            Text(time, style: AppTypography.labelSmall),
          ])),
          Icon(icon, size: 16, color: iconColor),
        ]),
        const SizedBox(height: 10),
        Text(content, style: AppTypography.bodyLarge),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text('$likes', style: AppTypography.labelSmall),
          const SizedBox(width: 16),
          Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text('$comments', style: AppTypography.labelSmall),
          const Spacer(),
          if (hasAction)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
              child: Text(actionLabel, style: AppTypography.labelSmall.copyWith(color: Colors.white)),
            ),
          if (!hasAction)
            Icon(Icons.share_outlined, size: 14, color: AppColors.textTertiary),
        ]),
      ]),
    );
  }
}

// ── Open Play ──────────────────────────────────────────────────

class _OpenPlayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final requests = <OpenPlayRequest>[]; // TODO: Fetch from Firestore
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final r = requests[index];
        final spotsLeft = r.playersNeeded - r.playersJoined;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 16, backgroundColor: AppColors.accentSubtle, child: Text(r.creatorName[0], style: AppTypography.labelMedium.copyWith(color: AppColors.accent))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.creatorName, style: AppTypography.titleSmall),
                Text('${r.date} · ${r.time}', style: AppTypography.bodySmall),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: spotsLeft <= 1 ? AppColors.error.withValues(alpha: 0.1) : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(spotsLeft <= 1 ? 'Last spot!' : 'Need $spotsLeft', style: AppTypography.labelSmall.copyWith(color: spotsLeft <= 1 ? AppColors.error : AppColors.accent)),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _Tag(label: r.sport == SportType.badminton ? '🏸 Badminton' : '🏏 Cricket', color: r.sport == SportType.badminton ? AppColors.badminton : AppColors.cricketTurf),
              _Tag(label: r.format == PlayFormat.singles ? 'Singles' : 'Doubles', color: AppColors.textSecondary),
              _Tag(label: r.level.name[0].toUpperCase() + r.level.name.substring(1), color: AppColors.accent),
              if (r.facility != null) _Tag(label: r.facility!, color: AppColors.textTertiary),
            ]),
            const SizedBox(height: 10),
            // Player progress
            Row(children: [
              ...List.generate(r.playersNeeded, (i) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: i < r.playersJoined ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: i < r.playersJoined ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border),
                ),
                child: Center(child: i < r.playersJoined
                    ? Icon(Icons.person_rounded, size: 12, color: AppColors.accent)
                    : Icon(Icons.add_rounded, size: 12, color: AppColors.textDisabled)),
              )),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), minimumSize: Size.zero),
                child: const Text('Join'),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
    );
  }
}

// ── Find Players ───────────────────────────────────────────────

class _FindPlayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Quick match banner
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.bolt_rounded, size: 24, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Quick Match', style: AppTypography.titleMedium.copyWith(color: AppColors.accent)),
                const SizedBox(height: 2),
                Text('Find a partner instantly based on your skill level', style: AppTypography.bodySmall),
              ])),
              ElevatedButton(onPressed: () {}, child: const Text('Go')),
            ]),
          ),
        ),

        // Available players
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('PLAYERS NEARBY', style: AppTypography.overline),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final players = [
                _PlayerData('Arjun K.', 'Advanced', '4.2', 'Doubles preferred', AppColors.success, true),
                _PlayerData('Sneha R.', 'Intermediate', '3.8', 'Singles · 6-7 PM slot', AppColors.accent, true),
                _PlayerData('Vikram S.', 'Expert', '4.7', 'Looking for competitive matches', AppColors.warning, false),
                _PlayerData('Priya M.', 'Advanced', '4.1', 'Weekend mornings', AppColors.badminton, true),
                _PlayerData('Rahul D.', 'Beginner', '3.0', 'Learning · Patient partners please', AppColors.textTertiary, false),
              ];
              if (i >= players.length) return null;
              final p = players[i];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Stack(
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: p.color.withValues(alpha: 0.15), child: Text(p.name[0], style: AppTypography.titleSmall.copyWith(color: p.color))),
                      if (p.isOnline) Positioned(right: 0, bottom: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(p.name, style: AppTypography.titleSmall),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(3)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_rounded, size: 10, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(p.rating, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(p.note, style: AppTypography.bodySmall),
                  ])),
                  OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero), child: const Text('Invite')),
                ]),
              );
            },
            childCount: 5,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _PlayerData {
  final String name, level, rating, note;
  final Color color;
  final bool isOnline;
  const _PlayerData(this.name, this.level, this.rating, this.note, this.color, this.isOnline);
}

// ── Tournaments ────────────────────────────────────────────────

class _TournamentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tournaments = <Tournament>[]; // TODO: Fetch from Firestore
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final t = tournaments[index];
        final isOngoing = t.status == 'ongoing';
        final spotsLeft = t.maxParticipants - t.participants;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  (isOngoing ? AppColors.success : AppColors.accent).withValues(alpha: 0.1),
                  Colors.transparent,
                ]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: (isOngoing ? AppColors.success : AppColors.accent).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.emoji_events_rounded, size: 20, color: isOngoing ? AppColors.success : AppColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name, style: AppTypography.titleMedium),
                  Text(t.date, style: AppTypography.bodySmall),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: (isOngoing ? AppColors.success : AppColors.accent).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(isOngoing ? 'Live' : 'Open', style: AppTypography.labelSmall.copyWith(color: isOngoing ? AppColors.success : AppColors.accent)),
                ),
              ]),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Column(children: [
                Row(children: [
                  _TournamentStat(icon: Icons.people_rounded, label: '${t.participants}/${t.maxParticipants}', detail: 'Players'),
                  const SizedBox(width: 16),
                  _TournamentStat(icon: Icons.emoji_events_rounded, label: '₹${t.prizePool.toInt()}', detail: 'Prize'),
                  const SizedBox(width: 16),
                  _TournamentStat(icon: Icons.timer_rounded, label: spotsLeft > 0 ? '$spotsLeft left' : 'Full', detail: 'Spots'),
                ]),
                if (!isOngoing && spotsLeft > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('Register Now'))),
                ],
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _TournamentStat extends StatelessWidget {
  final IconData icon;
  final String label, detail;
  const _TournamentStat({required this.icon, required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Row(children: [
      Icon(icon, size: 14, color: AppColors.textTertiary),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.titleSmall),
        Text(detail, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
      ]),
    ]));
  }
}
