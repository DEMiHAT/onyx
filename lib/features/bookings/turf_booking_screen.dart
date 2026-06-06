import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../models/models.dart';

/// Cricket Turf Booking Screen — Multi-hour selection with pricing.
class TurfBookingScreen extends StatefulWidget {
  const TurfBookingScreen({super.key});

  @override
  State<TurfBookingScreen> createState() => _TurfBookingScreenState();
}

class _TurfBookingScreenState extends State<TurfBookingScreen> {
  int _selectedDateIndex = 0;
  final Set<int> _selectedSlots = {};

  final List<String> _dates = ['Today', 'Tomorrow', 'Jun 8', 'Jun 9', 'Jun 10'];

  final List<TimeSlot> _slots = const [
    TimeSlot(time: '06:00', isAvailable: true, price: 1000),
    TimeSlot(time: '07:00', isAvailable: false, price: 1200, isPeak: true),
    TimeSlot(time: '08:00', isAvailable: true, price: 1200, isPeak: true),
    TimeSlot(time: '09:00', isAvailable: true, price: 1000),
    TimeSlot(time: '10:00', isAvailable: true, price: 1000),
    TimeSlot(time: '16:00', isAvailable: true, price: 1200, isPeak: true),
    TimeSlot(time: '17:00', isAvailable: true, price: 1500, isPeak: true),
    TimeSlot(time: '18:00', isAvailable: false, price: 1500, isPeak: true),
    TimeSlot(time: '19:00', isAvailable: true, price: 1500, isPeak: true),
    TimeSlot(time: '20:00', isAvailable: true, price: 1200),
    TimeSlot(time: '21:00', isAvailable: true, price: 1000),
  ];

  double get _totalPrice => _selectedSlots.fold(0.0, (sum, i) => sum + (_slots[i].price ?? 0));
  int get _totalHours => _selectedSlots.length;

  String get _timeRange {
    if (_selectedSlots.isEmpty) return '';
    final sorted = _selectedSlots.toList()..sort();
    final first = _slots[sorted.first].time;
    final lastHour = int.parse(_slots[sorted.last].time.split(':')[0]) + 1;
    return '$first – ${lastHour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Cricket Turf', style: AppTypography.titleLarge)),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Turf Info ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      Icon(Icons.sports_cricket_rounded, size: 20, color: AppColors.cricketTurf),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Cricket Turf', style: AppTypography.titleSmall),
                        const SizedBox(height: 2),
                        Text('Full-size synthetic turf pitch', style: AppTypography.bodySmall),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('Available', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                      ),
                    ]),
                  ),
                ),

                // ── Date Selection ───────────────────────────────
                const SliverToBoxAdapter(child: SectionHeader(title: 'Date', padding: EdgeInsets.fromLTRB(16, 4, 16, 8))),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _dates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() { _selectedDateIndex = index; _selectedSlots.clear(); }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent : AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                            ),
                            child: Center(child: Text(_dates[index], style: AppTypography.labelMedium.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary))),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Info ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text('Select multiple slots for multi-hour booking', style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
                    ]),
                  ),
                ),

                // ── Time Slots ───────────────────────────────────
                const SliverToBoxAdapter(child: SectionHeader(title: 'Available Slots', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                      child: Row(children: [
                        Expanded(flex: 2, child: Text('TIME', style: AppTypography.overline)),
                        Expanded(flex: 2, child: Text('PRICE/HR', style: AppTypography.overline, textAlign: TextAlign.center)),
                        Expanded(flex: 1, child: Text('TYPE', style: AppTypography.overline, textAlign: TextAlign.center)),
                        const SizedBox(width: 50),
                      ]),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final slot = _slots[index];
                      final isSelected = _selectedSlots.contains(index);
                      return GestureDetector(
                        onTap: slot.isAvailable ? () => setState(() => _selectedSlots.contains(index) ? _selectedSlots.remove(index) : _selectedSlots.add(index)) : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentSubtle : !slot.isAvailable ? AppColors.background : Colors.transparent,
                            border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                          ),
                          child: Row(children: [
                            Expanded(flex: 2, child: Text(slot.time, style: AppTypography.mono.copyWith(color: slot.isAvailable ? AppColors.textPrimary : AppColors.textDisabled))),
                            Expanded(flex: 2, child: Text('₹${slot.price?.toInt() ?? 0}', style: AppTypography.mono.copyWith(color: slot.isAvailable ? AppColors.textSecondary : AppColors.textDisabled), textAlign: TextAlign.center)),
                            Expanded(flex: 1, child: slot.isPeak ? Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppColors.warningMuted, borderRadius: BorderRadius.circular(3)), child: Text('Peak', style: AppTypography.labelSmall.copyWith(color: AppColors.warning, fontSize: 9), textAlign: TextAlign.center)) : const SizedBox()),
                            SizedBox(width: 50, child: slot.isAvailable ? Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 18, color: isSelected ? AppColors.accent : AppColors.textTertiary) : Text('Booked', style: AppTypography.labelSmall.copyWith(color: AppColors.textDisabled), textAlign: TextAlign.right)),
                          ]),
                        ),
                      );
                    },
                    childCount: _slots.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          if (_selectedSlots.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
              child: SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Cricket Turf · ${_dates[_selectedDateIndex]}', style: AppTypography.titleSmall),
                      const SizedBox(height: 2),
                      Text('$_timeRange · $_totalHours hr${_totalHours > 1 ? 's' : ''}', style: AppTypography.bodySmall),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('₹${_totalPrice.toInt()}', style: AppTypography.headlineMedium),
                      if (_totalHours > 1) Text('₹${(_totalPrice / _totalHours).toInt()}/hr', style: AppTypography.bodySmall),
                    ]),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Confirm · $_totalHours hr${_totalHours > 1 ? 's' : ''} · ₹${_totalPrice.toInt()}'),
                  )),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
