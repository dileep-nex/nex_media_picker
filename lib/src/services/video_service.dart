import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart' as video_compress;
import '../models/media_file.dart';
import '../models/compression_settings.dart';

class VideoService {
  static final ImagePicker _picker = ImagePicker();
  // Original single video picker
  static Future<MediaFile?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
    VideoCompressionSettings? compressionSettings,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
      if (pickedFile == null) return null;
      File videoFile = File(pickedFile.path);
      if (compressionSettings != null) {
        final compressedFile = await _compressVideo(videoFile, compressionSettings);
        if (compressedFile != null) {
          videoFile = compressedFile;
        }
      }

      // Get video thumbnail
      File? thumbnailFile;
      try {
        thumbnailFile = await video_compress.VideoCompress.getFileThumbnail(
          videoFile.path,
          quality: 25,
        );
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
      }
      return MediaFile(
        file: videoFile,
        name: videoFile.path.split('/').last,
        path: videoFile.path,
        type: MediaType.video,
        size: await videoFile.length(),
        mimeType: 'video/mp4',
        metadata: {
          'thumbnail': thumbnailFile?.path,
          'duration': await _getVideoDuration(videoFile),
        },
      );
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  // Multi-video picker
  static Future<List<MediaFile>> pickMultipleVideos({
    int? maxVideos,
    VideoCompressionSettings? compressionSettings,
    bool showProgressDialog = false,
    BuildContext? context,
    Function(int,int)? compressed
  }) async {

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiVideo(
      );
      if (pickedFiles.isEmpty) return [];
      // Limit the number of videos if specified
      if (maxVideos != null && pickedFiles.length > maxVideos) {
        pickedFiles.removeRange(maxVideos, pickedFiles.length);
      }

      final List<MediaFile> mediaFiles = [];
      for (int i = 0; i < pickedFiles.length; i++) {
        final xFile = pickedFiles[i];
        print("multi video Processing:");
        if (showProgressDialog && context != null) {
          _showProgressDialog(context, 'Processing video ${i + 1} of ${pickedFiles.length}');
        }

        final mediaFile = await _processVideoFile(
          File(xFile.path),
          compressionSettings,
        );

        if (mediaFile != null) {
          mediaFiles.add(mediaFile);
        }
        if (showProgressDialog && context != null) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        compressed!(pickedFiles.length,i+1);
      }
      return mediaFiles;
    } catch (e) {
      debugPrint('Error picking multiple videos: $e');
      return [];
    }
  }


  // Batch compress multiple videos
  static Future<List<MediaFile>> compressMultipleVideos(
      List<MediaFile> videos,
      VideoCompressionSettings settings, {
        Function(int current, int total)? onProgress,
        BuildContext? context,
        bool showProgressDialog = false,
      }) async {
    final List<MediaFile> compressedVideos = [];

    for (int i = 0; i < videos.length; i++) {
      final video = videos[i];

      if (showProgressDialog && context != null) {
        _showProgressDialog(
          context,
          'Compressing video ${i + 1} of ${videos.length}\n${video.name}',
        );
      }
      onProgress?.call(i + 1, videos.length);
      try {
        final compressedFile = await _compressVideo(video.file!, settings);

        if (compressedFile != null) {
          // Create new MediaFile with compressed video
          final compressedMediaFile = await _processVideoFile(
            compressedFile,
            null, // Already compressed
          );

          if (compressedMediaFile != null) {
            compressedVideos.add(compressedMediaFile);
          }
        } else {
          // Keep original if compression failed
          compressedVideos.add(video);
        }
      } catch (e) {
        debugPrint('Error compressing video ${video.name}: $e');
        // Keep original if compression failed
        compressedVideos.add(video);
      }

      if (showProgressDialog && context != null) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    return compressedVideos;
  }

  // Helper method to process a single video file
  static Future<MediaFile?> _processVideoFile(
      File videoFile,
      VideoCompressionSettings? compressionSettings,
      ) async {
    try {
      File processedFile = videoFile;

      if (compressionSettings != null) {
        final compressedFile = await _compressVideo(videoFile, compressionSettings);
        if (compressedFile != null) {
          processedFile = compressedFile;
        }
      }

      // Get video thumbnail
      File? thumbnailFile;
      try {
        thumbnailFile = await video_compress.VideoCompress.getFileThumbnail(
          processedFile.path,
          quality: 25,
        );
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
      }

      return MediaFile(
        file: processedFile,
        name: processedFile.path.split('/').last,
        path: processedFile.path,
        type: MediaType.video,
        size: await processedFile.length(),
        mimeType: 'video/mp4',
        metadata: {
          'thumbnail': thumbnailFile?.path,
          'duration': await _getVideoDuration(processedFile),
        },
      );
    } catch (e) {
      debugPrint('Error processing video file: $e');
      return null;
    }
  }

  // Original compression method
  static Future<File?> _compressVideo(
      File videoFile,
      VideoCompressionSettings settings,
      ) async {
    try {
      final info = await video_compress.VideoCompress.compressVideo(
        videoFile.path,
        quality: settings.quality,
        deleteOrigin: settings.deleteOrigin,
        startTime: settings.startTime,
        duration: settings.duration,
        includeAudio: settings.includeAudio,
      );

      return info?.file;
    } catch (e) {
      debugPrint('Error compressing video: $e');
      return null;
    }
  }

  static Future<int?> _getVideoDuration(File videoFile) async {
    try {
      final info = await video_compress.VideoCompress.getMediaInfo(videoFile.path);
      return info.duration?.toInt();
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      return null;
    }
  }

  // Utility method to show progress dialog
  static void _showProgressDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

}