import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/widgets/shimmer_loading.dart';

void main() {
  group('ShimmerLoading', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              child: SizedBox(width: 100, height: 20),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('uses AnimationController for shimmer effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              child: SizedBox(width: 100, height: 20),
            ),
          ),
        ),
      );

      // Pump a few frames to verify animation runs without errors
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              child: SizedBox(width: 100, height: 20),
            ),
          ),
        ),
      );

      // Remove the widget — should not throw
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    });
  });

  group('ShimmerListPlaceholder', () {
    testWidgets('renders default 3 placeholder items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListPlaceholder(),
          ),
        ),
      );

      // Should find 3 ShimmerLoading widgets (one per item)
      expect(find.byType(ShimmerLoading), findsNWidgets(3));
    });

    testWidgets('renders custom item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListPlaceholder(itemCount: 5),
          ),
        ),
      );

      expect(find.byType(ShimmerLoading), findsNWidgets(5));
    });

    testWidgets('uses NeverScrollableScrollPhysics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerListPlaceholder(),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    });
  });

  group('ShimmerDetailPlaceholder', () {
    testWidgets('renders image and text placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerDetailPlaceholder(),
          ),
        ),
      );

      // Should have multiple ShimmerLoading widgets (image + text block)
      expect(find.byType(ShimmerLoading), findsAtLeastNWidgets(2));
    });

    testWidgets('uses NeverScrollableScrollPhysics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerDetailPlaceholder(),
          ),
        ),
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.physics, isA<NeverScrollableScrollPhysics>());
    });
  });
}
