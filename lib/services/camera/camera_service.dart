import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';

/// Service for camera operations and image processing
class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Check and request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  /// Check and request gallery permission
  Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;

    final result = await Permission.photos.request();
    return result.isGranted || result.isLimited;
  }

  /// Capture image from camera
  Future<Result<CapturedImage>> captureFromCamera() async {
    try {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        return Result.failure(
          const PermissionFailure(
            message: 'Camera permission required. Enable in settings.',
          ),
        );
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        return Result.failure(
          const ImageProcessingFailure(message: 'Capture cancelled'),
        );
      }

      return _processImage(image);
    } catch (e) {
      return Result.failure(
        ImageProcessingFailure(message: 'Camera error: ${e.toString()}'),
      );
    }
  }

  /// Pick image from gallery
  Future<Result<CapturedImage>> pickFromGallery() async {
    try {
      final hasPermission = await requestGalleryPermission();
      if (!hasPermission) {
        return Result.failure(
          const PermissionFailure(
            message: 'Photo library permission required.',
          ),
        );
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        return Result.failure(
          const ImageProcessingFailure(message: 'Selection cancelled'),
        );
      }

      return _processImage(image);
    } catch (e) {
      return Result.failure(
        ImageProcessingFailure(message: 'Gallery error: ${e.toString()}'),
      );
    }
  }

  /// Process and compress image for API
  Future<Result<CapturedImage>> _processImage(XFile image) async {
    try {
      final originalBytes = await image.readAsBytes();

      // Compress image for API
      final compressedBytes = await compressImage(originalBytes);

      // Save compressed image locally
      final savedPath = await _saveImage(compressedBytes);

      return Result.success(
        CapturedImage(
          originalPath: image.path,
          compressedPath: savedPath,
          compressedBytes: compressedBytes,
          originalSize: originalBytes.length,
          compressedSize: compressedBytes.length,
        ),
      );
    } catch (e) {
      return Result.failure(
        ImageProcessingFailure(message: 'Processing failed: ${e.toString()}'),
      );
    }
  }

  /// Compress image bytes for API transmission
  Future<Uint8List> compressImage(Uint8List bytes) async {
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: AppConstants.maxImageWidth,
      minHeight: AppConstants.maxImageHeight,
      quality: AppConstants.imageQuality,
      format: CompressFormat.jpeg,
    );

    return result;
  }

  /// Save image to app documents directory
  Future<String> _saveImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/food_images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName = 'food_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${imagesDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// Delete a saved image
  Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore deletion errors
    }
  }

  /// Clean up old images (older than 30 days)
  Future<int> cleanupOldImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/food_images');

      if (!await imagesDir.exists()) return 0;

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      int deletedCount = 0;

      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      return deletedCount;
    } catch (_) {
      return 0;
    }
  }
}

/// Represents a captured and processed image
class CapturedImage {
  final String originalPath;
  final String compressedPath;
  final Uint8List compressedBytes;
  final int originalSize;
  final int compressedSize;

  const CapturedImage({
    required this.originalPath,
    required this.compressedPath,
    required this.compressedBytes,
    required this.originalSize,
    required this.compressedSize,
  });

  /// Compression ratio achieved
  double get compressionRatio => compressedSize / originalSize;

  /// Human-readable size saved
  String get sizeSaved {
    final saved = originalSize - compressedSize;
    if (saved < 1024) return '${saved}B';
    if (saved < 1024 * 1024) return '${(saved / 1024).toStringAsFixed(1)}KB';
    return '${(saved / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
