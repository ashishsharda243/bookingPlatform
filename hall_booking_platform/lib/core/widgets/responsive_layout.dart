import 'package:flutter/material.dart';

/// Responsive breakpoints for the application.
///
/// - Mobile: width < 600
/// - Tablet: 600 <= width < 1024
/// - Web/Desktop: width >= 1024
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Determines the current device type based on screen width.
enum DeviceType { mobile, tablet, web }

/// A responsive layout widget that adapts its child based on screen width
/// using [LayoutBuilder].
///
/// Provides separate builders for mobile, tablet, and web layouts.
/// Falls back to [mobile] builder when [tablet] or [web] are not provided.
///
/// Requirement 19.1: Responsive layout that adapts to mobile and web screen sizes.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.web,
  });

  /// Builder for mobile layout (width < 600).
  final Widget Function(BuildContext context, BoxConstraints constraints) mobile;

  /// Builder for tablet layout (600 <= width < 1024).
  /// Falls back to [mobile] if not provided.
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      tablet;

  /// Builder for web/desktop layout (width >= 1024).
  /// Falls back to [tablet] or [mobile] if not provided.
  final Widget Function(BuildContext context, BoxConstraints constraints)? web;

  /// Returns the [DeviceType] for the given [width].
  static DeviceType deviceTypeForWidth(double width) {
    if (width >= ResponsiveBreakpoints.tablet) return DeviceType.web;
    if (width >= ResponsiveBreakpoints.mobile) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = deviceTypeForWidth(constraints.maxWidth);

        return switch (deviceType) {
          DeviceType.web => (web ?? tablet ?? mobile)(context, constraints),
          DeviceType.tablet => (tablet ?? mobile)(context, constraints),
          DeviceType.mobile => mobile(context, constraints),
        };
      },
    );
  }
}
