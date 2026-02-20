import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/services/image_compression_service.dart';

void main() {
  group('ImageCompressionService', () {
    late ImageCompressionService service;

    setUp(() {
      service = ImageCompressionService();
    });

    test('returns original bytes when already under maxBytes', () async {
      final smallImage = Uint8List(100 * 1024); // 100KB — well under 500KB
      final result = await service.compress(smallImage);
      expect(identical(result, smallImage), isTrue,
          reason: 'Should return the exact same reference');
    });

    test('returns original bytes when exactly at maxBytes', () async {
      final exactImage = Uint8List(AppConstants.maxImageSizeBytes);
      final result = await service.compress(exactImage);
      expect(identical(result, exactImage), isTrue);
    });

    test('maxImageSizeBytes constant is 500KB', () {
      expect(AppConstants.maxImageSizeBytes, 500 * 1024);
    });
  });

  group('ImageCompressionException', () {
    test('toString includes message', () {
      const exception = ImageCompressionException('test error');
      expect(exception.toString(), contains('test error'));
      expect(exception.toString(), contains('ImageCompressionException'));
    });

    test('message is accessible', () {
      const exception = ImageCompressionException('size exceeded');
      expect(exception.message, 'size exceeded');
    });
  });
}
