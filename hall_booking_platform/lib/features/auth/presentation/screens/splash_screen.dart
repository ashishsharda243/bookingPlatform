import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';

/// Splash screen shown on app launch.
/// Checks auth state and redirects to login or home accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String routePath = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Brief delay for splash branding visibility.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState.isAuthenticated) {
      _navigateToHome();
    } else {
      if (AppConstants.enablePublicAccess) {
        if (!mounted) return;
        context.go('/home');
      } else {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    if (!mounted) return;
    context.go('/login');
  }

  void _navigateToHome() {
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    final role = authState.user?.role ?? 'user';
    switch (role) {
      case 'owner':
        context.go('/owner');
      case 'admin':
        context.go('/admin');
      default:
        context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Hall Booking',
              style: AppTypography.headlineLarge.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find & book venues near you',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
