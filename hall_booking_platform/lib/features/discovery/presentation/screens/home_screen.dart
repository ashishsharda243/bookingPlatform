import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:hall_booking_platform/features/discovery/presentation/widgets/hall_card.dart';
import 'package:hall_booking_platform/features/discovery/presentation/widgets/hall_list_view.dart';
import 'package:hall_booking_platform/features/discovery/presentation/widgets/hall_map_view.dart';
import 'package:hall_booking_platform/services/location_service.dart';
import 'package:latlong2/latlong.dart';

/// Whether the home screen shows list or map view.
final _viewModeProvider = StateProvider<_ViewMode>((ref) => _ViewMode.list);

enum _ViewMode { list, map }

/// Home screen with map/list toggle, search bar with 300ms debounce.
/// Requests location on first load. Requirements 2.1-2.8, 19.1-19.6.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Request location on first load (Requirement 2.1)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  Future<void> _initLocation() async {
    final notifier = ref.read(userLocationProvider.notifier);
    await notifier.fetchLocation();

    final locationState = ref.read(userLocationProvider);
    locationState.whenData((result) {
      if (result.isSuccess) {
        ref.read(hallListProvider.notifier).loadInitial(
              lat: result.latitude!,
              lng: result.longitude!,
            );
      } else {
        // Fallback to default location (Hyderabad) if location service fails
        // This ensures the user sees something instead of an empty screen
        ref.read(hallListProvider.notifier).loadInitial(
              lat: 17.4478,
              lng: 78.3540,
            );
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: AppConstants.searchDebounceDurationMs),
      () {
        ref.read(searchQueryProvider.notifier).state = value.trim();
      },
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final locationState = ref.read(userLocationProvider);
    final lat = locationState.asData?.value.latitude ?? 17.4478;
    final lng = locationState.asData?.value.longitude ?? 78.3540;

    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        height: 200,
        child: Column(
          children: [
            Text('Select Location', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.my_location, color: AppColors.primary),
              title: const Text('Use Current Location'),
              onTap: () async {
                context.pop();
                await ref.read(userLocationProvider.notifier).resetToCurrentLocation();
                
                final updatedLocation =
                    ref.read(userLocationProvider).asData?.value;
                if (updatedLocation != null && updatedLocation.isSuccess) {
                   ref.read(hallListProvider.notifier).loadInitial(
                        lat: updatedLocation.latitude!,
                        lng: updatedLocation.longitude!,
                      );
                } else {
                    // Fallback if location service fails even after reset
                     ref.read(hallListProvider.notifier).loadInitial(
                        lat: 17.4478,
                        lng: 78.3540,
                    );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: AppColors.primary),
              title: const Text('Select on Map'),
              onTap: () async {
                context.pop();
                final result = await context.push<LatLng>(
                  '/location-picker',
                  extra: {'lat': lat, 'lng': lng},
                );
                if (result != null) {
                  ref.read(userLocationProvider.notifier).setManualLocation(
                        result.latitude,
                        result.longitude,
                      );
                  // Reload list with new location
                   ref.read(hallListProvider.notifier).loadInitial(
                        lat: result.latitude,
                        lng: result.longitude,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(_viewModeProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        title: GestureDetector(
          onTap: _pickLocation,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Location',
                style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
              ),
              const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter halls',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const _FilterBottomSheet(),
              );
            },
          ),
          // Map/List toggle
          IconButton(
            icon: Icon(
              viewMode == _ViewMode.list ? Icons.map : Icons.list,
            ),
            tooltip: viewMode == _ViewMode.list
                ? 'Switch to map view'
                : 'Switch to list view',
            onPressed: () {
              ref.read(_viewModeProvider.notifier).state =
                  viewMode == _ViewMode.list ? _ViewMode.map : _ViewMode.list;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search halls...',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: searchQuery.isNotEmpty
                ? _SearchResults(searchQuery: searchQuery)
                : _LocationBasedContent(viewMode: viewMode),
          ),
        ],
      ),
    );
  }
}

/// Shows content based on user location state.
class _LocationBasedContent extends ConsumerWidget {
  const _LocationBasedContent({required this.viewMode});

  final _ViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(userLocationProvider);

    return locationState.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorDisplay(
        message: 'Failed to get location. Please try again.',
        onRetry: () => ref.read(userLocationProvider.notifier).fetchLocation(),
      ),
      data: (result) {
        if (!result.isSuccess) {
          return _LocationDeniedView(status: result.status);
        }

        final lat = result.latitude!;
        final lng = result.longitude!;

        return viewMode == _ViewMode.list
            ? HallListView(
                key: ValueKey('list_$lat$lng'),
                lat: lat,
                lng: lng,
              )
            : HallMapView(
                key: ValueKey('map_$lat$lng'),
                lat: lat,
                lng: lng,
              );
      },
    );
  }
}

