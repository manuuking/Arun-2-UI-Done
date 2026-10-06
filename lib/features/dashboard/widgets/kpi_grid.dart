import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/providers.dart';

class KpiGrid extends ConsumerWidget {
  const KpiGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return invoicesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox(),
      data: (invoices) {
        // Exclude rejected invoices from revenue totals
        final activeInvoices = invoices
            .where((i) => i.status != 'rejected')
            .toList();
        final totalCount = activeInvoices.length;
        final totalRevenue = activeInvoices.fold(
          0.0,
          (sum, i) => sum + i.grandTotal,
        );

        final paidInvoices = activeInvoices
            .where((i) => i.status == 'paid')
            .toList();
        final paidAmount = paidInvoices.fold(
          0.0,
          (sum, i) => sum + i.grandTotal,
        );

        final pendingInvoices = activeInvoices
            .where((i) => i.status == 'pending')
            .toList();
        final pendingAmount = pendingInvoices.fold(
          0.0,
          (sum, i) => sum + (i.grandTotal - i.paidAmount),
        );

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: [
            _buildKpiCard(
              title: 'Total Invoices',
              icon: Icons.receipt_long,
              value: '$totalCount',
              subtext: 'Active invoices',
              color: AppColors.onSurfaceVariant,
              valueColor: AppColors.onSurface,
              bgAccent: AppColors.surfaceContainer,
            ),
            _buildKpiCard(
              title: 'Total Amount',
              icon: Icons.account_balance_wallet_outlined,
              value: '₹${CurrencyFormatter.formatNumber(totalRevenue)}',
              subtext: 'Financial Year total',
              color: AppColors.primary,
              valueColor: AppColors.primary,
              bgAccent: AppColors.primaryContainer,
            ),
            _buildKpiCard(
              title: 'Paid',
              icon: Icons.check_circle_outline,
              value: '₹${CurrencyFormatter.formatNumber(paidAmount)}',
              subtext: '${paidInvoices.length} invoices cleared',
              color: AppColors.onTertiaryContainer,
              valueColor: AppColors.onTertiaryContainer,
              bgAccent: AppColors.tertiaryFixed,
            ),
            _buildKpiCard(
              title: 'Pending',
              icon: Icons.schedule,
              value: '₹${CurrencyFormatter.formatNumber(pendingAmount)}',
              subtext: '${pendingInvoices.length} invoices pending',
              color: AppColors.secondary,
              valueColor: AppColors.secondary,
              bgAccent: AppColors.secondaryFixed,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required IconData icon,
    required String value,
    required String subtext,
    required Color color,
    required Color valueColor,
    required Color bgAccent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgAccent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Icon(icon, size: 16, color: color),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: valueColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
