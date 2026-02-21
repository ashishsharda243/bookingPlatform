import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/utils/cache_utils.dart';

/// A simple counter to track how many times a provider body executes.
int _fetchCount = 0;

final _cachedProvider = FutureProvider.autoDispose<int>((ref) async {
  applyCacheTtl(ref, ttl: const Duration(milliseconds: 200));
  _fetchCount++;
  return _fetchCount;
});

void main() {
  setUp(() {
    _fetchCount = 0;
  });

  group('applyCacheTtl', () {
    test('keeps provider alive after listener is removed within TTL', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // First read triggers the fetch.
      final sub = container.listen(_cachedProvider.future, (_, __) {});
      final firstValue = await container.read(_cachedProvider.future);
      expect(firstValue, 1);
      expect(_fetchCount, 1);

      // Remove listener — TTL timer starts.
      sub.close();

      // Re-subscribe before TTL expires (200ms). Should reuse cached value.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final sub2 = container.listen(_cachedProvider.future, (_, __) {});
      final secondValue = await container.read(_cachedProvider.future);
      expect(secondValue, 1, reason: 'Should reuse cached value within TTL');
      expect(_fetchCount, 1, reason: 'No additional fetch within TTL');

      sub2.close();
    });

    test('disposes provider after TTL expires and re-fetches', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(_cachedProvider.future, (_, __) {});
      await container.read(_cachedProvider.future);
      expect(_fetchCount, 1);

      // Remove listener and wait for TTL to expire.
      sub.close();
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Re-subscribe — should trigger a new fetch.
      final sub2 = container.listen(_cachedProvider.future, (_, __) {});
      final newValue = await container.read(_cachedProvider.future);
      expect(newValue, 2, reason: 'Should re-fetch after TTL expiry');
      expect(_fetchCount, 2);

      sub2.close();
    });

    test('cancels TTL timer when listener re-subscribes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sub = container.listen(_cachedProvider.future, (_, __) {});
      await container.read(_cachedProvider.future);
      expect(_fetchCount, 1);

      // Remove listener — TTL timer starts.
      sub.close();

      // Wait 100ms (half of TTL), then re-subscribe.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final sub2 = container.listen(_cachedProvider.future, (_, __) {});

      // Wait another 150ms — past original TTL but timer was cancelled.
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final value = await container.read(_cachedProvider.future);
      expect(value, 1, reason: 'Timer was cancelled, cache still valid');
      expect(_fetchCount, 1);

      sub2.close();
    });
  });
}
