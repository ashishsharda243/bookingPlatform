import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transition utilities for GoRouter.
///
/// Provides reusable [CustomTransitionPage] builders for consistent
/// navigation animations across the app.
///
/// Requirement 19.5: Smooth page transitions and animations.
class PageTransitions {
  PageTransitions._();

  /// Default transition duration used across the app.
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// Creates a fade transition page for GoRouter.
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Creates a slide-from-right transition page for GoRouter.
  static CustomTransitionPage<T> slideRight<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  /// Creates a slide-from-bottom transition page for GoRouter.
  static CustomTransitionPage<T> slideUp<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }
}
