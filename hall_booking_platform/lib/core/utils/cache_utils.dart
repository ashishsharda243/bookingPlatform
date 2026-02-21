import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';

/// Applies a time-based cache policy to a Riverpod [AutoDisposeRef].
///
/// Keeps the provider alive for [ttl] (defaults to 5 minutes per
/// Requirement 18.3). After the TTL expires the provider is disposed on
/// next opportunity, forcing a fresh fetch on the next read.
///
/// Usage inside a provider:
/// ```dart
/// final myProvider = FutureProvider.autoDispose<Data>((ref) async {
///   applyCacheTtl(ref);
///   return fetchData();
/// });
/// ```
void applyCacheTtl(
  Ref ref, {
  Duration ttl = const Duration(minutes: AppConstants.cacheTtlMinutes),
}) {
  final link = ref.keepAlive();

  Timer? timer;

  ref.onDispose(() {
    timer?.cancel();
  });

  ref.onCancel(() {
    // When all listeners are gone, start the TTL countdown.
    timer = Timer(ttl, () {
      link.close();
    });
  });

  ref.onResume(() {
    // If a listener re-subscribes before TTL expires, cancel the timer.
    timer?.cancel();
  });
}
