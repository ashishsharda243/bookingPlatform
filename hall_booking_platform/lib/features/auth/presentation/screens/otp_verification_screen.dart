import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/theme/app_colors.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/theme/app_typography.dart';
import 'package:hall_booking_platform/features/auth/presentation/providers/auth_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

/// OTP verification screen with 6-digit input and countdown timer for resend.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isSignUp = false,
  });

  final String email;
  final bool isSignUp;
//...
  static const String routePath = '/otp-verification';
  static const int otpLength = 8;
  static const int resendCountdownSeconds = 60;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _remainingSeconds = OtpVerificationScreen.resendCountdownSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _remainingSeconds = OtpVerificationScreen.resendCountdownSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _onVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != OtpVerificationScreen.otpLength) return;

    await ref.read(authNotifierProvider.notifier).verifyOtp(
          widget.email,
          otp,
          type: widget.isSignUp ? OtpType.signup : OtpType.email,
        );
  }

  Future<void> _onResendOtp() async {
    if (!_canResend) return;
    await ref.read(authNotifierProvider.notifier).sendOtp(widget.email);
    _startResendTimer();
  }

  String get _formattedTimer {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Masks the email for display, e.g. a***@gmail.com.
  String get _maskedEmail {
    final email = widget.email;
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final name = parts[0];
    final domain = parts[1];
    
    if (name.length <= 2) return '$name***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Navigate away on successful authentication.
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated && !(prev?.isAuthenticated ?? false)) {
        // Pop back to root — the router/splash will handle redirection.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(authNotifierProvider.notifier).resetOtpState();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Icon
              const Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Enter verification code',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We sent a ${OtpVerificationScreen.otpLength}-digit code to $_maskedEmail',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // OTP input field
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  letterSpacing: 12,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                      OtpVerificationScreen.otpLength),
                ],
                decoration: const InputDecoration(
                  hintText: '--------', // Updated hint for 8 chars
                  counterText: '',
                ),
                maxLength: OtpVerificationScreen.otpLength,
                onChanged: (value) {
                  // Auto-verify when all digits entered.
                  if (value.length == OtpVerificationScreen.otpLength) {
                    _onVerifyOtp();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Error message
              if (authState.error != null) ...[
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Verify button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading || authState.isLocked
                      ? null
                      : _onVerifyOtp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Resend OTP with countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTypography.bodyMedium,
                  ),
                  if (_canResend)
                    GestureDetector(
                      onTap: _onResendOtp,
                      child: Text(
                        'Resend',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in $_formattedTimer',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                ],
              ),

              // Lockout warning
              if (authState.isLocked) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Account temporarily locked due to too many failed attempts. Please try again later.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
