import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';

/// Service for compressing images to meet the platform's 500KB maximum
/// upload size (Requirement 18.2).
///
/// Uses [FlutterImageCompress] to iteratively reduce quality until the
/// image fits within [AppConstants.maxImageSizeBytes].
class ImageCompressionService {
  /// Compresses [imageBytes] to at most [AppConstants.maxImageSizeBytes].
  ///
  /// The algorithm reduces JPEG quality in steps (90 → 70 → 50 → 30 → 10)
  /// while also constraining dimensions to [maxDimension] pixels on the
  /// longest side. Returns the original bytes if they are already within
  /// the size limit.
  ///
  /// Throws [ImageCompressionException] if the image cannot be compressed
  /// below the threshold after all quality steps.
  Future<Uint8List> compress(
    Uint8List imageBytes, {
    int maxBytes = AppConstants.maxImageSizeBytes,
    int maxDimension = 1920,
  }) async {
    if (imageBytes.lengthInBytes <= maxBytes) {
      return imageBytes;
    }

    const qualitySteps = [90, 70, 50, 30, 10];

    for (final quality in qualitySteps) {
      final compressed = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed.lengthInBytes <= maxBytes) {
        return compressed;
      }
    }

    // Last resort: aggressively shrink dimensions
    final lastResort = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 800,
      minHeight: 800,
      quality: 10,
      format: CompressFormat.jpeg,
    );

    if (lastResort.lengthInBytes <= maxBytes) {
      return lastResort;
    }

    throw ImageCompressionException(
      'Unable to compress image below ${maxBytes ~/ 1024}KB. '
      'Final size: ${lastResort.lengthInBytes ~/ 1024}KB.',
    );
  }
}

/// Exception thrown when image compression fails to meet the size target.
class ImageCompressionException implements Exception {
  const ImageCompressionException(this.message);
  final String message;

  @override
  String toString() => 'ImageCompressionException: $message';
}

/// Riverpod provider for [ImageCompressionService].
final imageCompressionServiceProvider =
    Provider<ImageCompressionService>((ref) {
  return ImageCompressionService();
});
