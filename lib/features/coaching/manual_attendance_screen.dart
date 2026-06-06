import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Manual Attendance Screen — Coach marks attendance per student per session.
class ManualAttendanceScreen extends StatefulWidget {
  final String batchName;
  final String time;
  const ManualAttendanceScreen({super.key, required this.batchName, required this.time});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final List<_StudentEntry> _students = [
    _StudentEntry(name: 'Sriram Kumar', age: 17, level: 'Advanced'),
    _StudentEntry(name: 'Ananya Desai', age: 15, level: 'Advanced'),
    _StudentEntry(name: 'Rohan Iyer', age: 16, level: 'Advanced'),
    _StudentEntry(name: 'Kavitha Nair', age: 14, level: 'Intermediate'),
    _StudentEntry(name: 'Aditya Rao', age: 18, level: 'Advanced'),
    _StudentEntry(name: 'Priya Menon', age: 15, level: 'Advanced'),
    _StudentEntry(name: 'Vikram Singh', age: 16, level: 'Intermediate'),
    _StudentEntry(name: 'Deepa Lakshmi', age: 14, level: 'Advanced'),
    _StudentEntry(name: 'Rahul Sharma', age: 17, level: 'Advanced'),
    _StudentEntry(name: 'Meera Das', age: 15, level: 'Intermediate'),
    _StudentEntry(name: 'Arjun Patel', age: 16, level: 'Advanced'),
    _StudentEntry(name: 'Sneha Reddy', age: 14, level: 'Advanced'),
  ];

  int get _presentCount => _students.where((s) => s.status == _AttendanceStatus.present).length;
  int get _absentCount => _students.where((s) => s.status == _AttendanceStatus.absent).length;
  int get _unmarkedCount => _students.where((s) => s.status == _AttendanceStatus.unmarked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance', style: AppTypography.titleLarge),
        actions: [
          TextButton(onPressed: _unmarkedCount == 0 ? () => _submitAttendance(context) : null, child: Text('Save', style: TextStyle(color: _unmarkedCount == 0 ? AppColors.accent : AppColors.textDisabled))),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Session info ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            color: AppColors.surface,
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.groups_rounded, size: 20, color: AppColors.accent)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.batchName, style: AppTypography.titleMedium),
                Text('${widget.time} · ${_students.length} students', style: AppTypography.bodySmall),
              ])),
            ]),
          ),

          // ── Summary bar ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              _CountChip(label: 'Present', count: _presentCount, color: AppColors.success),
              const SizedBox(width: 8),
              _CountChip(label: 'Absent', count: _absentCount, color: AppColors.error),
              const SizedBox(width: 8),
              _CountChip(label: 'Unmarked', count: _unmarkedCount, color: AppColors.textTertiary),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() { for (final s in _students) { s.status = _AttendanceStatus.present; } }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('All Present', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                ),
              ),
            ]),
          ),

          // ── Student list ───────────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final s = _students[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: s.status == _AttendanceStatus.present ? AppColors.success.withValues(alpha: 0.15) : s.status == _AttendanceStatus.absent ? AppColors.error.withValues(alpha: 0.15) : AppColors.surfaceSecondary,
                      child: Text(s.name[0], style: AppTypography.titleSmall.copyWith(
                        color: s.status == _AttendanceStatus.present ? AppColors.success : s.status == _AttendanceStatus.absent ? AppColors.error : AppColors.textSecondary,
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: AppTypography.titleSmall),
                      Text('Age ${s.age} · ${s.level}', style: AppTypography.bodySmall),
                    ])),
                    // Present / Absent toggle
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      GestureDetector(
                        onTap: () => setState(() => s.status = _AttendanceStatus.present),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: s.status == _AttendanceStatus.present ? AppColors.success : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                            border: Border.all(color: s.status == _AttendanceStatus.present ? AppColors.success : AppColors.border),
                          ),
                          child: Icon(Icons.check_rounded, size: 18, color: s.status == _AttendanceStatus.present ? Colors.white : AppColors.textTertiary),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => s.status = _AttendanceStatus.absent),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: s.status == _AttendanceStatus.absent ? AppColors.error : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                            border: Border.all(color: s.status == _AttendanceStatus.absent ? AppColors.error : AppColors.border),
                          ),
                          child: Icon(Icons.close_rounded, size: 18, color: s.status == _AttendanceStatus.absent ? Colors.white : AppColors.textTertiary),
                        ),
                      ),
                    ]),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitAttendance(BuildContext context) {
    showModalBottomSheet(context: context, builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
        const SizedBox(height: 16),
        Text('Attendance Saved', style: AppTypography.headlineMedium),
        const SizedBox(height: 8),
        Text('${widget.batchName} · $_presentCount present, $_absentCount absent', style: AppTypography.bodyMedium),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Done'))),
        const SizedBox(height: 8),
      ]),
    ));
  }
}

enum _AttendanceStatus { unmarked, present, absent }

class _StudentEntry {
  final String name;
  final int age;
  final String level;
  _AttendanceStatus status = _AttendanceStatus.unmarked;
  _StudentEntry({required this.name, required this.age, required this.level});
}

class _CountChip extends StatelessWidget {
  final String label; final int count; final Color color;
  const _CountChip({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text('$count', style: AppTypography.labelSmall.copyWith(color: color)),
    ]),
  );
}
