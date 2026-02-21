import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  /// Compresses an image file.
  /// 
  /// Returns the compressed [XFile] or the original if compression fails or isn't supported.
  /// On web, it currently returns the original file as flutter_image_compress has limited web support 
  /// without extra setup, but XFile is already optimal for web uploads.
  static Future<XFile> compressImage(XFile file) async {
    // Return original on web for now, or if it's not an image
    if (kIsWeb) {
      return file; 
    }

    final filePath = file.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.pn|.webp|.heic'));
    if (lastIndex == -1) return file; // Not an image or unknown extension

    final splitName = filePath.substring(0, (lastIndex));
    final outPath = '${splitName}_out${filePath.substring(lastIndex)}';

    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        outPath,
        quality: 70, // 70% quality
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result != null) {
        return result;
      }
    } catch (e) {
      debugPrint('Image compression failed: $e');
    }

    return file;
  }

  /// Compresses a list of images.
  static Future<List<XFile>> compressImages(List<XFile> files) async {
    final futures = files.map((file) => compressImage(file));
    return Future.wait(futures);
  }
}