/// Shown when location permission is denied (Requirement 2.6).
class _LocationDeniedView extends StatelessWidget {
  const _LocationDeniedView({required this.status});

  final LocationResultStatus status;

  @override
  Widget build(BuildContext context) {
    final message = switch (status) {
      LocationResultStatus.serviceDisabled =>
        'Location services are disabled. Please enable them in your device settings to discover nearby halls.',
      LocationResultStatus.denied =>
        'Location permission is needed to find halls near you. Please grant location access.',
      LocationResultStatus.permanentlyDenied =>
        'Location permission was permanently denied. Please enable it in your app settings to discover nearby halls.',
      _ => 'Unable to access location.',
    };

    return EmptyStateWidget(
      message: message,
      icon: Icons.location_off,
      actionLabel: 'Open Settings',
      onAction: () {
        // In a real app, this would open app settings
      },
    );
  }
}

/// Shows search results when the user types in the search bar.
class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchHallsProvider(1));

    return searchState.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorDisplay(
        message: 'Search failed. Please try again.',
        onRetry: () => ref.invalidate(searchHallsProvider(1)),
      ),
      data: (halls) {
        if (halls.isEmpty) {
          return EmptyStateWidget(
            message: 'No halls found for "$searchQuery"',
            icon: Icons.search_off,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          itemCount: halls.length,
          itemBuilder: (context, index) {
            final hall = halls[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HallCard(
                hall: hall,
                onTap: () => context.push('/hall/${hall.id}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterBottomSheet extends ConsumerStatefulWidget {
  const _FilterBottomSheet();

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late double _maxDistance;

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(filterStateProvider);
    _minPrice = currentFilters.minPrice ?? 0;
    _maxPrice = currentFilters.maxPrice ?? 50000;
    _maxDistance = currentFilters.maxDistance ?? 50;
  }

  void _applyFilters() {
    ref.read(filterStateProvider.notifier).state = FilterState(
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 50000 ? _maxPrice : null,
      maxDistance: _maxDistance < 50 ? _maxDistance : null,
    );

    // Reload list with new filters
    final userLocation = ref.read(userLocationProvider).asData?.value;
    if (userLocation != null && userLocation.isSuccess) {
      ref.read(hallListProvider.notifier).loadInitial(
            lat: userLocation.latitude!,
            lng: userLocation.longitude!,
          );
    } else {
        // Fallback reload
         ref.read(hallListProvider.notifier).loadInitial(
            lat: 17.4478,
            lng: 78.3540,
        );
    }
    context.pop();
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 50000;
      _maxDistance = 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      height: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTypography.headlineMedium),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text('Price Range (₹${_minPrice.round()} - ₹${_maxPrice.round()})',
              style: AppTypography.titleMedium),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 50000,
            divisions: 100,
            labels: RangeLabels(
              '₹${_minPrice.round()}',
              '₹${_maxPrice.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Max Distance (${_maxDistance.round()} km)',
              style: AppTypography.titleMedium),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_maxDistance.round()} km',
            onChanged: (value) {
              setState(() {
                _maxDistance = value;
              });
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
