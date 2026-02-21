import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/widgets/scaffold_with_navbar.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/core/utils/page_transitions.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';
import 'package:hall_booking_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:hall_booking_platform/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:hall_booking_platform/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:hall_booking_platform/features/auth/presentation/screens/splash_screen.dart';
import 'package:hall_booking_platform/features/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:hall_booking_platform/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:hall_booking_platform/features/booking/presentation/screens/booking_history_screen.dart';
import 'package:hall_booking_platform/features/booking/presentation/screens/booking_success_screen.dart';
import 'package:hall_booking_platform/features/booking/presentation/screens/slot_selection_screen.dart';
import 'package:hall_booking_platform/features/discovery/presentation/screens/hall_detail_screen.dart';
import 'package:hall_booking_platform/features/discovery/presentation/screens/home_screen.dart';
import 'package:hall_booking_platform/features/discovery/presentation/screens/location_picker_screen.dart';
import 'package:hall_booking_platform/features/payment/presentation/screens/payment_screen.dart';
import 'package:hall_booking_platform/features/owner/presentation/screens/add_edit_hall_screen.dart';
import 'package:hall_booking_platform/features/owner/presentation/screens/availability_calendar_screen.dart';
import 'package:hall_booking_platform/features/owner/presentation/screens/owner_bookings_screen.dart';
import 'package:hall_booking_platform/features/owner/presentation/screens/earnings_report_screen.dart';
import 'package:hall_booking_platform/features/owner/presentation/screens/owner_dashboard_screen.dart';
import 'package:hall_booking_platform/features/admin/approval/presentation/screens/hall_approval_screen.dart';
import 'package:hall_booking_platform/features/admin/users/presentation/screens/user_management_screen.dart';
import 'package:hall_booking_platform/features/admin/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:hall_booking_platform/features/admin/commission/presentation/screens/commission_management_screen.dart';
import 'package:hall_booking_platform/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:hall_booking_platform/features/profile/presentation/screens/profile_screen.dart';

