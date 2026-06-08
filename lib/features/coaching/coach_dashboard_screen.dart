import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/models.dart';
import 'manual_attendance_screen.dart';
import 'student_biodata_screen.dart';
import 'coach_announcements_screen.dart';

/// Coach Dashboard Screen — For coaches managing batches and students.
class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Dashboard', style: AppTypography.titleLarge),
        actions: [
          IconButton(icon: const Icon(Icons.campaign_rounded, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachAnnouncementsScreen()))),
          IconButton(icon: const Icon(Icons.add_rounded, size: 22), onPressed: () {}),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Today's Overview ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(child: StatCard(label: 'Batches Today', value: '3', icon: Icons.groups_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Students', value: '30', icon: Icons.people_rounded)),
                  SizedBox(width: 8),
                  Expanded(child: StatCard(label: 'Hours', value: '4.5', icon: Icons.timer_rounded)),
                ],
              ),
            ),
          ),

          // ── Today's Batches ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Today\'s Batches', padding: EdgeInsets.fromLTRB(16, 4, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: (() {
                final batches = <CoachBatch>[]; // TODO: Fetch from Firestore
                return batches.map((batch) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.all(14),
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
                          Row(
                            children: [
                              Text(batch.name, style: AppTypography.titleMedium),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(batch.level, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                              ),
                            ],
                          ),
                          Text(batch.time, style: AppTypography.monoSmall),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text('${batch.studentCount} students', style: AppTypography.bodySmall),
                          const SizedBox(width: 16),
                          Icon(Icons.sports_tennis_rounded, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text('Court 1 & 2', style: AppTypography.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Student avatars
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ...batch.studentNames.take(6).map((name) {
                            return CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.surfaceSecondary,
                              child: Text(name[0], style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textPrimary)),
                            );
                          }),
                          if (batch.studentCount > 6)
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.accentSubtle,
                              child: Text('+${batch.studentCount - 6}', style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.accent)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManualAttendanceScreen(batchName: batch.name, time: batch.time))),
                              child: const Text('Attendance'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoachAnnouncementsScreen())),
                              child: const Text('Announce'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList();
              })(),
            ),
          ),

          // ── Student Performance ────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Student Performance', actionText: 'View All', padding: EdgeInsets.fromLTRB(16, 16, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text('STUDENT', style: AppTypography.overline)),
                    Expanded(flex: 2, child: Text('ATTEND.', style: AppTypography.overline, textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('PROGRESS', style: AppTypography.overline, textAlign: TextAlign.center)),
                  ]),
                ),
                const _StudentRow(name: 'Sriram Kumar', attendance: '92%', progress: 'Excellent'),
                const _StudentRow(name: 'Ananya Desai', attendance: '88%', progress: 'Good'),
                const _StudentRow(name: 'Rohan Iyer', attendance: '95%', progress: 'Excellent'),
                const _StudentRow(name: 'Kavitha Nair', attendance: '76%', progress: 'Needs Work'),
                const _StudentRow(name: 'Aditya Rao', attendance: '85%', progress: 'Good'),
              ]),
            ),
          ),

          // ── Session Cancellation / Leave ──────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Session Management', padding: EdgeInsets.fromLTRB(16, 16, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: Column(children: [
                // Quota bar
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Monthly Cancel Quota', style: AppTypography.titleSmall),
                  Row(children: [
                    Text('1', style: AppTypography.headlineSmall.copyWith(color: AppColors.warning)),
                    Text(' / 3 used', style: AppTypography.bodySmall),
                  ]),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(value: 1 / 3, backgroundColor: AppColors.surfaceSecondary, valueColor: AlwaysStoppedAnimation(AppColors.warning), minHeight: 4),
                ),
                const SizedBox(height: 12),
                // Recent cancellations
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    Icon(Icons.event_busy_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Jun 3 — Advanced A cancelled', style: AppTypography.bodySmall),
                      Text('Reason: Personal emergency · Compensated', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: const Icon(Icons.event_busy_rounded, size: 16),
                    label: const Text('Cancel a Session'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                  ),
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  static void _showCancelDialog(BuildContext context) {
    String reason = 'Personal Emergency';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Cancel Session', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text('This will use 1 of your monthly quota. Students will be notified.', style: AppTypography.bodySmall),
            const SizedBox(height: 16),
            Text('Select Batch', style: AppTypography.labelMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['Advanced A', 'Intermediate B', 'Beginners C'].map((b) => ChoiceChip(
              label: Text(b),
              selected: b == 'Advanced A',
              onSelected: (_) {},
            )).toList()),
            const SizedBox(height: 16),
            Text('Reason', style: AppTypography.labelMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: ['Personal Emergency', 'Illness', 'Weather', 'Facility Issue', 'Other'].map((r) {
              final isSelected = reason == r;
              return GestureDetector(
                onTap: () => setSheetState(() => reason = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                  ),
                  child: Text(r, style: AppTypography.labelMedium.copyWith(color: isSelected ? AppColors.accent : AppColors.textSecondary)),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session cancelled — $reason'), backgroundColor: AppColors.warning));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Confirm Cancellation'),
            )),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String name;
  final String attendance;
  final String progress;

  const _StudentRow({required this.name, required this.attendance, required this.progress});

  Color get _progressColor => switch (progress) {
    'Excellent' => AppColors.success,
    'Good' => AppColors.accent,
    'Needs Work' => AppColors.warning,
    _ => AppColors.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentBiodataScreen(studentName: name))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.surfaceSecondary,
                    child: Text(name[0], style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textPrimary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(name, style: AppTypography.bodyLarge, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(attendance, style: AppTypography.mono, textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(progress, style: AppTypography.labelSmall.copyWith(color: _progressColor, fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
