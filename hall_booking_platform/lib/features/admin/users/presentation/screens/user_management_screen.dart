import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/admin/users/presentation/providers/user_management_providers.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:intl/intl.dart';

/// Admin screen for managing platform users.
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userManagementNotifierProvider.notifier).loadUsers();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(userManagementNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userManagementNotifierProvider);

    ref.listen<UserManagementState>(userManagementNotifierProvider,
        (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(userManagementNotifierProvider.notifier).clearSuccess();
      }
      if (next.error != null &&
          next.error != prev?.error &&
          next.users.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(userManagementNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(userManagementNotifierProvider.notifier)
                  .loadUsers();
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(UserManagementState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.users.isEmpty) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(userManagementNotifierProvider.notifier).loadUsers();
        },
      );
    }

    if (state.users.isEmpty) {
      return const EmptyStateWidget(
        message: 'No users found.',
        icon: Icons.people_outline,
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(userManagementNotifierProvider.notifier)
                .loadUsers();
          },
          child: ListView.separated(
            controller: _scrollController,
            padding: AppSpacing.screenPadding,
            itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == state.users.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _UserCard(
                user: state.users[index],
                isProcessing: state.isProcessing,
              );
            },
          ),
        ),
        if (state.isProcessing)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

/// Card displaying a user with role change and deactivate actions.
class _UserCard extends ConsumerWidget {
  const _UserCard({
    required this.user,
    required this.isProcessing,
  });

  final AppUser user;
  final bool isProcessing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: AppTypography.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!user.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'Inactive',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.email_outlined,
              text: user.email ?? 'No email',
            ),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(
              icon: Icons.phone_outlined,
              text: user.phone ?? 'N/A',
            ),
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: 'Registered: ${dateFormat.format(user.createdAt)}',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _RoleDropdown(
                    currentRole: user.role,
                    isDisabled: isProcessing || !user.isActive,
                    onChanged: (newRole) {
                      if (newRole != null && newRole != user.role) {
                        _showRoleChangeDialog(context, ref, newRole);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (user.isActive)
                  OutlinedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : () => _showDeactivateDialog(context, ref),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Deactivate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(
    BuildContext context,
    WidgetRef ref,
    String newRole,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change User Role'),
        content: Text(
          'Change ${user.name}\'s role from "${user.role}" to "$newRole"?\n\n'
          'New RBAC permissions will be enforced immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref
                  .read(userManagementNotifierProvider.notifier)
                  .updateUserRole(user.id, newRole);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text(
          'Deactivate ${user.name}\'s account?\n\n'
          'This will prevent the user from logging in and cancel all '
          'their active bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref
                  .read(userManagementNotifierProvider.notifier)
                  .deactivateUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}

/// A simple info row with an icon and text.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Dropdown for selecting a user role.
class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({
    required this.currentRole,
    required this.isDisabled,
    required this.onChanged,
  });

  final String currentRole;
  final bool isDisabled;
  final ValueChanged<String?> onChanged;

  static const _roles = ['user', 'owner', 'admin'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: currentRole,
      decoration: InputDecoration(
        labelText: 'Role',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        isDense: true,
        enabled: !isDisabled,
      ),
      items: _roles
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(
                  role[0].toUpperCase() + role.substring(1),
                  style: AppTypography.bodyMedium,
                ),
              ))
          .toList(),
      onChanged: isDisabled ? null : onChanged,
    );
  }
}
