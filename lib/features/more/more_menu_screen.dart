import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu', style: AppTextStyles.headlineSm)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuSection(
            title: 'MASTER DATA',
            items: [
              _MenuItem(
                icon: Icons.payments_outlined,
                title: 'Payments & Collections',
                subtitle: 'Manage received and outstanding payments',
                onTap: () => context.push('/payments'),
              ),
              _MenuItem(
                icon: Icons.analytics_outlined,
                title: 'Purchase Orders & Stock',
                subtitle: 'Company-wise PO tracking & allocation',
                onTap: () => context.push('/po-dashboard'),
              ),
              _MenuItem(
                icon: Icons.business,
                title: 'Companies & Clients',
                subtitle: 'Manage buyers and GST details',
                onTap: () => context.push('/companies'),
              ),
              _MenuItem(
                icon: Icons.inventory_2,
                title: 'Products & Services',
                subtitle: 'Manage inventory and HSN codes',
                onTap: () => context.push('/products'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            title: 'SETTINGS & COMPLIANCE',
            items: [
              _MenuItem(
                icon: Icons.settings,
                title: 'App Settings',
                subtitle: 'Seller profile, tax rates, logo',
                onTap: () => context.push('/settings'),
              ),
              _MenuItem(
                icon: Icons.backup,
                title: 'Backup & Restore',
                subtitle: 'Google Drive sync configuration',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            title: 'ACCOUNT',
            items: [
              _MenuItem(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'admin@arunmensware.com',
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(
                  item.icon,
                  color: item.iconColor ?? AppColors.onSurfaceVariant,
                ),
                title: Text(
                  item.title,
                  style: AppTextStyles.labelLg.copyWith(
                    color: item.textColor ?? AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                ),
                onTap: item.onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(index == 0 ? 16 : 0),
                    bottom: Radius.circular(index == items.length - 1 ? 16 : 0),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });
}
