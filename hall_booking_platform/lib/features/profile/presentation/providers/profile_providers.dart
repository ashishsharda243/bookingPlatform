import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:image_picker/image_picker.dart';

/// State for the profile screen.
class ProfileState {
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.error,
    this.successMessage,
  });

  final AppUser? user;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImage;
  final String? error;
  final String? successMessage;

  ProfileState copyWith({
    AppUser? user,
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingImage,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Manages profile state: loading, updating, and image upload.
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._repository) : super(const ProfileState());

  final ProfileRepositoryImpl _repository;

  /// Loads the current user's profile.
  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.getProfile();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
      ),
    );
  }

  /// Updates the user's name and/or email.
  Future<void> updateProfile({String? name, String? email}) async {
    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.updateProfile(
      name: name,
      email: email,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isSaving: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isSaving: false,
        user: user,
        successMessage: 'Profile updated successfully.',
      ),
    );
  }

  /// Uploads a profile image.
  Future<void> uploadProfileImage(XFile imageFile) async {
    state = state.copyWith(
      isUploadingImage: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.uploadProfileImage(imageFile);

    result.fold(
      (failure) => state = state.copyWith(
        isUploadingImage: false,
        error: failure.message,
      ),
      (url) {
        final updatedUser = state.user?.copyWith(profileImageUrl: url);
        state = state.copyWith(
          isUploadingImage: false,
          user: updatedUser,
          successMessage: 'Profile picture updated.',
        );
      },
    );
  }

  /// Upgrades the user to 'owner' role.
  Future<void> upgradeToOwner() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.upgradeToOwner();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        successMessage: 'Switched to Owner Mode successfully!',
      ),
    );
  }

  /// Clears any displayed error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears the success message.
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}

/// Riverpod provider for [ProfileNotifier].
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
