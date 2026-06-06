import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';

/// Walk-In Booking Screen — For staff to register walk-in guests.
/// Used by Coach, Facility Manager, and Admin instead of player booking.
class WalkInBookingScreen extends StatefulWidget {
  const WalkInBookingScreen({super.key});

  @override
  State<WalkInBookingScreen> createState() => _WalkInBookingScreenState();
}

class _WalkInBookingScreenState extends State<WalkInBookingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91 ');
  String _selectedFacility = 'Court 1';
  int _hours = 1;
  final _pricePerHour = {'Court 1': 400, 'Court 2': 400, 'Court 3': 400, 'Cricket Turf': 1500, 'Cricket Nets': 500};
  String _paymentMethod = 'Cash';

  int get _totalPrice => (_pricePerHour[_selectedFacility] ?? 400) * _hours;

  @override
  void dispose() { _nameController.dispose(); _phoneController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Walk-In Booking', style: AppTypography.titleLarge)),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Guest Info ───────────────────────────────────────
                const SliverToBoxAdapter(child: SectionHeader(title: 'Guest Details', padding: EdgeInsets.fromLTRB(16, 16, 16, 8))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      TextField(
                        controller: _nameController,
                        style: AppTypography.bodyLarge,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                          hintText: 'Guest name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTypography.bodyLarge,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone_rounded, size: 18),
                          hintText: 'Phone number',
                        ),
                      ),
                    ]),
                  ),
                ),

                // ── Facility Selection ───────────────────────────────
                const SliverToBoxAdapter(child: SectionHeader(title: 'Facility', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _pricePerHour.keys.map((f) {
                        final isSelected = _selectedFacility == f;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFacility = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                            ),
                            child: Column(children: [
                              Text(f, style: AppTypography.titleSmall.copyWith(color: isSelected ? AppColors.accent : AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('₹${_pricePerHour[f]}/hr', style: AppTypography.bodySmall),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Duration ─────────────────────────────────────────
                const SliverToBoxAdapter(child: SectionHeader(title: 'Duration', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [1, 2, 3, 4].map((h) {
                        final isSelected = _hours == h;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _hours = h),
                            child: Container(
                              margin: EdgeInsets.only(right: h < 4 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accent : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                              ),
                              child: Center(child: Text('$h hr${h > 1 ? 's' : ''}', style: AppTypography.labelMedium.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary))),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Payment ──────────────────────────────────────────
                const SliverToBoxAdapter(child: SectionHeader(title: 'Payment', padding: EdgeInsets.fromLTRB(16, 20, 16, 8))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['Cash', 'UPI', 'Card'].map((m) {
                        final isSelected = _paymentMethod == m;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _paymentMethod = m),
                            child: Container(
                              margin: EdgeInsets.only(right: m != 'Card' ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border),
                              ),
                              child: Center(child: Text(m, style: AppTypography.labelMedium.copyWith(color: isSelected ? AppColors.accent : AppColors.textSecondary))),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // ── Bottom Bar ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$_selectedFacility · $_hours hr${_hours > 1 ? 's' : ''}', style: AppTypography.titleSmall),
                    Text('$_paymentMethod payment', style: AppTypography.bodySmall),
                  ]),
                  Text('₹$_totalPrice', style: AppTypography.headlineMedium),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showConfirmation(context),
                    child: Text('Register Walk-In · ₹$_totalPrice'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    final name = _nameController.text.trim().isEmpty ? 'Walk-in Guest' : _nameController.text.trim();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
          const SizedBox(height: 16),
          Text('Walk-In Registered', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('$name · $_selectedFacility', style: AppTypography.bodyMedium),
          const SizedBox(height: 4),
          Text('$_hours hr${_hours > 1 ? 's' : ''} · ₹$_totalPrice · $_paymentMethod', style: AppTypography.bodySmall),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _nameController.clear(); _phoneController.text = '+91 '; },
            child: const Text('Register Another'),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('Done'),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
