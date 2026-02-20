import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/widgets/responsive_layout.dart';

void main() {
  group('ResponsiveBreakpoints', () {
    test('mobile breakpoint is 600', () {
      expect(ResponsiveBreakpoints.mobile, 600);
    });

    test('tablet breakpoint is 1024', () {
      expect(ResponsiveBreakpoints.tablet, 1024);
    });
  });

  group('ResponsiveLayout.deviceTypeForWidth', () {
    test('returns mobile for width < 600', () {
      expect(ResponsiveLayout.deviceTypeForWidth(0), DeviceType.mobile);
      expect(ResponsiveLayout.deviceTypeForWidth(320), DeviceType.mobile);
      expect(ResponsiveLayout.deviceTypeForWidth(599), DeviceType.mobile);
    });

    test('returns tablet for width >= 600 and < 1024', () {
      expect(ResponsiveLayout.deviceTypeForWidth(600), DeviceType.tablet);
      expect(ResponsiveLayout.deviceTypeForWidth(768), DeviceType.tablet);
      expect(ResponsiveLayout.deviceTypeForWidth(1023), DeviceType.tablet);
    });

    test('returns web for width >= 1024', () {
      expect(ResponsiveLayout.deviceTypeForWidth(1024), DeviceType.web);
      expect(ResponsiveLayout.deviceTypeForWidth(1440), DeviceType.web);
      expect(ResponsiveLayout.deviceTypeForWidth(1920), DeviceType.web);
    });
  });

  group('ResponsiveLayout widget', () {
    Widget buildWithSize({
      required double width,
      required Widget Function(BuildContext, BoxConstraints) mobile,
      Widget Function(BuildContext, BoxConstraints)? tablet,
      Widget Function(BuildContext, BoxConstraints)? web,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            height: 800,
            child: ResponsiveLayout(
              mobile: mobile,
              tablet: tablet,
              web: web,
            ),
          ),
        ),
      );
    }

    testWidgets('renders mobile builder for narrow width', (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 400,
          mobile: (_, __) => const Text('mobile'),
          tablet: (_, __) => const Text('tablet'),
          web: (_, __) => const Text('web'),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
      expect(find.text('web'), findsNothing);
    });

    testWidgets('renders tablet builder for medium width', (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 768,
          mobile: (_, __) => const Text('mobile'),
          tablet: (_, __) => const Text('tablet'),
          web: (_, __) => const Text('web'),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
      expect(find.text('web'), findsNothing);
    });

    testWidgets('renders web builder for wide width', (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 1200,
          mobile: (_, __) => const Text('mobile'),
          tablet: (_, __) => const Text('tablet'),
          web: (_, __) => const Text('web'),
        ),
      );

      expect(find.text('web'), findsOneWidget);
      expect(find.text('mobile'), findsNothing);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('falls back to mobile when tablet is null', (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 768,
          mobile: (_, __) => const Text('mobile-fallback'),
        ),
      );

      expect(find.text('mobile-fallback'), findsOneWidget);
    });

    testWidgets('falls back to tablet when web is null', (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 1200,
          mobile: (_, __) => const Text('mobile'),
          tablet: (_, __) => const Text('tablet-fallback'),
        ),
      );

      expect(find.text('tablet-fallback'), findsOneWidget);
    });

    testWidgets('falls back to mobile when both tablet and web are null',
        (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 1200,
          mobile: (_, __) => const Text('mobile-only'),
        ),
      );

      expect(find.text('mobile-only'), findsOneWidget);
    });

    testWidgets('passes constraints to builder', (tester) async {
      double? receivedWidth;

      await tester.pumpWidget(
        buildWithSize(
          width: 400,
          mobile: (_, constraints) {
            receivedWidth = constraints.maxWidth;
            return const SizedBox();
          },
        ),
      );

      expect(receivedWidth, 400);
    });

    testWidgets('uses LayoutBuilder internally', (tester) async {
      await tester.pumpWidget(
        buildWithSize(
          width: 400,
          mobile: (_, __) => const SizedBox(),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });
  });
}
