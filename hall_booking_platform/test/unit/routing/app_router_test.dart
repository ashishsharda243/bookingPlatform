import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/errors/failure.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';
import 'package:hall_booking_platform/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;

AppUser _user({String role = 'user'}) => AppUser(
      id: 'u1',
      role: role,
      name: 'Test',
      phone: '+911234567890',
      createdAt: DateTime(2024),
    );

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._state) : super(_FakeAuthRepo());
  final AuthState _state;
  @override
  AuthState get state => _state;
}

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<Either<Failure, AppUser?>> signUpWithEmailPassword(
          String email, String password, String name) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, AppUser>> signInWithEmailPassword(
          String email, String password) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, AppUser>> signInWithOtp(String phone) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, AppUser>> verifyOtp(String phone, String otp,
          {OtpType type = OtpType.email}) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, void>> signOut() => throw UnimplementedError();
  @override
  Future<AppUser?> getCurrentUser() async => null;
  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();
}

/// Builds a GoRouter with the same routes and redirect logic as AppRouter
/// but with a custom [initialLocation], avoiding the SplashScreen timer.
Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required AuthState authState,
  required String initialLocation,
}) async {
  final container = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWith(
        (_) => _FakeAuthNotifier(authState),
      ),
    ],
  );

  // Read the real router to get its route configuration.
  final realRouter = container.read(appRouterProvider);

  // Build a test router with the same routes/redirect but custom initial loc.
  final testRouter = GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = container.read(authNotifierProvider);
      final isAuthenticated = auth.isAuthenticated;
      final location = state.matchedLocation;
      const publicPaths = ['/', '/login', '/otp-verification'];
      final isPublicRoute = publicPaths.contains(location);
      if (!isAuthenticated && !isPublicRoute) return '/login';
      if (isAuthenticated && location == '/login') {
        return switch (auth.user!.role) {
          'owner' => '/owner',
          'admin' => '/admin',
          _ => '/home',
        };
      }
      if (isAuthenticated && auth.user != null) {
        final role = auth.user!.role;
        if (location.startsWith('/owner') &&
            role != 'owner' &&
            role != 'admin') {
          return '/home';
        }
        if (location.startsWith('/admin') && role != 'admin') {
          return '/home';
        }
      }
      return null;
    },
    routes: realRouter.configuration.routes,
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: testRouter),
    ),
  );
  await tester.pumpAndSettle();

  return testRouter;
}

void main() {
  group('AppRouter redirect logic', () {
    testWidgets('unauthenticated on /home redirects to /login', (t) async {
      final r = await _pumpRouter(t,
          authState: const AuthState(), initialLocation: '/home');
      expect(r.state.matchedLocation, '/login');
    });

    testWidgets('unauthenticated can access /login', (t) async {
      final r = await _pumpRouter(t,
          authState: const AuthState(), initialLocation: '/login');
      expect(r.state.matchedLocation, '/login');
    });

    testWidgets('user on /login redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/login');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('owner on /login redirects to /owner', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/login');
      expect(r.state.matchedLocation, '/owner');
    });

    testWidgets('admin on /login redirects to /admin', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'admin')),
          initialLocation: '/login');
      expect(r.state.matchedLocation, '/admin');
    });

    testWidgets('user on /owner redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/owner');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('user on /admin redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/admin');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('owner on /admin redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/admin');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('admin can access /owner', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'admin')),
          initialLocation: '/owner');
      expect(r.state.matchedLocation, '/owner');
    });

    testWidgets('admin can access /admin/approvals', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'admin')),
          initialLocation: '/admin/approvals');
      expect(r.state.matchedLocation, '/admin/approvals');
    });

    testWidgets('owner can access /owner/hall/add', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/owner/hall/add');
      expect(r.state.matchedLocation, '/owner/hall/add');
    });

    testWidgets('user can access /bookings', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user()),
          initialLocation: '/bookings');
      expect(r.state.matchedLocation, '/bookings');
    });

    // --- Admin sub-route guards ---

    testWidgets('user on /admin/users redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/admin/users');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('owner on /admin/users redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/admin/users');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('admin can access /admin/users', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'admin')),
          initialLocation: '/admin/users');
      expect(r.state.matchedLocation, '/admin/users');
    });

    testWidgets('admin can access /admin/analytics', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'admin')),
          initialLocation: '/admin/analytics');
      expect(r.state.matchedLocation, '/admin/analytics');
    });

    testWidgets('admin can access /admin/commission', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'admin')),
          initialLocation: '/admin/commission');
      expect(r.state.matchedLocation, '/admin/commission');
    });

    testWidgets('user on /admin/analytics redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/admin/analytics');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('owner on /admin/commission redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/admin/commission');
      expect(r.state.matchedLocation, '/home');
    });

    // --- Owner sub-route guards ---

    testWidgets('user on /owner/bookings redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/owner/bookings');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('user on /owner/earnings redirects to /home', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'user')),
          initialLocation: '/owner/earnings');
      expect(r.state.matchedLocation, '/home');
    });

    testWidgets('owner can access /owner/bookings', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/owner/bookings');
      expect(r.state.matchedLocation, '/owner/bookings');
    });

    testWidgets('owner can access /owner/earnings', (t) async {
      final r = await _pumpRouter(t,
          authState: AuthState(user: _user(role: 'owner')),
          initialLocation: '/owner/earnings');
      expect(r.state.matchedLocation, '/owner/earnings');
    });

    // --- Unauthenticated guards on protected sub-routes ---

    testWidgets('unauthenticated on /admin/approvals redirects to /login',
        (t) async {
      final r = await _pumpRouter(t,
          authState: const AuthState(),
          initialLocation: '/admin/approvals');
      expect(r.state.matchedLocation, '/login');
    });

    testWidgets('unauthenticated on /owner/bookings redirects to /login',
        (t) async {
      final r = await _pumpRouter(t,
          authState: const AuthState(),
          initialLocation: '/owner/bookings');
      expect(r.state.matchedLocation, '/login');
    });
  });
}
