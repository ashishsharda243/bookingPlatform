class AppConstants {
  static const String appName = 'Hall Booking Platform';
  static const bool enablePublicAccess =
      bool.fromEnvironment('ENABLE_PUBLIC_ACCESS', defaultValue: false);
  static const int searchDebounceDurationMs = 300;
  static const double defaultSearchRadiusKm = 50.0;
  static const int defaultPageSize = 20;
  static const int maxImagesPerHall = 10;
  static const int maxImageSizeBytes = 500 * 1024;
  static const int cacheTtlMinutes = 5;
  static const int defaultSlotDurationMinutes = 60;
  
  static const int accountLockMinutes = 15;
  static const int maxAuthAttempts = 5;
  static const int cancellationWindowHours = 24;
}
