import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';

/// Admin dashboard screen with navigation cards to all admin features.
///
/// Provides quick access to:
/// - Hall Approvals
/// - User Management
/// - Analytics Dashboard
/// - Commission Management
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _sections = [
    _AdminSection(
      title: 'Hall Approvals',
      subtitle: 'Review and approve pending hall listings',
      icon: Icons.check_circle_outline,
      color: AppColors.warning,
      route: '/admin/approvals',
    ),
    _AdminSection(
      title: 'User Management',
      subtitle: 'Manage users, roles, and account status',
      icon: Icons.people_outline,
      color: AppColors.info,
      route: '/admin/users',
    ),
    _AdminSection(
      title: 'Analytics',
      subtitle: 'View platform performance and metrics',
      icon: Icons.bar_chart_outlined,
      color: AppColors.success,
      route: '/admin/analytics',
    ),
    _AdminSection(
      title: 'Commission',
      subtitle: 'Configure platform commission rates',
      icon: Icons.percent_outlined,
      color: AppColors.primary,
      route: '/admin/commission',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView.separated(
        padding: AppSpacing.screenPadding,
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return _AdminNavigationCard(section: section);
        },
      ),
    );
  }
}

/// Data class for an admin dashboard navigation section.
class _AdminSection {
  const _AdminSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}

/// Card widget for navigating to an admin feature section.
class _AdminNavigationCard extends StatelessWidget {
  const _AdminNavigationCard({required this.section});

  final _AdminSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () => context.push(section.route),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(section.icon, color: section.color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: AppTypography.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(section.subtitle, style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
