import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';

/// Card widget displaying a hall summary: thumbnail, name, distance,
/// base price, and rating. Used in the hall list view (Requirement 2.5, 19.6).
class HallCard extends StatelessWidget {
  const HallCard({
    super.key,
    required this.hall,
    required this.onTap,
  });

  final Hall hall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbnail =
        (hall.imageUrls != null && hall.imageUrls!.isNotEmpty)
            ? hall.imageUrls!.first
            : null;

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              height: 160,
              width: double.infinity,
              child: thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => _DefaultCover(name: hall.name),
                    )
                  : _DefaultCover(name: hall.name),
            ),
            Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    hall.name,
                    style: AppTypography.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Distance + Rating row
                  Row(
                    children: [
                      if (hall.distance != null) ...[
                        Icon(Icons.location_on,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          '${hall.distance!.toStringAsFixed(1)} km',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      if (hall.averageRating != null) ...[
                        Icon(Icons.star,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          hall.averageRating!.toStringAsFixed(1),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '₹${hall.basePrice.toStringAsFixed(0)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultCover extends StatelessWidget {
  const _DefaultCover({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'H',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
