import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as compress;
import 'package:path_provider/path_provider.dart';
import '../models/media_file.dart';
import '../models/compression_settings.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<MediaFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    bool enableCropping = true,
    ImageCompressionSettings? compressionSettings,
    bool isDarkMode = false,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      File imageFile = File(pickedFile.path);

      if (enableCropping) {
        final croppedFile = await _cropImage(imageFile, isDarkMode);
        if (croppedFile != null) {
          imageFile = File(croppedFile.path);
        } else{
          return null;
        }
      }

      if (compressionSettings != null) {
        final compressedFile = await _compressImage(imageFile, compressionSettings);
        if (compressedFile != null) {
          imageFile = compressedFile;
        }
      }

      return MediaFile(
        file: imageFile,
        name: imageFile.path.split('/').last,
        path: imageFile.path,
        type: MediaType.image,
        size: await imageFile.length(),
        mimeType: _getMimeType(imageFile.path),
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<List<MediaFile>> pickMultipleImages({
    bool enableCropping = false,
    ImageCompressionSettings? compressionSettings,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      List<MediaFile> mediaFiles = [];

      for (XFile file in pickedFiles) {
        File imageFile = File(file.path);

        if (compressionSettings != null) {
          final compressedFile = await _compressImage(imageFile, compressionSettings);
          if (compressedFile != null) {
            imageFile = compressedFile;
          }
        }

        mediaFiles.add(MediaFile(
          file: imageFile,
          name: imageFile.path.split('/').last,
          path: imageFile.path,
          type: MediaType.image,
          size: await imageFile.length(),
          mimeType: _getMimeType(imageFile.path),
        ));
      }

      return mediaFiles;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  static Future<CroppedFile?> _cropImage(File imageFile, bool isDarkMode) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: isDarkMode ? Colors.black : Colors.white,
          toolbarWidgetColor: isDarkMode ? Colors.white : Colors.black,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          activeControlsWidgetColor: const Color(0xFF1976D2),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );
  }

  static Future<File?> _compressImage(
      File imageFile,
      ImageCompressionSettings settings,
      ) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await compress.FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: settings.quality,
        // minWidth: settings.maxWidth,
        // minHeight: settings.maxHeight,
        rotate: settings.rotate ? 90 : 0,
        format: _getCompressFormat(settings.format),
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  static compress.CompressFormat _getCompressFormat(CompressFormat format) {
    switch (format) {
      case CompressFormat.jpeg:
        return compress.CompressFormat.jpeg;
      case CompressFormat.png:
        return compress.CompressFormat.png;
      case CompressFormat.heic:
        return compress.CompressFormat.heic;
      case CompressFormat.webp:
        return compress.CompressFormat.webp;
    }
  }

  static String _getMimeType(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}