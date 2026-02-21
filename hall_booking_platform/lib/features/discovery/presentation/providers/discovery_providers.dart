import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/core/services/geocoding_service.dart';
import 'package:hall_booking_platform/features/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/services/location_service.dart';

/// Provides access to the geocoding service.
final geocodingServiceProvider = Provider((ref) => GeocodingService());

/// Holds the user's current location once resolved.
final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, AsyncValue<LocationResult>>(
  (ref) => UserLocationNotifier(ref),
);

class UserLocationNotifier extends StateNotifier<AsyncValue<LocationResult>> {
  UserLocationNotifier(this._ref) : super(const AsyncValue.loading());

  final Ref _ref;
  bool _isManual = false;

  Future<void> fetchLocation() async {
    if (_isManual) return; // Do not overwrite manual location automatically
    state = const AsyncValue.loading();
    try {
      final result =
          await _ref.read(locationServiceProvider).getCurrentLocation();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setManualLocation(double lat, double lng) {
    _isManual = true;
    state = AsyncValue.data(LocationResult.success(latitude: lat, longitude: lng));
  }

  Future<void> resetToCurrentLocation() async {
    _isManual = false;
    await fetchLocation();
  }
}

class FilterState {
  final double? minPrice;
  final double? maxPrice;
  final double? maxDistance;

  const FilterState({this.minPrice, this.maxPrice, this.maxDistance});

  FilterState copyWith({
    double? minPrice,
    double? maxPrice,
    double? maxDistance,
  }) {
    return FilterState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }
}

final filterStateProvider = StateProvider<FilterState>((ref) => const FilterState());

/// Query parameters for nearby halls.
class NearbyHallsQuery {
  const NearbyHallsQuery({
    required this.lat,
    required this.lng,
    this.radiusKm = AppConstants.defaultSearchRadiusKm,
    this.page = 1,
    this.pageSize = AppConstants.defaultPageSize,
  });

  final double lat;
  final double lng;
  final double radiusKm;
  final int page;
  final int pageSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyHallsQuery &&
          other.lat == lat &&
          other.lng == lng &&
          other.radiusKm == radiusKm &&
          other.page == page &&
          other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(lat, lng, radiusKm, page, pageSize);
}

/// Fetches nearby halls for a given query (location + page).
final nearbyHallsProvider = FutureProvider.autoDispose
    .family<List<Hall>, NearbyHallsQuery>((ref, query) async {
  final repo = ref.read(discoveryRepositoryProvider);
  final result = await repo.getNearbyHalls(
    lat: query.lat,
    lng: query.lng,
    radiusKm: query.radiusKm,
    page: query.page,
    pageSize: query.pageSize,
  );
  return result.fold(
    (failure) => throw failure,
    (halls) => halls,
  );
});

/// Fetches hall details by ID.
final hallDetailProvider =
    FutureProvider.autoDispose.family<Hall, String>((ref, hallId) async {
  final repo = ref.read(discoveryRepositoryProvider);
  final result = await repo.getHallDetails(hallId);
  return result.fold(
    (failure) => throw failure,
    (hall) => hall,
  );
});

/// Search query text state (debounced externally by the UI).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Searches halls by text query with pagination.
final searchHallsProvider = FutureProvider.autoDispose
    .family<List<Hall>, int>((ref, page) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final location = ref.read(userLocationProvider);
  double? lat;
  double? lng;
  location.whenData((loc) {
    if (loc.isSuccess) {
      lat = loc.latitude;
      lng = loc.longitude;
    }
  });

  final repo = ref.read(discoveryRepositoryProvider);
  final result = await repo.searchHalls(
    query: query,
    lat: lat,
    lng: lng,
    page: page,
    pageSize: AppConstants.defaultPageSize,
  );
  return result.fold(
    (failure) => throw failure,
    (halls) => halls,
  );
});

/// Manages paginated list of nearby halls with load-more support.
final hallListProvider =
    StateNotifierProvider<HallListNotifier, AsyncValue<List<Hall>>>(
  (ref) => HallListNotifier(ref),
);

class HallListNotifier extends StateNotifier<AsyncValue<List<Hall>>> {
  HallListNotifier(this._ref) : super(const AsyncValue.loading());

  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInitial({
    required double lat,
    required double lng,
  }) async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    try {
      final filters = _ref.read(filterStateProvider);
      final repo = _ref.read(discoveryRepositoryProvider);
      final result = await repo.getNearbyHalls(
        lat: lat,
        lng: lng,
        radiusKm: AppConstants.defaultSearchRadiusKm,
        page: 1,
        pageSize: AppConstants.defaultPageSize,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        maxDistance: filters.maxDistance,
      );
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (halls) {
          _hasMore = halls.length >= AppConstants.defaultPageSize;
          state = AsyncValue.data(halls);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore({
    required double lat,
    required double lng,
  }) async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      _currentPage++;
      final filters = _ref.read(filterStateProvider);
      final repo = _ref.read(discoveryRepositoryProvider);
      final result = await repo.getNearbyHalls(
        lat: lat,
        lng: lng,
        radiusKm: AppConstants.defaultSearchRadiusKm,
        page: _currentPage,
        pageSize: AppConstants.defaultPageSize,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        maxDistance: filters.maxDistance,
      );
      result.fold(
        (failure) => _currentPage--,
        (halls) {
          _hasMore = halls.length >= AppConstants.defaultPageSize;
          final current = state.asData?.value ?? [];
          state = AsyncValue.data([...current, ...halls]);
        },
      );
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }
}
