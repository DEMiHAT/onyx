import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';

/// Membership Payment Screen — Plan selection and payment for guests/members.
/// Shows different plans, pricing, and payment options.
class MembershipPaymentScreen extends StatefulWidget {
  const MembershipPaymentScreen({super.key});

  @override
  State<MembershipPaymentScreen> createState() => _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState extends State<MembershipPaymentScreen> {
  int _selectedPlan = 1; // default to quarterly

  final _plans = const [
    _Plan(name: 'Monthly', price: 2499, duration: '1 month', savings: '', features: ['Court access', 'Booking priority', 'Basic analytics']),
    _Plan(name: 'Quarterly', price: 5999, duration: '3 months', savings: 'Save ₹1,498', features: ['Court access', 'Priority booking', 'Full analytics', 'Open play priority', 'Member-only slots']),
    _Plan(name: 'Annual', price: 19999, duration: '12 months', savings: 'Save ₹9,989', features: ['All quarterly benefits', '2 guest passes/month', 'Tournament discounts', 'Coaching discounts', 'Priority support']),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = _plans[_selectedPlan];

    return Scaffold(
      appBar: AppBar(title: Text('Membership Plans', style: AppTypography.titleLarge)),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Plan Cards ─────────────────────────────────────
                const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Choose a Plan', padding: EdgeInsets.fromLTRB(16, 16, 16, 8)),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(3, (i) {
                        final plan = _plans[i];
                        final isSelected = _selectedPlan == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = i),
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accentSubtle : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.border, width: isSelected ? 1.5 : 1),
                              ),
                              child: Column(children: [
                                if (i == 1) Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(3)),
                                  child: Text('Popular', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 9)),
                                ),
                                Text(plan.name, style: AppTypography.titleSmall.copyWith(color: isSelected ? AppColors.accent : AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text('₹${plan.price}', style: AppTypography.headlineSmall.copyWith(color: isSelected ? AppColors.accent : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(plan.duration, style: AppTypography.bodySmall),
                                if (plan.savings.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(plan.savings, style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontSize: 10)),
                                ],
                              ]),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // ── Features ───────────────────────────────────────
                const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Included', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: selected.features.map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                          const SizedBox(width: 10),
                          Text(f, style: AppTypography.bodyLarge),
                        ]),
                      )).toList(),
                    ),
                  ),
                ),

                // ── Payment Methods ────────────────────────────────
                const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Payment Method', padding: EdgeInsets.fromLTRB(16, 20, 16, 8)),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: Column(children: const [
                      _PaymentMethod(icon: Icons.account_balance_rounded, label: 'UPI', detail: 'Google Pay, PhonePe, Paytm', isSelected: true),
                      _PaymentMethod(icon: Icons.credit_card_rounded, label: 'Card', detail: 'Debit / Credit Card'),
                      _PaymentMethod(icon: Icons.account_balance_wallet_rounded, label: 'Net Banking', detail: 'All major banks'),
                      _PaymentMethod(icon: Icons.payments_rounded, label: 'Cash', detail: 'Pay at front desk', isLast: true),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // ── Pay Button ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${selected.name} Plan', style: AppTypography.titleSmall),
                    Text(selected.duration, style: AppTypography.bodySmall),
                  ]),
                  Text('₹${selected.price}', style: AppTypography.headlineMedium),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSuccess(context, selected),
                    child: Text('Pay ₹${selected.price}'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context, _Plan plan) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
          const SizedBox(height: 16),
          Text('Payment Successful!', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('${plan.name} membership activated', style: AppTypography.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('Done'),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _Plan {
  final String name;
  final int price;
  final String duration;
  final String savings;
  final List<String> features;
  const _Plan({required this.name, required this.price, required this.duration, required this.savings, required this.features});
}

class _PaymentMethod extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final bool isSelected;
  final bool isLast;
  const _PaymentMethod({required this.icon, required this.label, required this.detail, this.isSelected = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Icon(icon, size: 20, color: isSelected ? AppColors.accent : AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.titleSmall),
          Text(detail, style: AppTypography.bodySmall),
        ])),
        Icon(isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: 18, color: isSelected ? AppColors.accent : AppColors.textTertiary),
      ]),
    );
  }
}
