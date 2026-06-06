import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Coach Announcements — Send nudges and announcements to students.
class CoachAnnouncementsScreen extends StatefulWidget {
  const CoachAnnouncementsScreen({super.key});

  @override
  State<CoachAnnouncementsScreen> createState() => _CoachAnnouncementsScreenState();
}

class _CoachAnnouncementsScreenState extends State<CoachAnnouncementsScreen> {
  final List<_Announcement> _announcements = [
    _Announcement(title: 'Session Rescheduled', body: 'Tomorrow\'s Advanced A batch moved from 6:00 AM to 7:00 AM due to court maintenance.', type: _AnnType.session, time: '2h ago', batch: 'Advanced A'),
    _Announcement(title: 'Tournament Prep', body: 'All advanced students — extra practice sessions this Saturday 4-6 PM. Attendance strongly recommended.', type: _AnnType.general, time: '1d ago', batch: 'All Batches'),
    _Announcement(title: 'Great Progress! 🎉', body: 'The team showed excellent improvement in footwork drills this week. Keep up the intensity!', type: _AnnType.nudge, time: '2d ago', batch: 'Advanced A'),
    _Announcement(title: 'Session Cancelled', body: 'Thursday Intermediate B session cancelled due to facility maintenance. Will be compensated next week.', type: _AnnType.session, time: '3d ago', batch: 'Intermediate B'),
    _Announcement(title: 'Fee Reminder', body: 'June coaching fees are due by Jun 10. Please ensure timely payment to avoid session interruption.', type: _AnnType.general, time: '4d ago', batch: 'All Batches'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements', style: AppTypography.titleLarge),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, size: 22), onPressed: () => _showComposeSheet(context)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Quick nudge buttons ─────────────────────────────
          Row(children: [
            _NudgeButton(icon: Icons.schedule_rounded, label: 'Session Update', onTap: () => _showComposeSheet(context, preset: 'session')),
            const SizedBox(width: 8),
            _NudgeButton(icon: Icons.campaign_rounded, label: 'Announcement', onTap: () => _showComposeSheet(context, preset: 'general')),
            const SizedBox(width: 8),
            _NudgeButton(icon: Icons.thumb_up_rounded, label: 'Encourage', onTap: () => _showComposeSheet(context, preset: 'nudge')),
          ]),
          const SizedBox(height: 20),

          Text('RECENT', style: AppTypography.overline),
          const SizedBox(height: 8),

          ..._announcements.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: a.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(a.icon, size: 16, color: a.color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.title, style: AppTypography.titleSmall),
                  Text('${a.batch} · ${a.time}', style: AppTypography.labelSmall),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                  child: Text(a.typeLabel, style: AppTypography.labelSmall.copyWith(color: a.color, fontSize: 9)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(a.body, style: AppTypography.bodyMedium),
            ]),
          )),
        ],
      ),
    );
  }

  void _showComposeSheet(BuildContext context, {String preset = 'general'}) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String selectedBatch = 'All Batches';
    String selectedType = preset;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('New Announcement', style: AppTypography.headlineSmall),
          const SizedBox(height: 16),

          // Type
          Text('Type', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['session', 'general', 'nudge'].map((t) {
            final isSelected = selectedType == t;
            return GestureDetector(
              onTap: () => setSheetState(() => selectedType = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                ),
                child: Text(t == 'session' ? 'Session' : t == 'general' ? 'General' : 'Nudge', style: AppTypography.labelMedium.copyWith(color: isSelected ? AppColors.accent : AppColors.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          // Batch
          Text('Target Batch', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['All Batches', 'Advanced A', 'Intermediate B', 'Beginners C'].map((b) {
            final isSelected = selectedBatch == b;
            return GestureDetector(
              onTap: () => setSheetState(() => selectedBatch = b),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                ),
                child: Text(b, style: AppTypography.labelMedium.copyWith(color: isSelected ? AppColors.accent : AppColors.textSecondary)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          TextField(controller: titleCtrl, style: AppTypography.bodyLarge, decoration: const InputDecoration(hintText: 'Title')),
          const SizedBox(height: 10),
          TextField(controller: bodyCtrl, style: AppTypography.bodyLarge, maxLines: 3, decoration: const InputDecoration(hintText: 'Message')),
          const SizedBox(height: 20),

          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
                setState(() {
                  _announcements.insert(0, _Announcement(
                    title: titleCtrl.text, body: bodyCtrl.text,
                    type: selectedType == 'session' ? _AnnType.session : selectedType == 'nudge' ? _AnnType.nudge : _AnnType.general,
                    time: 'Just now', batch: selectedBatch,
                  ));
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement sent to students')));
              }
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send to Students'),
          )),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }
}

enum _AnnType { session, general, nudge }

class _Announcement {
  final String title, body, time, batch;
  final _AnnType type;
  _Announcement({required this.title, required this.body, required this.type, required this.time, required this.batch});

  IconData get icon => switch (type) { _AnnType.session => Icons.schedule_rounded, _AnnType.general => Icons.campaign_rounded, _AnnType.nudge => Icons.thumb_up_rounded };
  Color get color => switch (type) { _AnnType.session => AppColors.warning, _AnnType.general => AppColors.accent, _AnnType.nudge => AppColors.success };
  String get typeLabel => switch (type) { _AnnType.session => 'Session', _AnnType.general => 'General', _AnnType.nudge => 'Nudge' };
}

class _NudgeButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _NudgeButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
    child: Column(children: [Icon(icon, size: 20, color: AppColors.accent), const SizedBox(height: 6), Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center)]),
  )));
}