/// Application router with role-based route guards.
///
/// Redirect logic:
/// - Unauthenticated users are sent to `/login` (except splash & OTP).
/// - Authenticated users on `/login` are redirected to their role-appropriate home.
/// - Users accessing `/owner/*` or `/admin/*` without the matching role
///   are redirected to `/home`.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(Ref ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => _guard(ref, state),
      routes: [
        // --- Public / Auth routes (fade transitions) ---
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => PageTransitions.fade(
            key: state.pageKey,
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => PageTransitions.fade(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/otp-verification',
          pageBuilder: (context, state) {
            String email = '';
            bool isSignUp = false;
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              email = extra['email'] as String? ?? '';
              isSignUp = extra['isSignUp'] as bool? ?? false;
            } else if (extra is String) {
              email = extra;
            }
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: OtpVerificationScreen(email: email, isSignUp: isSignUp),
            );
          },
        ),

        // --- User routes (slide transitions for drill-down) ---
        // --- Shell Route for Bottom Navigation ---
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            // Tab 1: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            // Tab 2: Bookings
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/bookings',
                  builder: (context, state) => const BookingHistoryScreen(),
                ),
              ],
            ),
            // Tab 3: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
            // Tab 4: Owner Dashboard (My Halls)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/owner',
                  builder: (context, state) => const OwnerDashboardScreen(),
                ),
              ],
            ),
          ],
        ),

        // --- Detail routes (hide bottom nav) ---
        GoRoute(
          path: '/hall/:id',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final hallId = state.pathParameters['id']!;
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: HallDetailScreen(hallId: hallId),
            );
          },
        ),
        GoRoute(
          path: '/hall/:id/slots',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final hallId = state.pathParameters['id']!;
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: SlotSelectionScreen(hallId: hallId),
            );
          },
        ),
        GoRoute(
          path: '/booking/confirm',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final params = state.extra as BookingConfirmationParams;
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: BookingConfirmationScreen(params: params),
            );
          },
        ),
        GoRoute(
          path: '/booking/payment',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final params = state.extra as PaymentScreenParams;
            return PageTransitions.slideUp(
              key: state.pageKey,
              child: PaymentScreen(params: params),
            );
          },
        ),
        GoRoute(
          path: '/booking/success',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => PageTransitions.slideUp(
            key: state.pageKey,
            child: const BookingSuccessScreen(),
          ),
        ),
        GoRoute(
          path: '/bookings/:id',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final bookingId = state.pathParameters['id']!;
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: BookingDetailScreen(bookingId: bookingId),
            );
          },
        ),
        GoRoute(
          path: '/location-picker',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, double>;
            return PageTransitions.slideUp(
              key: state.pageKey,
              child: LocationPickerScreen(
                initialLat: extra['lat']!,
                initialLng: extra['lng']!,
              ),
            );
          },
        ),

        // --- Owner routes (Sub-pages of Owner Dashboard) ---
        // Note: /owner itself is now in the shell, so we remove the top-level /owner route.
        // We keep the sub-routes here so they cover the bottom nav.
        GoRoute(
          path: '/owner/hall/add',
          pageBuilder: (context, state) => PageTransitions.slideUp(
            key: state.pageKey,
            child: const AddEditHallScreen(),
          ),
        ),
        GoRoute(
          path: '/owner/hall/:id/edit',
          pageBuilder: (context, state) {
            final hallId = state.pathParameters['id']!;
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: AddEditHallScreen(hallId: hallId),
            );
          },
        ),
        GoRoute(
          path: '/owner/hall/:id/availability',
          pageBuilder: (context, state) {
            final hallId = state.pathParameters['id']!;
            return PageTransitions.slideRight(
              key: state.pageKey,
              child: AvailabilityCalendarScreen(hallId: hallId),
            );
          },
        ),
        GoRoute(
          path: '/owner/bookings',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const OwnerBookingsScreen(),
          ),
        ),
        GoRoute(
          path: '/owner/earnings',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const EarningsReportScreen(),
          ),
        ),

        // --- Admin routes ---
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => PageTransitions.fade(
            key: state.pageKey,
            child: const AdminDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/approvals',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const HallApprovalScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/users',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const UserManagementScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/analytics',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const AnalyticsDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/admin/commission',
          pageBuilder: (context, state) => PageTransitions.slideRight(
            key: state.pageKey,
            child: const CommissionManagementScreen(),
          ),
        ),
      ],
    );
  }

  /// Central redirect logic enforcing authentication and role-based access.
  static String? _guard(Ref ref, GoRouterState state) {
    final authState = ref.read(authNotifierProvider);
    final isAuthenticated = authState.isAuthenticated;
    final location = state.matchedLocation;

    // Allow splash and OTP screens without auth.
    const publicPaths = ['/', '/login', '/signup', '/otp-verification'];
    final isPublicRoute = publicPaths.contains(location);

    // --- Unauthenticated guard ---
    if (!isAuthenticated && !isPublicRoute) {
      // Check feature toggle for public access
      if (AppConstants.enablePublicAccess) {
        // Allow home, hall details, slots, AND tab roots (profile, bookings)
        // This lets us show a "Login Required" UI inside the tabs instead of redirecting
        if (location == '/home' || 
            location == '/profile' ||
            location == '/bookings' ||
            location == '/location-picker' ||
            location.startsWith('/hall/') || 
            location.startsWith('/hall-')) {
          return null;
        }
        
        // If user tries to access root, redirect to home instead of login
        if (location == '/') {
          return '/home';
        }
      }
      
      return '/login';
    }

    // --- Authenticated on login → redirect to role home ---
    if (isAuthenticated && location == '/login') {
      return _homeForRole(authState.user!.role);
    }

    // --- Role-based guards ---
    if (isAuthenticated && authState.user != null) {
      final role = authState.user!.role;

      // Owner routes require 'owner' or 'admin' role.
      if (location.startsWith('/owner') && role != 'owner' && role != 'admin') {
        return '/home';
      }

      // Admin routes require 'admin' role.
      if (location.startsWith('/admin') && role != 'admin') {
        return '/home';
      }
    }

    return null; // no redirect
  }

  /// Returns the home route for a given user role.
  static String _homeForRole(String role) {
    return switch (role) {
      'owner' => '/owner',
      'admin' => '/admin',
      _ => '/home',
    };
  }
}

/// Riverpod provider for the GoRouter instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router(ref);
});
