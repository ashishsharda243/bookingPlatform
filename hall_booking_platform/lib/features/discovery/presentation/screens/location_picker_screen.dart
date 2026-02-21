import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/services/location_service.dart';
import 'package:hall_booking_platform/features/discovery/presentation/providers/discovery_providers.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  final double initialLat;
  final double initialLng;

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isMoving = ValueNotifier<bool>(false);
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      _selectedLocation = camera.center;
      if (!_isMoving.value) {
        _isMoving.value = true;
      }
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      _isMoving.value = false;
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoadingLocation = true);
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    final geocodingService = ref.read(geocodingServiceProvider);
    final coords = await geocodingService.getCoordinates(query);

    if (mounted) {
      setState(() => _isLoadingLocation = false);
      if (coords != null) {
        final newLocation = LatLng(coords['lat']!, coords['lng']!);
        _mapController.move(newLocation, 13.0);
        setState(() {
          _selectedLocation = newLocation;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    }
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    final locationService = ref.read(locationServiceProvider);
    final result = await locationService.getCurrentLocation();

    if (mounted) {
      setState(() => _isLoadingLocation = false);
      
      if (result.isSuccess && result.latitude != null && result.longitude != null) {
        final newLocation = LatLng(result.latitude!, result.longitude!);
        _mapController.move(newLocation, 13.0);
        setState(() {
          _selectedLocation = newLocation;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get current location')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search city or place...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(_selectedLocation);
            },
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13.0,
              onPositionChanged: _onMapPositionChanged,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hall_booking_platform',
              ),
            ],
          ),
          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24), // Adjust for pin tip
              child: ValueListenableBuilder<bool>(
                valueListenable: _isMoving,
                builder: (context, isMoving, child) {
                  return Icon(
                    Icons.location_on,
                    size: 48,
                    color: isMoving ? AppColors.primary : AppColors.error,
                  );
                },
              ),
            ),
          ),
          // Instructions
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Drag map to select location',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            ),
          ),
          if (_isLoadingLocation)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
