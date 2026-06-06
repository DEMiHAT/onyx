import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/mock_data.dart';
import '../../models/models.dart';
import 'court_booking_screen.dart';
import 'turf_booking_screen.dart';
import 'nets_booking_screen.dart';

/// Bookings Screen — Upcoming, Past, and Cancelled bookings.
/// The + button opens a facility chooser to start a new booking.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNewBooking() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('New Booking', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text('Choose a facility to book', style: AppTypography.bodySmall),
            const SizedBox(height: 16),
            _BookingOption(
              icon: Icons.sports_tennis_rounded,
              color: AppColors.badminton,
              title: 'Badminton Court',
              subtitle: '3 courts · ₹300–500/hr',
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const CourtBookingScreen())); },
            ),
            const SizedBox(height: 8),
            _BookingOption(
              icon: Icons.sports_cricket_rounded,
              color: AppColors.cricketTurf,
              title: 'Cricket Turf',
              subtitle: '1 turf · ₹1200–1800/hr',
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const TurfBookingScreen())); },
            ),
            const SizedBox(height: 8),
            _BookingOption(
              icon: Icons.sports_baseball_rounded,
              color: AppColors.cricketNets,
              title: 'Cricket Nets',
              subtitle: '1 area · ₹400–600/hr',
              onTap: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const NetsBookingScreen())); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: _showNewBooking,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(bookings: MockData.bookings.where((b) => b.status == BookingStatus.upcoming).toList()),
          _BookingList(bookings: MockData.bookings.where((b) => b.status == BookingStatus.completed).toList()),
          _BookingList(bookings: MockData.bookings.where((b) => b.status == BookingStatus.cancelled).toList()),
        ],
      ),
    );
  }
}

class _BookingOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _BookingOption({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.titleSmall),
            Text(subtitle, style: AppTypography.bodySmall),
          ])),
          Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 40, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text('No bookings', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _facilityColor(booking.facilityType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_facilityIcon(booking.facilityType), size: 20, color: _facilityColor(booking.facilityType)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(booking.facilityName, style: AppTypography.titleSmall),
                        _StatusBadge(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.access_time_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text('${booking.date} · ${booking.timeSlot} · ${booking.durationMinutes}min', style: AppTypography.bodySmall),
                    ]),
                    if (booking.amount != null) ...[
                      const SizedBox(height: 4),
                      Text('₹${booking.amount!.toInt()}', style: AppTypography.mono.copyWith(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _facilityIcon(FacilityType type) => switch (type) {
    FacilityType.badmintonCourt => Icons.sports_tennis_rounded,
    FacilityType.cricketTurf => Icons.sports_cricket_rounded,
    FacilityType.cricketNets => Icons.sports_baseball_rounded,
  };

  Color _facilityColor(FacilityType type) => switch (type) {
    FacilityType.badmintonCourt => AppColors.badminton,
    FacilityType.cricketTurf => AppColors.cricketTurf,
    FacilityType.cricketNets => AppColors.cricketNets,
  };
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.upcoming => ('Upcoming', AppColors.accent),
      BookingStatus.active => ('Active', AppColors.success),
      BookingStatus.completed => ('Completed', AppColors.textTertiary),
      BookingStatus.cancelled => ('Cancelled', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
    );
  }
}
