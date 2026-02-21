import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_theme.dart';
import 'package:hall_booking_platform/routing/app_router.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: .env file not found or failed to load: $e');
  }

  // Initialize Supabase with robust error handling
  try {
    await SupabaseService.initialize();
  } catch (e) {
    const allowDummySupabase = bool.fromEnvironment(
      'ALLOW_DUMMY_SUPABASE',
      defaultValue: false,
    );

    if (allowDummySupabase && !kReleaseMode) {
      debugPrint('Supabase initialization failed: $e');
      debugPrint('ALLOW_DUMMY_SUPABASE enabled; using dummy keys for local UI testing.');
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        anonKey: 'dummy-anon-key',
      );
    } else {
      rethrow;
    }
  }

  runApp(const ProviderScope(child: HallBookingApp()));
}

class HallBookingApp extends ConsumerWidget {
  const HallBookingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Hall Booking',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
