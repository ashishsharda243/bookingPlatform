import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/discovery/presentation/providers/discovery_providers.dart';

/// Map view showing hall markers on a Mapbox map.
/// Uses a placeholder Container for the actual Mapbox map since
/// mapbox_gl has compatibility issues. Requirement 2.4.
class HallMapView extends ConsumerWidget {
  const HallMapView({
    super.key,
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallsState = ref.watch(hallListProvider);

    return hallsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Map error: $error')),
      data: (halls) {
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hall_booking_platform',
                ),
                MarkerLayer(
                  markers: halls.map((hall) {
                    return Marker(
                      point: LatLng(hall.lat, hall.lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => context.push('/hall/${hall.id}'),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Hall marker chips at the bottom
            if (halls.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: halls.length,
                  itemBuilder: (context, index) {
                    final hall = halls[index];
                    return _MapHallChip(
                      hall: hall,
                      onTap: () => context.push('/hall/${hall.id}'),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MapHallChip extends StatelessWidget {
  const _MapHallChip({required this.hall, required this.onTap});

  final Hall hall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hall.name,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (hall.distance != null)
                  Text(
                    '${hall.distance!.toStringAsFixed(1)} km away',
                    style: AppTypography.bodySmall,
                  ),
                const Spacer(),
                Text(
                  '₹${hall.basePrice.toStringAsFixed(0)}',
                  style: AppTypography.titleMedium
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
