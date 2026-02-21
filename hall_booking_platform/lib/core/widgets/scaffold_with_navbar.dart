import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isOwnerOrAdmin = user?.role == 'owner' || user?.role == 'admin';

    // Define all possible destinations matching the ShellBranches in AppRouter
    // 0: Home, 1: Bookings, 2: Profile, 3: Owner Dashboard
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: AppColors.primary),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),
        label: 'Bookings',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: AppColors.primary),
        label: 'Profile',
      ),
      if (isOwnerOrAdmin)
        const NavigationDestination(
          icon: Icon(Icons.store_outlined),
          selectedIcon: Icon(Icons.store, color: AppColors.primary),
          label: 'My Halls',
        ),
    ];

    // Safety check: if current index is out of bounds (e.g. user lost owner role while on tab 3),
    // redirect or just clamp (though clamping won't navigate). 
    // NavigationBar throws if selectedIndex >= destinations.length.
    final effectiveIndex = navigationShell.currentIndex >= destinations.length
        ? 0 // Fallback to Home if we are on a hidden tab
        : navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: effectiveIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: destinations,
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
