import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/media_file.dart';

class DocumentService {
  static Future<MediaFile?> pickDocument({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    FileType type = FileType.custom,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile platformFile = result.files.first;

        File? file;
        if (platformFile.path != null) {
          file = File(platformFile.path!);
        }

        return MediaFile(
          file: file,
          bytes: platformFile.bytes,
          name: platformFile.name,
          path: platformFile.path,
          type: MediaType.document,
          size: platformFile.size,
          mimeType: _getMimeType(platformFile.extension ?? ''),
          metadata: {
            'extension': platformFile.extension,
          },
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }

  static Future<List<MediaFile>> pickMultipleDocuments({
    List<String>? allowedExtensions,
    FileType type = FileType.custom,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: true,
        allowedExtensions: allowedExtensions
      );

      if (result != null && result.files.isNotEmpty) {
        List<MediaFile> mediaFiles = [];

        for (PlatformFile platformFile in result.files) {
          File? file;
          if (platformFile.path != null) {
            file = File(platformFile.path!);
          }

          mediaFiles.add(MediaFile(
            file: file,
            bytes: platformFile.bytes,
            name: platformFile.name,
            path: platformFile.path,
            type: MediaType.document,
            size: platformFile.size,
            mimeType: _getMimeType(platformFile.extension ?? ''),
            metadata: {
              'extension': platformFile.extension,
            },
          ));
        }

        return mediaFiles;
      }

      return [];
    } catch (e) {
      debugPrint('Error picking multiple documents: $e');
      return [];
    }
  }

  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      default:
        return 'application/octet-stream';
    }
  }

  static IconData getDocumentIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'csv':
        return Icons.table_view;
      case 'json':
      case 'xml':
        return Icons.code;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }
}