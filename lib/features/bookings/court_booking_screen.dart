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

/// Court Booking Screen — Live Firestore data for courts and slots.
class CourtBookingScreen extends StatefulWidget {
  const CourtBookingScreen({super.key});

  @override
  State<CourtBookingScreen> createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingScreen> {
  int _selectedCourt = 0;
  int _selectedDateIndex = 0;
  final Set<int> _selectedSlots = {};

  List<Facility> _courts = [];
  List<TimeSlot> _slots = [];
  bool _loadingSlots = false;
  bool _loadingCourts = true;

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
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    try {
      final stream = BookingService.instance.getFacilitiesByType(FacilityType.badmintonCourt);
      stream.listen((facilities) {
        if (mounted) {
          setState(() { _courts = facilities; _loadingCourts = false; });
          _loadSlots();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCourts = false);
        OnyxToast.error(context, e);
      }
    }
  }

  Future<void> _loadSlots() async {
    if (_courts.isEmpty) return;
    setState(() => _loadingSlots = true);
    try {
      final courtId = _courts[_selectedCourt].id;
      final date = _dateForQuery(_selectedDateIndex);
      final slots = await BookingService.instance.getAvailableSlots(
        facilityId: courtId, date: date,
      );
      if (mounted) setState(() { _slots = slots; _loadingSlots = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSlots = false);
        OnyxToast.error(context, e);
      }
    }
  }

  double get _totalPrice {
    double total = 0;
    for (final i in _selectedSlots) {
      if (i < _slots.length) total += _slots[i].price ?? 0;
    }
    return total;
  }

  int get _totalHours => _selectedSlots.length;

  String get _timeRange {
    if (_selectedSlots.isEmpty || _slots.isEmpty) return '';
    final sorted = _selectedSlots.toList()..sort();
    final first = _slots[sorted.first].time;
    final lastIdx = sorted.last;
    final lastTime = _slots[lastIdx].time;
    final parts = lastTime.split(':');
    final endHour = (int.parse(parts[0]) + 1).toString().padLeft(2, '0');
    return '$first – $endHour:00';
  }

  void _toggleSlot(int index) {
    setState(() {
      if (_selectedSlots.contains(index)) {
        _selectedSlots.remove(index);
      } else {
        _selectedSlots.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courtName = _courts.isNotEmpty ? _courts[_selectedCourt].shortName : 'Court';

    return Scaffold(
      appBar: AppBar(title: Text('Book Badminton Court', style: AppTypography.titleLarge)),
      body: _loadingCourts
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // ── Court Selection ──────────────────────────────
                      const SliverToBoxAdapter(child: SectionHeader(title: 'Select Court', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: List.generate(_courts.length, (index) {
                              final isSelected = _selectedCourt == index;
                              final facility = _courts[index];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () { setState(() { _selectedCourt = index; _selectedSlots.clear(); }); _loadSlots(); },
                                  child: Container(
                                    margin: EdgeInsets.only(right: index < _courts.length - 1 ? 8 : 0),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                                    ),
                                    child: Column(children: [
                                      Text(facility.shortName, style: AppTypography.titleSmall.copyWith(color: isSelected ? AppColors.accent : AppColors.textPrimary)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: facility.status == FacilityStatus.available ? AppColors.success.withValues(alpha: 0.1) : AppColors.warningMuted,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          facility.status == FacilityStatus.available ? 'Open' : facility.status == FacilityStatus.maintenance ? 'Maintenance' : 'In Use',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: facility.status == FacilityStatus.available ? AppColors.success : facility.status == FacilityStatus.maintenance ? AppColors.error : AppColors.warning,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      // ── Date Selection ───────────────────────────────
                      const SliverToBoxAdapter(child: SectionHeader(title: 'Select Date', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
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

                      // ── Info Banner ──────────────────────────────────
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)),
                          child: Row(children: [
                            Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text('Tap multiple slots to book consecutive hours', style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
                          ]),
                        ),
                      ),

                      // ── Time Slot Grid ──────────────────────────────
                      const SliverToBoxAdapter(child: SectionHeader(title: 'Available Slots', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),

                      if (_loadingSlots)
                        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: AppColors.accent))))
                      else if (_slots.isEmpty)
                        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('No slots available', style: AppTypography.bodyMedium))))
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
                                onTap: slot.isAvailable ? () => _toggleSlot(index) : null,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.accentSubtle : !slot.isAvailable ? AppColors.background : Colors.transparent,
                                    border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                                  ),
                                  child: Row(children: [
                                    Expanded(flex: 2, child: Text(slot.time, style: AppTypography.mono.copyWith(color: slot.isAvailable ? AppColors.textPrimary : AppColors.textDisabled))),
                                    Expanded(flex: 2, child: Text(slot.price != null ? '₹${slot.price!.toInt()}' : '—', style: AppTypography.mono.copyWith(color: slot.isAvailable ? AppColors.textSecondary : AppColors.textDisabled), textAlign: TextAlign.center)),
                                    Expanded(flex: 1, child: slot.isPeak ? Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppColors.warningMuted, borderRadius: BorderRadius.circular(3)), child: Text('Peak', style: AppTypography.labelSmall.copyWith(color: AppColors.warning, fontSize: 9), textAlign: TextAlign.center)) : const SizedBox()),
                                    SizedBox(width: 50, child: slot.isAvailable ? isSelected ? Icon(Icons.check_circle_rounded, size: 18, color: AppColors.accent) : Icon(Icons.radio_button_unchecked_rounded, size: 18, color: AppColors.textTertiary) : Text('Booked', style: AppTypography.labelSmall.copyWith(color: AppColors.textDisabled), textAlign: TextAlign.right)),
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

                // ── Booking Summary Bar ────────────────────────────────
                if (_selectedSlots.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
                    child: SafeArea(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('$courtName · ${_dates[_selectedDateIndex]}', style: AppTypography.titleSmall),
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
                          onPressed: () => _showConfirmation(context),
                          child: Text('Confirm · $_totalHours hr${_totalHours > 1 ? 's' : ''} · ₹${_totalPrice.toInt()}'),
                        )),
                      ]),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showConfirmation(BuildContext context) {
    final courtName = _courts.isNotEmpty ? _courts[_selectedCourt].shortName : 'Court';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Confirm Booking', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('Review your booking details', style: AppTypography.bodyMedium),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              _ConfirmRow(label: 'Facility', value: courtName),
              _ConfirmRow(label: 'Date', value: _dates[_selectedDateIndex]),
              _ConfirmRow(label: 'Time', value: _timeRange),
              _ConfirmRow(label: 'Duration', value: '$_totalHours hour${_totalHours > 1 ? 's' : ''}'),
              const Divider(color: AppColors.border, height: 16),
              _ConfirmRow(label: 'Total', value: '₹${_totalPrice.toInt()}'),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _processPayment(context); },
            child: Text('Pay ₹${_totalPrice.toInt()}'),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    final sorted = _selectedSlots.toList()..sort();
    final startTime = _slots[sorted.first].time;
    final lastTime = _slots[sorted.last].time;
    final parts = lastTime.split(':');
    final endHour = (int.parse(parts[0]) + 1).toString().padLeft(2, '0');
    final endTime = '$endHour:00';
    final checkInToken = const Uuid().v4();
    final courtId = _courts[_selectedCourt].id;
    final courtName = _courts[_selectedCourt].shortName;
    final date = _dateForQuery(_selectedDateIndex);

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)));

