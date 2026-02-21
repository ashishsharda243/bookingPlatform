import 'package:flutter/material.dart';

/// A centered circular progress indicator for async loading states.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color,
    this.size,
    this.strokeWidth = 4.0,
  });

  final Color? color;
  final double? size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
      strokeWidth: strokeWidth,
    );

    if (size != null) {
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: indicator,
        ),
      );
    }

    return Center(child: indicator);
  }
}
