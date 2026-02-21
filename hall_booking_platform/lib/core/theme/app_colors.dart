import 'package:flutter/material.dart';

/// Application color palette.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Secondary
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF6EE7B7);
  static const Color secondaryDark = Color(0xFF047857);

  // Neutral
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Slot status
  static const Color slotAvailable = Color(0xFF10B981);
  static const Color slotBooked = Color(0xFFEF4444);
  static const Color slotBlocked = Color(0xFF6B7280);
}
