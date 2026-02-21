import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/utils/page_transitions.dart';

void main() {
  group('PageTransitions', () {
    test('defaultDuration is 300ms', () {
      expect(
        PageTransitions.defaultDuration,
        const Duration(milliseconds: 300),
      );
    });

    group('fade', () {
      test('returns CustomTransitionPage with correct key and child', () {
        const key = ValueKey('fade-test');
        const child = Text('Fade Page');

        final page = PageTransitions.fade(key: key, child: child);

        expect(page, isA<CustomTransitionPage>());
        expect(page.key, key);
        expect(page.child, child);
        expect(page.transitionDuration, PageTransitions.defaultDuration);
      });

      test('accepts custom duration', () {
        const key = ValueKey('fade-custom');
        const duration = Duration(milliseconds: 500);

        final page = PageTransitions.fade(
          key: key,
          child: const SizedBox(),
          duration: duration,
        );

        expect(page.transitionDuration, duration);
      });
    });

    group('slideRight', () {
      test('returns CustomTransitionPage with correct key and child', () {
        const key = ValueKey('slide-right-test');
        const child = Text('Slide Right');

        final page = PageTransitions.slideRight(key: key, child: child);

        expect(page, isA<CustomTransitionPage>());
        expect(page.key, key);
        expect(page.child, child);
        expect(page.transitionDuration, PageTransitions.defaultDuration);
      });
    });

    group('slideUp', () {
      test('returns CustomTransitionPage with correct key and child', () {
        const key = ValueKey('slide-up-test');
        const child = Text('Slide Up');

        final page = PageTransitions.slideUp(key: key, child: child);

        expect(page, isA<CustomTransitionPage>());
        expect(page.key, key);
        expect(page.child, child);
        expect(page.transitionDuration, PageTransitions.defaultDuration);
      });
    });
  });
}
