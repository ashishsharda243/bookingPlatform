import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders centered CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('ErrorDisplay', () {
    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorDisplay(message: 'Error')),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: 'No items found'),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'No bookings',
              icon: Icons.calendar_today,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'No halls',
              actionLabel: 'Browse',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Browse'), findsOneWidget);
      await tester.tap(find.text('Browse'));
      expect(tapped, isTrue);
    });

    testWidgets('hides action button when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: 'Empty'),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
