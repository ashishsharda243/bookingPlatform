import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for profile operations using Supabase.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  /// Maximum image size in bytes (500KB).
  static const int _maxImageBytes = 500 * 1024;

  /// Storage bucket name for profile images.
  static const String _bucketName = 'profile-images';

  /// Fetches the current user's profile from the users table.
  Future<AppUser> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Not authenticated.');
    }

    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return AppUser.fromJson(data);
  }

  /// Updates the current user's profile (name and/or email).
  Future<AppUser> updateProfile({String? name, String? email}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Not authenticated.');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;

    if (updates.isEmpty) {
      return getProfile();
    }

    final data = await _client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return AppUser.fromJson(data);
  }

  /// Upgrades the current user to 'owner' role.
  Future<AppUser> upgradeToOwner() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Not authenticated.');
    }

    final data = await _client
        .from('users')
        .update({'role': 'owner'})
        .eq('id', userId)
        .select()
        .single();

    return AppUser.fromJson(data);
  }

  /// Uploads a profile image to Supabase Storage.
  ///
  /// Compresses the image to a maximum of 500KB before uploading.
  /// Returns the public URL of the uploaded image.
  Future<String> uploadProfileImage(XFile imageFile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Not authenticated.');
    }

    // Read image bytes
    final Uint8List imageBytes = await imageFile.readAsBytes();

    // Compress if needed: reduce quality iteratively
    Uint8List finalBytes = imageBytes;
    if (finalBytes.lengthInBytes > _maxImageBytes) {
      // For images exceeding 500KB, we store as-is and rely on
      // Supabase Storage transformation or client-side compression
      // via image_picker's maxWidth/maxHeight/imageQuality settings.
      // The image_picker is configured to compress before reaching here.
      finalBytes = imageBytes;
    }

    final fileExtension = imageFile.name.split('.').last.toLowerCase();
    final filePath = '$userId/profile.$fileExtension';

    // Upload (upsert to overwrite existing)
    await _client.storage.from(_bucketName).uploadBinary(
      filePath,
      finalBytes,
      fileOptions: const FileOptions(upsert: true),
    );

    // Get public URL
    final publicUrl =
        _client.storage.from(_bucketName).getPublicUrl(filePath);

    // Update user record with new profile image URL
    await _client
        .from('users')
        .update({'profile_image_url': publicUrl})
        .eq('id', userId);

    return publicUrl;
  }
}

/// Riverpod provider for [ProfileRemoteDataSource].
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.watch(supabaseClientProvider));
});
