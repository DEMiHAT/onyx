/// ONYX Booking Service — Firestore reads for bookings & facilities.
///
/// Replaces all mock data with live Firestore streams and queries.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

class BookingService {
  BookingService._();
  static final instance = BookingService._();

  final _db = FirebaseFirestore.instance;

  // ── Facilities (real-time) ────────────────────────────────────

  Stream<List<Facility>> getFacilities() {
    return _db.collection('facilities').snapshots().map((snap) =>
      snap.docs.map((d) => Facility.fromFirestore(d.data(), d.id)).toList(),
    );
  }

  Stream<List<Facility>> getFacilitiesByType(FacilityType type) {
    final typeStr = switch (type) {
      FacilityType.badmintonCourt => 'badmintonCourt',
      FacilityType.cricketTurf => 'cricketTurf',
      FacilityType.cricketNets => 'cricketNets',
    };
    return _db.collection('facilities')
      .where('type', isEqualTo: typeStr)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Facility.fromFirestore(d.data(), d.id)).toList());
  }

  // ── User Bookings (real-time) ─────────────────────────────────

  Stream<List<Booking>> getUserBookings(String userId) {
    return _db.collection('bookings')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Booking.fromFirestore(d.data(), d.id)).toList());
  }

  // ── Available Slots ───────────────────────────────────────────

  /// Returns time slots for a facility+date with live availability.
  /// Generates all operating-hour slots, then marks booked ones unavailable.
  Future<List<TimeSlot>> getAvailableSlots({
    required String facilityId,
    required String date,
    String? courtNumber,
  }) async {
    // Get pricing config
    final configSnap = await _db.collection('config').doc('pricing').get();
    final config = configSnap.data() ?? {};
    final pricing = config['pricing'] ?? {};
    final peakHours = config['peakHours'] ?? {};
    final peakStart = int.tryParse((peakHours['start'] ?? '16:00').split(':')[0]) ?? 16;
    final peakEnd = int.tryParse((peakHours['end'] ?? '21:00').split(':')[0]) ?? 21;
    final opHours = config['operatingHours'] ?? {};
    final opStart = int.tryParse((opHours['start'] ?? '06:00').split(':')[0]) ?? 6;
    final opEnd = int.tryParse((opHours['end'] ?? '22:00').split(':')[0]) ?? 22;

    // Determine pricing tier
    Map<String, dynamic> priceTier = {};
    if (facilityId.startsWith('court')) {
      priceTier = Map<String, dynamic>.from(pricing['badmintonCourt'] ?? {});
    } else if (facilityId == 'turf') {
      priceTier = Map<String, dynamic>.from(pricing['cricketTurf'] ?? {});
    } else {
      priceTier = Map<String, dynamic>.from(pricing['cricketNets'] ?? {});
    }
    final offPeak = (priceTier['offPeak'] ?? 400).toDouble();
    final peak = (priceTier['peak'] ?? 600).toDouble();

    // Query existing bookings for this facility + date
    Query query = _db.collection('bookings')
      .where('facilityId', isEqualTo: facilityId)
      .where('date', isEqualTo: date)
      .where('status', whereIn: ['upcoming', 'active']);

    if (courtNumber != null) {
      query = query.where('courtNumber', isEqualTo: courtNumber);
    }

    final bookedSnap = await query.get();
    final bookedHours = <int>{};
    for (final doc in bookedSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final start = int.tryParse((data['startTime'] ?? '').split(':')[0]) ?? 0;
      final end = int.tryParse((data['endTime'] ?? '').split(':')[0]) ?? 0;
      for (int h = start; h < end; h++) {
        bookedHours.add(h);
      }
    }

    // Generate slots
    final slots = <TimeSlot>[];
    for (int h = opStart; h < opEnd; h++) {
      final isPeak = h >= peakStart && h < peakEnd;
      final price = isPeak ? peak : offPeak;
      final timeStr = '${h.toString().padLeft(2, '0')}:00';
      slots.add(TimeSlot(
        time: timeStr,
        isAvailable: !bookedHours.contains(h),
        price: price,
        isPeak: isPeak,
      ));
    }
    return slots;
  }

  // ── Pricing Config ────────────────────────────────────────────

  Future<Map<String, dynamic>> getPricingConfig() async {
    final snap = await _db.collection('config').doc('pricing').get();
    return snap.data() ?? {};
  }
}
