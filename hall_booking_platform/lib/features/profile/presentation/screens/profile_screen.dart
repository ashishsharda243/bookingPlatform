import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';
import 'package:hall_booking_platform/features/profile/presentation/providers/profile_providers.dart';
import 'package:image_picker/image_picker.dart';

/// Profile screen displaying user info with edit capability.
///
/// Shows profile picture, name, phone (read-only), email,
/// and a logout button. Supports image upload via image_picker.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Load profile on first build
    Future.microtask(() {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final user = ref.read(profileNotifierProvider).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70, // Compress to help stay under 500KB
    );

    if (pickedFile != null) {
      ref.read(profileNotifierProvider.notifier).uploadProfileImage(pickedFile);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(profileNotifierProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );

    if (mounted) {
      setState(() => _isEditing = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    // Listen for success/error messages
    ref.listen<ProfileState>(profileNotifierProvider, (prev, next) {
      if (next.successMessage != null && prev?.successMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(profileNotifierProvider.notifier).clearSuccess();
      }
      if (next.error != null && prev?.error == null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(profileNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing && profileState.user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _populateFields();
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(ProfileState profileState) {
    // Listen for auth state changes to reload profile when user logs in
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated && (prev?.isAuthenticated == false || prev == null)) {
         ref.read(profileNotifierProvider.notifier).loadProfile();
      }
    });

    final authState = ref.watch(authNotifierProvider);

    // Handle loading state
    if (profileState.isLoading && profileState.user == null) {
      return const LoadingIndicator();
    }

    // if not authenticated, show login required
    if (!authState.isAuthenticated) {
       return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Please login to view your profile',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    // Authenticated but profile not loaded yet
    final user = profileState.user;
    if (user == null) {
      // If we are authenticated but have no user and no error, reload.
      if (profileState.error == null && !profileState.isLoading) {
          Future.microtask(() => ref.read(profileNotifierProvider.notifier).loadProfile());
          return const LoadingIndicator();
      }
    }
    
    // Handle error state
    if (profileState.error != null && user == null) {
      return ErrorDisplay(
        message: profileState.error!,
        onRetry: () =>
            ref.read(profileNotifierProvider.notifier).loadProfile(),
      );
    }

    // Handle authenticated state
    if (user == null) {
      // Should not be reached given above checks, but safe fallback
      return const LoadingIndicator();
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildProfileImage(user.profileImageUrl, profileState),
          const SizedBox(height: AppSpacing.lg),
          if (_isEditing)
            _buildEditForm(user)
          else
            _buildProfileInfo(user),
          const SizedBox(height: AppSpacing.xxl),
          if (user.role != 'owner') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .upgradeToOwner();
                  
                  // Refresh auth state to pick up the new role
                  await ref.read(authNotifierProvider.notifier).refreshUser();

                  if (!mounted) return;
                  context.go('/owner');
                },
                icon: const Icon(Icons.business),
                label: const Text('Switch to Owner Mode'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/owner'),
                icon: const Icon(Icons.dashboard),
                label: const Text('Go to Owner Dashboard'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileImage(
    String? imageUrl,
    ProfileState profileState,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppColors.border,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? CachedNetworkImageProvider(imageUrl)
              : null,
          child: imageUrl == null || imageUrl.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 56,
                  color: AppColors.textHint,
                )
              : null,
        ),
        if (profileState.isUploadingImage)
          const Positioned.fill(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.black38,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: profileState.isUploadingImage ? null : _pickImage,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(dynamic user) {
    return Column(
      children: [
        _infoTile(
          icon: Icons.person_outline,
          label: 'Name',
          value: user.name,
        ),
        const Divider(height: 1),
        _infoTile(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: user.phone ?? 'Not set',
        ),
        const Divider(height: 1),
        _infoTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email ?? 'Not set',
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTypography.bodySmall),
      subtitle: Text(
        value,
        style: AppTypography.titleLarge,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }

  Widget _buildEditForm(dynamic user) {
    final profileState = ref.watch(profileNotifierProvider);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // Phone is read-only
          TextFormField(
            initialValue: user.phone ?? 'N/A',
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            enabled: false,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: profileState.isSaving
                      ? null
                      : () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: profileState.isSaving ? null : _saveProfile,
                  child: profileState.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          'Logout',
          style: AppTypography.titleMedium.copyWith(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
      ),
    );
  }
}
