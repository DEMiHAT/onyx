import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/booking_service.dart';
import '../../models/models.dart';
import '../facility/facility_detail_screen.dart';
import '../bookings/court_booking_screen.dart';
import '../bookings/turf_booking_screen.dart';
import '../bookings/nets_booking_screen.dart';
import '../bookings/booking_qr_screen.dart';
import '../notifications/notifications_screen.dart';
import '../membership/membership_payment_screen.dart';

/// Guest Home — Firestore-driven, with active session QR card.
class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final userName = auth.displayName.split(' ').first;
    final userId = auth.uid;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(children: [
              Image.asset('assets/images/onyx_logo.png', width: 28, height: 28),
              const SizedBox(width: 8),
              Text('ONYX', style: AppTypography.titleLarge.copyWith(letterSpacing: 2, fontWeight: FontWeight.w700)),
            ]),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none_rounded, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
              const SizedBox(width: 4),
            ],
          ),

          // ── Greeting ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hey $userName 👋', style: AppTypography.headlineMedium),
                const SizedBox(height: 2),
                // Live facility count
                StreamBuilder<List<Facility>>(
                  stream: BookingService.instance.getFacilities(),
                  builder: (ctx, snap) {
                    final count = snap.data?.where((f) => f.status == FacilityStatus.available).length ?? 0;
                    return Text('$count facilities available right now', style: AppTypography.bodySmall);
                  },
                ),
              ]),
            ),
          ),

          // ── Active Session QR Card ─────────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: userId)
                  .where('status', whereIn: ['active', 'upcoming'])
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox.shrink();

                final doc = snap.data!.docs.first;
                final booking = Booking.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

                if (booking.checkInToken == null) return const SizedBox.shrink();

                final isActive = booking.status == BookingStatus.active;
                final statusColor = isActive ? AppColors.success : AppColors.accent;
                final statusLabel = isActive ? 'Active Now' : 'Upcoming';

                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BookingQRScreen(
                      bookingId: booking.id,
                      checkInToken: booking.checkInToken!,
                      facilityName: booking.facilityName,
                      date: booking.date,
                      timeSlot: booking.timeSlot,
                      amount: booking.amount ?? 0,
                      courtNumber: booking.courtNumber,
                    ),
                  )),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)]),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.qr_code_rounded, size: 22, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(statusLabel, style: AppTypography.labelSmall.copyWith(color: statusColor, fontSize: 10)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(booking.facilityName, style: AppTypography.titleSmall, overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 4),
                        Text('${booking.date} · ${booking.timeSlot}', style: AppTypography.bodySmall),
                      ])),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: statusColor),
                    ]),
                  ),
                );
              },
            ),
          ),

          // ── Book Now Cards ─────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Book Now', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _BookCard(title: 'Badminton', subtitle: '3 Courts', price: 'From ₹400/hr', icon: Icons.sports_tennis_rounded, color: AppColors.badminton, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourtBookingScreen()))),
                  _BookCard(title: 'Cricket Turf', subtitle: '1 Turf', price: 'From ₹1000/hr', icon: Icons.sports_cricket_rounded, color: AppColors.cricketTurf, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurfBookingScreen()))),
                  _BookCard(title: 'Cricket Nets', subtitle: '3 Lanes', price: 'From ₹400/hr', icon: Icons.sports_baseball_rounded, color: AppColors.cricketNets, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetsBookingScreen()))),
                ],
              ),
            ),
          ),

          // ── Membership CTA ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPaymentScreen())),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.card_membership_rounded, size: 20, color: AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Become a Member', style: AppTypography.titleSmall.copyWith(color: AppColors.accent)),
                    Text('Unlock priority slots, discounts & more', style: AppTypography.bodySmall),
                  ])),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accent),
                ]),
              ),
            ),
          ),

          // ── Live Facility Board (Firestore) ────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Live Status', padding: EdgeInsets.fromLTRB(16, 20, 16, 6))),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Facility>>(
              stream: BookingService.instance.getFacilities(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.accent)));
                }
                final facilities = snap.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: Column(
                    children: facilities.asMap().entries.map((entry) {
                      final f = entry.value;
                      final isLast = entry.key == facilities.length - 1;
                      final isAvail = f.status == FacilityStatus.available;
                      return InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FacilityDetailScreen(facility: f))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
                          child: Row(children: [
                            Icon(f.type == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : f.type == FacilityType.cricketTurf ? Icons.sports_cricket_rounded : Icons.sports_baseball_rounded, size: 16, color: AppColors.textTertiary),
                            const SizedBox(width: 8),
                            Expanded(flex: 3, child: Text(f.shortName, style: AppTypography.titleSmall)),
                            Expanded(flex: 2, child: StatusChip(status: f.status, compact: true)),
                            SizedBox(width: 60, child: Text(isAvail ? 'Book' : f.status == FacilityStatus.maintenance ? 'Closed' : '${f.timeRemainingMinutes ?? '?'}m', style: AppTypography.bodySmall.copyWith(color: isAvail ? AppColors.success : AppColors.textSecondary), textAlign: TextAlign.right)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          // ── Quick Actions ──────────────────────────────────
          const SliverToBoxAdapter(child: SectionHeader(title: 'Quick Actions', padding: EdgeInsets.fromLTRB(16, 20, 16, 6))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _QuickAction(icon: Icons.sports_tennis_rounded, label: 'Court', color: AppColors.badminton, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourtBookingScreen()))),
                const SizedBox(width: 8),
                _QuickAction(icon: Icons.sports_cricket_rounded, label: 'Turf', color: AppColors.cricketTurf, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurfBookingScreen()))),
                const SizedBox(width: 8),
                _QuickAction(icon: Icons.sports_baseball_rounded, label: 'Nets', color: AppColors.cricketNets, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetsBookingScreen()))),
              ]),
            ),
          ),

          // ── Upcoming Bookings (Firestore) ──────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: userId)
                  .where('status', whereIn: ['upcoming', 'active'])
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snap) {
                final upcoming = snap.data?.docs.map((d) => Booking.fromFirestore(d.data() as Map<String, dynamic>, d.id)).toList() ?? [];
                if (upcoming.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('UPCOMING', style: AppTypography.overline),
                      Text('No upcoming bookings', style: AppTypography.bodySmall),
                    ]),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('UPCOMING', style: AppTypography.overline),
                        Text('${upcoming.length} booking${upcoming.length > 1 ? 's' : ''}', style: AppTypography.bodySmall),
                      ]),
                    ),
                    ...upcoming.map((b) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(6)), child: Icon(b.facilityType == FacilityType.badmintonCourt ? Icons.sports_tennis_rounded : b.facilityType == FacilityType.cricketTurf ? Icons.sports_cricket_rounded : Icons.sports_baseball_rounded, size: 18, color: AppColors.accent)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b.facilityName, style: AppTypography.titleSmall),
                          const SizedBox(height: 2),
                          Text('${b.date} · ${b.timeSlot}', style: AppTypography.bodySmall),
                        ])),
                        if (b.checkInToken != null)
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingQRScreen(
                              bookingId: b.id, checkInToken: b.checkInToken!,
                              facilityName: b.facilityName, date: b.date,
                              timeSlot: b.timeSlot, amount: b.amount ?? 0, courtNumber: b.courtNumber,
                            ))),
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Icon(Icons.qr_code_rounded, size: 16, color: AppColors.accent),
                            ),
                          )
                        else if (b.amount != null)
                          Text('₹${b.amount!.toInt()}', style: AppTypography.mono.copyWith(color: AppColors.textSecondary)),
                      ]),
                    )),
                  ],
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title, subtitle, price;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _BookCard({required this.title, required this.subtitle, required this.price, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: color)),
          const Spacer(),
          Text(title, style: AppTypography.titleSmall),
          Text(subtitle, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(price, style: AppTypography.labelSmall.copyWith(color: AppColors.accent)),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
      child: Column(children: [Icon(icon, size: 20, color: color), const SizedBox(height: 6), Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary))]),
    )));
  }
}
