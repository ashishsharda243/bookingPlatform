import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:hall_booking_platform/features/reviews/presentation/providers/review_providers.dart';
import 'package:hall_booking_platform/features/reviews/presentation/widgets/review_form_widget.dart';
import 'package:hall_booking_platform/features/reviews/presentation/widgets/review_list_widget.dart';

/// Detail screen for a single hall. Shows image carousel, name, description,
/// address, amenities, reviews, embedded map, and "Book Now" button.
/// Requirements 3.1, 3.2, 3.3, 3.4.
class HallDetailScreen extends ConsumerWidget {
  const HallDetailScreen({super.key, required this.hallId});

  final String hallId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallState = ref.watch(hallDetailProvider(hallId));

    return Scaffold(
      body: hallState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorDisplay(
          message: 'Failed to load hall details.',
          onRetry: () => ref.invalidate(hallDetailProvider(hallId)),
        ),
        data: (hall) => _HallDetailBody(hall: hall),
      ),
      bottomNavigationBar: hallState.whenOrNull(
        data: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _BookNowButton(hallId: hallId),
          ),
        ),
      ),
    );
  }
}

class _HallDetailBody extends ConsumerWidget {
  const _HallDetailBody({required this.hall});

  final Hall hall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Image carousel in SliverAppBar
        _ImageCarouselAppBar(hall: hall),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(hall.name,
                          style: AppTypography.headlineMedium),
                    ),
                    if (hall.averageRating != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _RatingBadge(rating: hall.averageRating!),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Address
                const SizedBox(height: AppSpacing.sm),
                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(hall.address,
                          style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
                if (hall.googleMapLink != null &&
                    hall.googleMapLink!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(hall.googleMapLink!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'View on Google Maps',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                // Price + Slot duration
                Row(
                  children: [
                    Text(
                      '₹${hall.basePrice.toStringAsFixed(0)}',
                      style: AppTypography.headlineSmall
                          .copyWith(color: AppColors.primary),
                    ),
                    Text(
                      ' / ${hall.slotDurationMinutes} min slot',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Description
                if (hall.description.isNotEmpty) ...[
                  Text('About', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(hall.description, style: AppTypography.bodyLarge),
                  const SizedBox(height: AppSpacing.lg),
                ],
                // Amenities
                if (hall.amenities.isNotEmpty) ...[
                  Text('Amenities', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  _AmenitiesChips(amenities: hall.amenities),
                  const SizedBox(height: AppSpacing.lg),
                ],
                // Embedded map placeholder (Requirement 3.4)
                Text('Location', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                _EmbeddedMapPlaceholder(lat: hall.lat, lng: hall.lng),
                const SizedBox(height: AppSpacing.lg),
                // Reviews section placeholder (Requirement 3.3)
                Text('Reviews', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                _ReviewsSection(hall: hall),
                // Bottom spacing for the Book Now button
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Image carousel in a SliverAppBar with PageView (Requirement 3.2).
class _ImageCarouselAppBar extends StatefulWidget {
  const _ImageCarouselAppBar({required this.hall});

  final Hall hall;

  @override
  State<_ImageCarouselAppBar> createState() => _ImageCarouselAppBarState();
}

class _ImageCarouselAppBarState extends State<_ImageCarouselAppBar> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.hall.imageUrls ?? [];

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: images.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.broken_image,
                              size: 48, color: AppColors.textHint),
                        ),
                      );
                    },
                  ),
                  // Page indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _currentPage
                                  ? AppColors.surface
                                  : AppColors.surface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : Container(
                color: AppColors.divider,
                child: const Center(
                  child: Icon(Icons.image,
                      size: 64, color: AppColors.textHint),
                ),
              ),
      ),
      // Book Now floating button
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.titleMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AmenitiesChips extends StatelessWidget {
  const _AmenitiesChips({required this.amenities});

  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: amenities
          .map((a) => Chip(
                label: Text(a, style: AppTypography.bodySmall),
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ))
          .toList(),
    );
  }
}

/// Placeholder for the embedded Mapbox map (Requirement 3.4).
class _EmbeddedMapPlaceholder extends StatelessWidget {
  const _EmbeddedMapPlaceholder({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF0),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 32, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reviews section showing review list and conditional review form.
/// Requirements 3.3, 7.1, 7.2.
class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.hall});

  final Hall hall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSubmitAsync = ref.watch(canSubmitReviewProvider(hall.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average rating summary
        if (hall.averageRating != null) ...[
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                hall.averageRating!.toStringAsFixed(1),
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('average rating', style: AppTypography.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        // Review form (only visible for users with completed bookings and no existing review)
        canSubmitAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (canSubmit) {
            if (!canSubmit) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ReviewFormWidget(hallId: hall.id),
            );
          },
        ),
        // Paginated review list
        ReviewListWidget(hallId: hall.id),
      ],
    );
  }
}

/// Floating "Book Now" button shown at the bottom of the detail screen.
class _BookNowButton extends StatelessWidget {
  const _BookNowButton({required this.hallId});

  final String hallId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => context.push('/hall/$hallId/slots'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: const Text('Book Now', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
