import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A shimmer loading effect widget for placeholder content during async loads.
///
/// Uses a [LinearGradient] animated across the widget to create a shimmering
/// effect. No external package required.
///
/// Requirement 19.2: Display appropriate loading indicators during async operations.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  /// The placeholder shape to apply the shimmer effect to.
  final Widget child;

  /// Base color of the shimmer. Defaults to a light grey.
  final Color? baseColor;

  /// Highlight color of the shimmer. Defaults to near-white.
  final Color? highlightColor;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? Colors.grey.shade300;
    final highlight = widget.highlightColor ?? Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A pre-built shimmer placeholder for list items (e.g., hall cards).
///
/// Renders a card-shaped skeleton with a thumbnail, title lines, and a
/// subtitle line to mimic the layout of a real hall card.
class ShimmerListPlaceholder extends StatelessWidget {
  const ShimmerListPlaceholder({
    super.key,
    this.itemCount = 3,
  });

  /// Number of placeholder items to display.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: ShimmerLoading(child: _CardSkeleton()),
        );
      },
    );
  }
}

/// A pre-built shimmer placeholder for detail screens.
///
/// Renders a large image area, title block, and several body text lines.
class ShimmerDetailPlaceholder extends StatelessWidget {
  const ShimmerDetailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ShimmerLoading(
            child: Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
          ),
          Padding(
            padding: AppSpacing.screenPadding,
            child: ShimmerLoading(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _shimmerBox(height: 24, widthFraction: 0.6),
                  const SizedBox(height: AppSpacing.sm),
                  _shimmerBox(height: 16, widthFraction: 0.4),
                  const SizedBox(height: AppSpacing.lg),
                  _shimmerBox(height: 14, widthFraction: 1.0),
                  const SizedBox(height: AppSpacing.sm),
                  _shimmerBox(height: 14, widthFraction: 1.0),
                  const SizedBox(height: AppSpacing.sm),
                  _shimmerBox(height: 14, widthFraction: 0.8),
                  const SizedBox(height: AppSpacing.lg),
                  _shimmerBox(height: 14, widthFraction: 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _shimmerBox({required double height, required double widthFraction}) {
  return FractionallySizedBox(
    widthFactor: widthFraction,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}
