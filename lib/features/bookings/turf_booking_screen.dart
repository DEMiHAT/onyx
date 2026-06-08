import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/onyx_toast.dart';
import '../../core/services/booking_service.dart';
import '../../core/services/payment_service.dart';
import '../../models/models.dart';
import 'booking_qr_screen.dart';

/// Cricket Turf Booking Screen — Live Firestore slots.
class TurfBookingScreen extends StatefulWidget {
  const TurfBookingScreen({super.key});

  @override
  State<TurfBookingScreen> createState() => _TurfBookingScreenState();
}

class _TurfBookingScreenState extends State<TurfBookingScreen> {
  int _selectedDateIndex = 0;
  final Set<int> _selectedSlots = {};

  List<TimeSlot> _slots = [];
  bool _loadingSlots = true;
  Facility? _turf;

  final List<String> _dates = _generateDates();

  static List<String> _generateDates() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      if (i == 0) return 'Today';
      if (i == 1) return 'Tomorrow';
      return '${d.day}/${d.month}/${d.year}';
    });
  }

  String _dateForQuery(int index) {
    final now = DateTime.now();
    final d = now.add(Duration(days: index));
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  void initState() {
    super.initState();
    _loadFacility();
  }

  Future<void> _loadFacility() async {
    BookingService.instance.getFacilitiesByType(FacilityType.cricketTurf).listen((list) {
      if (mounted && list.isNotEmpty) {
        setState(() => _turf = list.first);
      }
    });
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _loadingSlots = true);
    try {
      final slots = await BookingService.instance.getAvailableSlots(
        facilityId: 'turf', date: _dateForQuery(_selectedDateIndex),
      );
      if (mounted) setState(() { _slots = slots; _loadingSlots = false; });
    } catch (e) {
      if (mounted) { setState(() => _loadingSlots = false); OnyxToast.error(context, e); }
    }
  }

  double get _totalPrice => _selectedSlots.fold(0.0, (sum, i) => sum + (_slots[i].price ?? 0));
  int get _totalHours => _selectedSlots.length;

  String get _timeRange {
    if (_selectedSlots.isEmpty || _slots.isEmpty) return '';
    final sorted = _selectedSlots.toList()..sort();
    final first = _slots[sorted.first].time;
    final lastHour = int.parse(_slots[sorted.last].time.split(':')[0]) + 1;
    return '$first – ${lastHour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _turf?.status == FacilityStatus.available ? 'Available' :
                        _turf?.status == FacilityStatus.maintenance ? 'Maintenance' : 'In Use';
    final statusColor = _turf?.status == FacilityStatus.available ? AppColors.success :
                        _turf?.status == FacilityStatus.maintenance ? AppColors.error : AppColors.warning;

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
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(statusText, style: AppTypography.labelSmall.copyWith(color: statusColor)),
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
                          onTap: () { setState(() { _selectedDateIndex = index; _selectedSlots.clear(); }); _loadSlots(); },
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

                if (_loadingSlots)
                  const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: AppColors.accent))))
                else ...[
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
                ],
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
                    onPressed: () => _processPayment(context),
                    child: Text('Pay ₹${_totalPrice.toInt()}'),
                  )),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    final sorted = _selectedSlots.toList()..sort();
    final startTime = _slots[sorted.first].time;
    final lastHour = int.parse(_slots[sorted.last].time.split(':')[0]) + 1;
    final endTime = '${lastHour.toString().padLeft(2, '0')}:00';
    final checkInToken = const Uuid().v4();
    final date = _dateForQuery(_selectedDateIndex);

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)));

      final result = await FirebaseFunctions.instance.httpsCallable('createBooking').call({
        'facilityId': 'turf', 'date': date,
        'startTime': startTime, 'endTime': endTime,
        'amount': _totalPrice, 'paymentMode': 'online', 'checkInToken': checkInToken,
      });
      final bookingId = (result.data as Map<String, dynamic>)['bookingId'] ?? '';
      if (!mounted) return;
      Navigator.pop(context);

      PaymentService.instance.initiatePayment(
        bookingId: bookingId, amountInPaise: (_totalPrice * 100).toInt(),
        description: '$startTime — $endTime', facilityName: 'Cricket Turf',
        onSuccess: (bid, pid) {
          if (!mounted) return;
          OnyxToast.success(context, 'Payment successful! Show this QR at the desk');
          Navigator.push(context, MaterialPageRoute(builder: (_) => BookingQRScreen(
            bookingId: bookingId, checkInToken: checkInToken,
            facilityName: 'Cricket Turf', date: _dates[_selectedDateIndex],
            timeSlot: _timeRange, amount: _totalPrice,
          )));
        },
        onFailure: (e) { if (mounted) OnyxToast.error(context, e); },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      OnyxToast.error(context, e);
    }
  }
}
