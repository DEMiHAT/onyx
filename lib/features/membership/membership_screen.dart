import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/section_header.dart';
import '../../core/services/auth_service.dart';

/// Membership Screen — Plan display, digital card, QR pass, payment history.
class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final userName = auth.displayName;
    final profile = auth.profile ?? {};
    final isMembershipActive = profile['membershipStatus'] == 'active';
    final membershipType = profile['membershipType'] ?? 'None';

    return Scaffold(
      appBar: AppBar(
        title: Text('Membership', style: AppTypography.titleLarge),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Digital Membership Card ────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.accentSubtle,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ONYX', style: AppTypography.titleLarge.copyWith(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                        ),
                        child: Text(isMembershipActive ? 'ACTIVE' : 'INACTIVE', style: AppTypography.labelSmall.copyWith(
                          color: isMembershipActive ? AppColors.success : AppColors.textSecondary,
                          letterSpacing: 1,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(userName, style: AppTypography.headlineSmall),
                  const SizedBox(height: 4),
                  Text('$membershipType Membership', style: AppTypography.bodySmall),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _CardField(label: 'MEMBER SINCE', value: 'May 2026'),
                      const SizedBox(width: 24),
                      _CardField(label: 'EXPIRES', value: 'Aug 15, 2026'),
                      const SizedBox(width: 24),
                      _CardField(label: 'ID', value: 'ONX-001'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── QR Access Pass ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_rounded, size: 48, color: AppColors.background),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QR Access Pass', style: AppTypography.titleSmall),
                        const SizedBox(height: 4),
                        Text('Show this at the entrance for quick check-in', style: AppTypography.bodySmall),
                        const SizedBox(height: 8),
                        Text('ONX-001-QR-2026', style: AppTypography.mono.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Plan Comparison ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Plans', padding: EdgeInsets.fromLTRB(16, 24, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  _PlanCard(name: 'Monthly', price: '₹3,500', period: '/month', features: ['All facility access', 'Booking priority', 'Community features'], isSelected: false),
                  SizedBox(height: 8),
                  _PlanCard(name: 'Quarterly', price: '₹8,500', period: '/quarter', features: ['All facility access', 'Priority booking', 'Coaching discount 10%', 'Tournament entry discount'], isSelected: true),
                  SizedBox(height: 8),
                  _PlanCard(name: 'Annual', price: '₹28,000', period: '/year', features: ['All facility access', 'Top booking priority', 'Coaching discount 20%', 'Free tournament entries', 'Guest passes (4/month)'], isSelected: false),
                ],
              ),
            ),
          ),

          // ── Payment History ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Payment History', padding: EdgeInsets.fromLTRB(16, 24, 16, 8)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('DESCRIPTION', style: AppTypography.overline)),
                        Expanded(flex: 2, child: Text('AMOUNT', style: AppTypography.overline, textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text('DATE', style: AppTypography.overline, textAlign: TextAlign.right)),
                        SizedBox(width: 56, child: Text('STATUS', style: AppTypography.overline, textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  // Payments list placeholder
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: Text('No recent payments', style: AppTypography.bodySmall)),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── Renewal CTA ────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Renew Membership'),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final String label;
  final String value;
  const _CardField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.overline.copyWith(fontSize: 9)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isSelected;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentSubtle : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(name, style: AppTypography.titleMedium),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('Current', style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontSize: 10)),
                    ),
                  ],
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: AppTypography.headlineSmall),
                  Text(period, style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.check_rounded, size: 14, color: isSelected ? AppColors.accent : AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(f, style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
