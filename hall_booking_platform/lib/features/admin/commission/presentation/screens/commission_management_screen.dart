import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/core/widgets/error_display.dart';
import 'package:hall_booking_platform/core/widgets/loading_indicator.dart';
import 'package:hall_booking_platform/features/admin/commission/presentation/providers/commission_providers.dart';

/// Admin screen for viewing and updating the platform commission percentage.
class CommissionManagementScreen extends ConsumerStatefulWidget {
  const CommissionManagementScreen({super.key});

  @override
  ConsumerState<CommissionManagementScreen> createState() =>
      _CommissionManagementScreenState();
}

class _CommissionManagementScreenState
    extends ConsumerState<CommissionManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(commissionNotifierProvider.notifier).loadCommission();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commissionNotifierProvider);

    ref.listen<CommissionState>(commissionNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(commissionNotifierProvider.notifier).clearSuccess();
      }
      if (next.error != null &&
          next.error != prev?.error &&
          next.currentPercentage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(commissionNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commission Management'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CommissionState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.currentPercentage == null) {
      return ErrorDisplay(
        message: state.error!,
        onRetry: () {
          ref.read(commissionNotifierProvider.notifier).loadCommission();
        },
      );
    }

    final currentRate = state.currentPercentage ?? 0.0;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // Current rate display card
        Card(
          elevation: AppSpacing.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              children: [
                Text('Current Commission Rate', style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${currentRate.toStringAsFixed(1)}%',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Applied to all future bookings',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Update form
        Card(
          elevation: AppSpacing.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Update Commission Rate',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Commission (%)',
                      hintText: 'Enter percentage (0-100)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a commission percentage';
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsed < 0 || parsed > 100) {
                        return 'Commission must be between 0 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: state.isUpdating ? null : _onSubmit,
                    child: state.isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update Commission'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final percentage = double.parse(_controller.text.trim());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Commission Update'),
        content: Text(
          'Update the platform commission rate to '
          '${percentage.toStringAsFixed(1)}%?\n\n'
          'This will apply to all future bookings.',
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
                  .read(commissionNotifierProvider.notifier)
                  .updateCommission(percentage);
              _controller.clear();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
