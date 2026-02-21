import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A reusable image widget that wraps [CachedNetworkImage] with consistent
/// placeholder and error handling across the app.
///
/// Supports lazy loading out of the box via cached_network_image's built-in
/// behavior (Requirement 18.1).
class CachedImageWidget extends StatelessWidget {
  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image,
    this.errorIcon = Icons.broken_image,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _IconPlaceholder(icon: placeholderIcon),
      errorWidget: (_, __, ___) => _IconPlaceholder(icon: errorIcon),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

class _IconPlaceholder extends StatelessWidget {
  const _IconPlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.divider,
      child: Center(
        child: Icon(icon, size: 48, color: AppColors.textHint),
      ),
    );
  }
}
