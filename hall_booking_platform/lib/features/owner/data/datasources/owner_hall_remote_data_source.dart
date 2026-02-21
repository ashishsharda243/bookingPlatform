import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_create_request.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_update_request.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';

/// Remote data source for owner hall management operations.
class OwnerHallRemoteDataSource {
  OwnerHallRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Maximum number of images allowed per hall.
  static const int maxImagesPerHall = 10;

  /// Storage bucket name for hall images.
  static const String _bucketName = 'hall-images';

  /// Returns the current authenticated user's ID or throws.
  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Not authenticated.');
    }
    return userId;
  }

  /// Fetches all halls owned by the current user.
  Future<List<Hall>> getOwnerHalls() async {
    final userId = _currentUserId;

    final data = await _client
        .from('halls')
        .select()
        .eq('owner_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final halls = <Hall>[];
    for (final row in data) {
      // Extract lat/lng from location if stored as geography,
      // otherwise use direct fields.
      final hall = _hallFromRow(row);

      // Fetch image URLs for this hall
      final images = await _client
          .from('hall_images')
          .select('image_url')
          .eq('hall_id', hall.id)
          .order('sort_order');

      final imageUrls =
          images.map<String>((img) => img['image_url'] as String).toList();

      halls.add(hall.copyWith(imageUrls: imageUrls));
    }

    return halls;
  }

  /// Fetches a single hall by ID (must be owned by current user).
  Future<Hall> getHall(String hallId) async {
    final data = await _client
        .from('halls')
        .select()
        .eq('id', hallId)
        .single();

    final hall = _hallFromRow(data);

    // Fetch image URLs
    final images = await _client
        .from('hall_images')
        .select('image_url')
        .eq('hall_id', hallId)
        .order('sort_order');

    final imageUrls =
        images.map<String>((img) => img['image_url'] as String).toList();

    return hall.copyWith(imageUrls: imageUrls);
  }

  /// Creates a new hall with approval_status='pending' and the current user as owner.
  Future<Hall> createHall(HallCreateRequest request) async {
    final userId = _currentUserId;

    final data = await _client.from('halls').insert({
      'owner_id': userId,
      'name': request.name,
      'description': request.description,
      'location': 'POINT(${request.lng} ${request.lat})',
      'address': request.address,
      'amenities': request.amenities,
      'slot_duration_minutes': request.slotDurationMinutes,
      'base_price': request.basePrice,
      'approval_status': 'pending',
      'google_map_link': request.googleMapLink,
    }).select().single();

    final hall = _hallFromRow(data);
    
    // Automatically generate available slots for the next 30 days
    await _generateAndInsertSlots(hall.id, request.slotDurationMinutes);
    
    return hall;
  }

  /// Updates an existing hall WITHOUT changing approval_status.
  Future<Hall> updateHall(String hallId, HallUpdateRequest request) async {
    final updates = <String, dynamic>{};

    if (request.name != null) updates['name'] = request.name;
    if (request.description != null) {
      updates['description'] = request.description;
    }
    if (request.lat != null && request.lng != null) {
      updates['location'] = 'POINT(${request.lng} ${request.lat})';
    }
    if (request.address != null) updates['address'] = request.address;
    if (request.amenities != null) updates['amenities'] = request.amenities;
    if (request.slotDurationMinutes != null) {
      updates['slot_duration_minutes'] = request.slotDurationMinutes;
    }
    if (request.basePrice != null) {
      updates['base_price'] = request.basePrice;
    }
    if (request.googleMapLink != null) {
      updates['google_map_link'] = request.googleMapLink;
    }

    // Note: approval_status is intentionally NOT included in updates
    // to preserve the current status (Requirement 10.3).

    if (updates.isEmpty) {
      return getHall(hallId);
    }

    final data = await _client
        .from('halls')
        .update(updates)
        .eq('id', hallId)
        .select()
        .single();

    return _hallFromRow(data);
  }

  /// Soft deletes a hall by setting its is_active flag to false.
  Future<void> deleteHall(String hallId) async {
    await _client
        .from('halls')
        .update({'is_active': false})
        .eq('id', hallId);
  }

  // ... (uploadHallImages)

  // ... (other methods)

  /// Converts a database row to a [Hall] entity.
  Hall _hallFromRow(Map<String, dynamic> row) {
    // The database stores location as PostGIS geography.
    // When queried directly, lat/lng may need extraction.
    // If the row has 'lat' and 'lng' directly (from RPC), use those.
    // Otherwise, default to 0.0 (the actual lat/lng are in the geography column).
    var lat = row['lat'] as double? ?? 0.0;
    var lng = row['lng'] as double? ?? 0.0;

    // Fallback: Parse from location WKT if lat/lng are missing/zero
    // PostGIS 'location' column often returns as "POINT(lng lat)" string
    if ((lat == 0.0 || lng == 0.0) && row['location'] is String) {
      final loc = row['location'] as String;
      final regex = RegExp(r'POINT\s*\(\s*([-\d\.]+)\s+([-\d\.]+)\s*\)');
      final match = regex.firstMatch(loc);
      if (match != null) {
        // Note: PostGIS WKT is usually "POINT(lng lat)"
        lng = double.tryParse(match.group(1)!) ?? lng;
        lat = double.tryParse(match.group(2)!) ?? lat;
      }
    }

    // Fallback 2: Parse from google_map_link if available and still zero
    // Link format: https://www.google.com/maps/search/?api=1&query=lat,lng
    if ((lat == 0.0 || lng == 0.0) && row['google_map_link'] is String) {
      final link = row['google_map_link'] as String;
      final uri = Uri.tryParse(link);
      if (uri != null) {
        final query = uri.queryParameters['query'];
        if (query != null && query.contains(',')) {
          final parts = query.split(',');
          if (parts.length >= 2) {
             lat = double.tryParse(parts[0]) ?? lat;
             lng = double.tryParse(parts[1]) ?? lng;
          }
        }
      }
    }

    return Hall(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      lat: lat,
      lng: lng,
      address: row['address'] as String,
      amenities: (row['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      slotDurationMinutes: row['slot_duration_minutes'] as int,
      basePrice: (row['base_price'] as num).toDouble(),
      approvalStatus: row['approval_status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      googleMapLink: row['google_map_link'] as String?,
    );
  }

  /// Uploads images to Supabase Storage and inserts records into hall_images.
  ///
  /// Enforces a maximum of [maxImagesPerHall] images per hall.
  /// Uploads images to Supabase Storage and inserts records into hall_images.
  ///
  /// Enforces a maximum of [maxImagesPerHall] images per hall.
  Future<List<String>> uploadHallImages(
    String hallId,
    List<XFile> images,
  ) async {
    // Check existing image count
    final existingImages = await _client
        .from('hall_images')
        .select('id')
        .eq('hall_id', hallId);

    final existingCount = existingImages.length;
    final allowedCount = maxImagesPerHall - existingCount;

    if (allowedCount <= 0) {
      throw Exception(
        'Maximum of $maxImagesPerHall images per hall reached.',
      );
    }

    final imagesToUpload = images.take(allowedCount).toList();
    final uploadedUrls = <String>[];

    for (var i = 0; i < imagesToUpload.length; i++) {
      final file = imagesToUpload[i];
      final Uint8List bytes = await file.readAsBytes();
      
      // Get extension from name (safer on web than path)
      final name = file.name;
      final extension = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$hallId/${timestamp}_$i.$extension';

      await _client.storage.from(_bucketName).uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl =
          _client.storage.from(_bucketName).getPublicUrl(filePath);

      // Insert into hall_images table
      await _client.from('hall_images').insert({
        'hall_id': hallId,
        'image_url': publicUrl,
        'sort_order': existingCount + i,
      });

      uploadedUrls.add(publicUrl);
    }

    return uploadedUrls;
  }

  /// Deletes a hall image from storage and the hall_images table.
  Future<void> deleteHallImage(String imageId) async {
    await _client.from('hall_images').delete().eq('id', imageId);
  }

  // ---------------------------------------------------------------------------
  // Availability Management
  // ---------------------------------------------------------------------------

  /// Fetches all slots for a specific hall and date.
  Future<List<Map<String, dynamic>>> getSlotsByDate(
    String hallId,
    DateTime date,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final data = await _client
        .from('slots')
        .select()
        .eq('hall_id', hallId)
        .eq('date', dateStr)
        .order('start_time');

    return List<Map<String, dynamic>>.from(data);
  }

  /// Fetches slot summary counts for a hall within a date range.
  ///
  /// Returns a map of date string → { 'available': n, 'booked': n, 'blocked': n }.
  Future<Map<String, Map<String, int>>> getSlotSummary(
    String hallId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final data = await _client
        .from('slots')
        .select('date, status')
        .eq('hall_id', hallId)
        .gte('date', startStr)
        .lte('date', endStr);

    final summary = <String, Map<String, int>>{};
    for (final row in data) {
      final date = row['date'] as String;
      final status = row['status'] as String;
      summary.putIfAbsent(
          date, () => {'available': 0, 'booked': 0, 'blocked': 0});
      summary[date]![status] = (summary[date]![status] ?? 0) + 1;
    }
    return summary;
  }

  /// Blocks slots for the given hall across a date range.
  ///
  /// Creates slot records with status='blocked' for each date.
  /// Throws if any slot in the range is already 'booked'.
  Future<void> blockSlots(
    String hallId,
    List<DateTime> dates,
  ) async {
    for (final date in dates) {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Check for existing booked slots on this date
      final bookedSlots = await _client
          .from('slots')
          .select()
          .eq('hall_id', hallId)
          .eq('date', dateStr)
          .eq('status', 'booked');

      if (bookedSlots.isNotEmpty) {
        throw Exception(
          'Cannot block $dateStr: ${bookedSlots.length} slot(s) already booked.',
        );
      }

      // Update any existing 'available' slots to 'blocked'
      await _client
          .from('slots')
          .update({'status': 'blocked'})
          .eq('hall_id', hallId)
          .eq('date', dateStr)
          .eq('status', 'available');

      // Also insert a full-day blocked slot if no slots exist for this date
      final existingSlots = await _client
          .from('slots')
          .select('id')
          .eq('hall_id', hallId)
          .eq('date', dateStr);

      if (existingSlots.isEmpty) {
        await _client.from('slots').insert({
          'hall_id': hallId,
          'date': dateStr,
          'start_time': '00:00',
          'end_time': '23:59',
          'status': 'blocked',
        });
      }
    }
  }

  /// Unblocks slots for the given hall across a date range.
  ///
  /// Changes 'blocked' slots back to 'available'. Skips 'booked' slots.
  Future<void> unblockSlots(
    String hallId,
    List<DateTime> dates,
  ) async {
    for (final date in dates) {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Check for existing slots
      final existingSlots = await _client
          .from('slots')
          .select()
          .eq('hall_id', hallId)
          .eq('date', dateStr);

      if (existingSlots.isEmpty) {
         // No slot exists, create one as 'available'
         await _client.from('slots').insert({
          'hall_id': hallId,
          'date': dateStr,
          'start_time': '00:00',
          'end_time': '23:59',
          'status': 'available',
        });
      } else {
         // Update existing 'blocked' slots to 'available'
         // We should avoid overwriting 'booked' slots
         await _client
          .from('slots')
          .update({'status': 'available'})
          .eq('hall_id', hallId)
          .eq('date', dateStr)
          .eq('status', 'blocked');
      }
    }
  }

  /// Fetches all bookings for halls owned by the current user, sorted by date.
  ///
  /// Supports pagination with 20 items per page.
  Future<List<Booking>> getOwnerBookings({required int page}) async {
    final userId = _currentUserId;
    const pageSize = 20;
    final offset = (page - 1) * pageSize;

    // Get all hall IDs owned by this user
    final hallRows = await _client
        .from('halls')
        .select('id')
        .eq('owner_id', userId);

    final hallIds =
        hallRows.map<String>((row) => row['id'] as String).toList();

    if (hallIds.isEmpty) {
      return [];
    }

    // Fetch bookings for all owned halls with slot, hall, and user joins
    final data = await _client
        .from('bookings')
        .select('*, slots(*), halls(*), users(*)')
        .inFilter('hall_id', hallIds)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return data.map<Booking>((row) => _bookingFromRow(row)).toList();
  }

  /// Fetches bookings for a specific hall owned by the current user.
  Future<List<Booking>> getHallBookings({
    required String hallId,
    required int page,
  }) async {
    final userId = _currentUserId;
    const pageSize = 20;
    final offset = (page - 1) * pageSize;

    // Ownership guard: hall must belong to current owner.
    final hall = await _client
        .from('halls')
        .select('id')
        .eq('id', hallId)
        .eq('owner_id', userId)
        .maybeSingle();

    if (hall == null) {
      return [];
    }

    final data = await _client
        .from('bookings')
        .select('*, slots(*), halls(*), users(*)')
        .eq('hall_id', hallId)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return data.map<Booking>((row) => _bookingFromRow(row)).toList();
  }

  /// Updates the status of a booking.
  ///
  /// If [slotIdToRelease] is provided, also updates the corresponding slot
  /// back to 'available' status.
  Future<void> updateBookingStatus(
    String bookingId,
    String newStatus, {
    String? slotIdToRelease,
  }) async {
    // 1. Update booking status
    await _client.from('bookings').update({
      'booking_status': newStatus,
    }).eq('id', bookingId);

    // 2. If rejecting or cancelling, release the slot
    if (slotIdToRelease != null &&
        (newStatus == 'cancelled' || newStatus == 'rejected')) {
      await _client.from('slots').update({
        'status': 'available',
      }).eq('id', slotIdToRelease);
    }
  }

  /// Fetches earnings report for a specific hall over a given period.
  ///
  /// [period] must be one of 'daily', 'weekly', or 'monthly'.
  /// Calculates gross revenue from confirmed bookings, applies commission
  /// from platform_config, and returns net earnings.
  Future<EarningsReport> getEarnings({
    required String hallId,
    required String period,
  }) async {
    // Fetch commission percentage from platform_config
    final configData = await _client
        .from('platform_config')
        .select('value')
        .eq('key', 'commission_percentage')
        .single();

    final commissionPercentage =
        double.parse(configData['value'].toString());

    // Fetch confirmed bookings for this hall
    final bookingsData = await _client
        .from('bookings')
        .select('total_price, created_at, halls(name)')
        .eq('hall_id', hallId)
        .eq('booking_status', 'confirmed');

    final grossRevenue = bookingsData.fold<double>(
      0.0,
      (sum, row) => sum + (row['total_price'] as num).toDouble(),
    );

    final commissionAmount = grossRevenue * (commissionPercentage / 100);
    final netEarnings = grossRevenue - commissionAmount;

    // Group entries by period
    final entries = _groupByPeriod(bookingsData, hallId, period);

    return EarningsReport(
      grossRevenue: grossRevenue,
      commissionAmount: commissionAmount,
      netEarnings: netEarnings,
      commissionPercentage: commissionPercentage,
      entries: entries,
    );
  }

  /// Fetches earnings report across all halls owned by the current user.
  Future<EarningsReport> getOwnerEarnings({required String period}) async {
    final userId = _currentUserId;

    // Fetch commission percentage from platform_config
    final configData = await _client
        .from('platform_config')
        .select('value')
        .eq('key', 'commission_percentage')
        .single();

    final commissionPercentage =
        double.parse(configData['value'].toString());

    // Get all hall IDs owned by this user
    final hallRows = await _client
        .from('halls')
        .select('id, name')
        .eq('owner_id', userId);

    final hallMap = <String, String>{};
    for (final row in hallRows) {
      hallMap[row['id'] as String] = row['name'] as String;
    }

    if (hallMap.isEmpty) {
      return EarningsReport(
        grossRevenue: 0,
        commissionAmount: 0,
        netEarnings: 0,
        commissionPercentage: commissionPercentage,
        entries: [],
      );
    }

    // Fetch confirmed bookings for all owned halls
    final bookingsData = await _client
        .from('bookings')
        .select('total_price, created_at, hall_id')
        .inFilter('hall_id', hallMap.keys.toList())
        .eq('booking_status', 'confirmed');

    final grossRevenue = bookingsData.fold<double>(
      0.0,
      (sum, row) => sum + (row['total_price'] as num).toDouble(),
    );

    final commissionAmount = grossRevenue * (commissionPercentage / 100);
    final netEarnings = grossRevenue - commissionAmount;

    // Group entries by period across all halls
    final entries = _groupOwnerByPeriod(bookingsData, hallMap, period);

    return EarningsReport(
      grossRevenue: grossRevenue,
      commissionAmount: commissionAmount,
      netEarnings: netEarnings,
      commissionPercentage: commissionPercentage,
      entries: entries,
    );
  }

  /// Groups booking data into [EarningEntry] items by the given period.
  List<EarningEntry> _groupByPeriod(
    List<dynamic> bookingsData,
    String hallId,
    String period,
  ) {
    final grouped = <String, _EntryAccumulator>{};
    final hallName = bookingsData.isNotEmpty
        ? ((bookingsData.first['halls'] as Map<String, dynamic>?)?['name']
                as String? ??
            'Unknown')
        : 'Unknown';

    for (final row in bookingsData) {
      final createdAt = DateTime.parse(row['created_at'] as String);
      final key = _periodKey(createdAt, period);
      final price = (row['total_price'] as num).toDouble();

      grouped.putIfAbsent(
        key,
        () => _EntryAccumulator(date: _periodDate(createdAt, period)),
      );
      grouped[key]!.revenue += price;
      grouped[key]!.bookingCount += 1;
    }

    return grouped.entries
        .map((e) => EarningEntry(
              hallId: hallId,
              hallName: hallName,
              revenue: e.value.revenue,
              bookingCount: e.value.bookingCount,
              date: e.value.date,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Groups booking data across multiple halls by period.
  List<EarningEntry> _groupOwnerByPeriod(
    List<dynamic> bookingsData,
    Map<String, String> hallMap,
    String period,
  ) {
    final grouped = <String, _EntryAccumulator>{};

    for (final row in bookingsData) {
      final createdAt = DateTime.parse(row['created_at'] as String);
      final hallId = row['hall_id'] as String;
      final key = '${hallId}_${_periodKey(createdAt, period)}';
      final price = (row['total_price'] as num).toDouble();

      grouped.putIfAbsent(
        key,
        () => _EntryAccumulator(
          date: _periodDate(createdAt, period),
          hallId: hallId,
        ),
      );
      grouped[key]!.revenue += price;
      grouped[key]!.bookingCount += 1;
    }

    return grouped.entries
        .map((e) => EarningEntry(
              hallId: e.value.hallId ?? '',
              hallName: hallMap[e.value.hallId] ?? 'Unknown',
              revenue: e.value.revenue,
              bookingCount: e.value.bookingCount,
              date: e.value.date,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Returns a grouping key for the given date and period.
  String _periodKey(DateTime date, String period) {
    return switch (period) {
      'daily' => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'weekly' =>
        '${date.year}-W${_weekNumber(date).toString().padLeft(2, '0')}',
      'monthly' =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}',
      _ => '${date.year}-${date.month.toString().padLeft(2, '0')}',
    };
  }

  /// Returns the start date for the period containing the given date.
  DateTime _periodDate(DateTime date, String period) {
    return switch (period) {
      'daily' => DateTime(date.year, date.month, date.day),
      'weekly' => date.subtract(Duration(days: date.weekday - 1)),
      'monthly' => DateTime(date.year, date.month, 1),
      _ => DateTime(date.year, date.month, 1),
    };
  }

  /// Returns the ISO week number for a date.
  int _weekNumber(DateTime date) {
    final dayOfYear =
        date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  /// Converts a database row (with joins) to a [Booking] entity.
  Booking _bookingFromRow(Map<String, dynamic> row) {
    final slotData = row['slots'] as Map<String, dynamic>?;
    final hallData = row['halls'] as Map<String, dynamic>?;
    final userData = row['users'] as Map<String, dynamic>?;

    Slot? slot;
    if (slotData != null) {
      slot = Slot(
        id: slotData['id'] as String,
        hallId: slotData['hall_id'] as String,
        date: DateTime.parse(slotData['date'] as String),
        startTime: slotData['start_time'] as String,
        endTime: slotData['end_time'] as String,
        status: slotData['status'] as String,
      );
    }

    Hall? hall;
    if (hallData != null) {
      hall = _hallFromRow(hallData);
    }

    AppUser? user;
    if (userData != null) {
      user = AppUser(
        id: userData['id'] as String,
        role: userData['role'] as String,
        name: userData['name'] as String,
        phone: userData['phone'] as String?,
        email: userData['email'] as String?,
        profileImageUrl: userData['profile_image_url'] as String?,
        isActive: userData['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(userData['created_at'] as String),
      );
    }

    return Booking(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      hallId: row['hall_id'] as String,
      slotId: row['slot_id'] as String,
      totalPrice: (row['total_price'] as num).toDouble(),
      paymentStatus: row['payment_status'] as String,
      bookingStatus: row['booking_status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      slot: slot,
      hall: hall,
      user: user,
    );
  }

  /// Generates and inserts 'available' slots for the next 30 days.
  Future<void> _generateAndInsertSlots(
    String hallId,
    int slotDurationMinutes,
  ) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    // Generate for 30 days
    const daysToGenerate = 30;

    final batchInsert = <Map<String, dynamic>>[];

    for (var i = 0; i < daysToGenerate; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Generate slots for the day
      // 24 hours * 60 minutes = 1440 minutes
      const totalMinutesInDay = 1440;
      var currentMinutes = 0;

      while (currentMinutes + slotDurationMinutes <= totalMinutesInDay) {
        final startH = currentMinutes ~/ 60;
        final startM = currentMinutes % 60;
        
        final endTotal = currentMinutes + slotDurationMinutes;
        final endH = endTotal ~/ 60;
        final endM = endTotal % 60;

        // Format HH:mm
        final startTime =
            '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}';
        
        String endTime;
        if (endTotal == 1440) {
          endTime = '23:59'; 
        } else {
          endTime =
            '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';
        }

        batchInsert.add({
          'hall_id': hallId,
          'date': dateStr,
          'start_time': startTime,
          'end_time': endTime,
          'status': 'available',
        });

        currentMinutes += slotDurationMinutes;
      }
    }

    if (batchInsert.isNotEmpty) {
      // Supabase handles batch inserts efficiently
      await _client.from('slots').insert(batchInsert);
    }
  }

}

/// Riverpod provider for [OwnerHallRemoteDataSource].
final ownerHallRemoteDataSourceProvider =
    Provider<OwnerHallRemoteDataSource>((ref) {
  return OwnerHallRemoteDataSource(ref.watch(supabaseClientProvider));
});

/// Accumulator for grouping earnings entries.
class _EntryAccumulator {
  _EntryAccumulator({required this.date, this.hallId});

  final DateTime date;
  final String? hallId;
  double revenue = 0;
  int bookingCount = 0;
}