      final result = await FirebaseFunctions.instance.httpsCallable('createBooking').call({
        'facilityId': courtId, 'date': date,
        'startTime': startTime, 'endTime': endTime,
        'courtNumber': courtName,
        'amount': _totalPrice, 'paymentMode': 'online', 'checkInToken': checkInToken,
      });
      final bookingId = (result.data as Map<String, dynamic>)['bookingId'] ?? '';

      if (!mounted) return;
      Navigator.pop(context);

      PaymentService.instance.initiatePayment(
        bookingId: bookingId,
        amountInPaise: (_totalPrice * 100).toInt(),
        description: '$startTime — $endTime · ${_dates[_selectedDateIndex]}',
        facilityName: 'Badminton $courtName',
        onSuccess: (bid, paymentId) {
          if (!mounted) return;
          OnyxToast.success(context, 'Payment successful! Show this QR at the desk');
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => BookingQRScreen(
              bookingId: bookingId, checkInToken: checkInToken,
              facilityName: 'Badminton $courtName', date: _dates[_selectedDateIndex],
              timeSlot: _timeRange, amount: _totalPrice, courtNumber: courtName,
            ),
          ));
        },
        onFailure: (error) {
          if (!mounted) return;
          OnyxToast.error(context, error);
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      OnyxToast.error(context, e);
    }
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
    );
  }
}
