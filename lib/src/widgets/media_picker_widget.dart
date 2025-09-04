import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/media_file.dart';
import '../models/compression_settings.dart';
import '../services/image_service.dart';
import '../services/video_service.dart';
import '../services/document_service.dart';
import 'theme_provider.dart';

class MediaPickerWidget extends StatefulWidget {
  final Function(MediaFile)? onMediaSelected;
  final Function(List<MediaFile>)? onMultipleMediaSelected;
  final bool allowMultiple;
  final List<MediaType> allowedTypes;
  final ImageCompressionSettings? imageCompressionSettings;
  final VideoCompressionSettings? videoCompressionSettings;
  final List<String>? allowedDocumentExtensions;
  final Widget? customButton;

  const MediaPickerWidget({
    super.key,
    this.onMediaSelected,
    this.onMultipleMediaSelected,
    this.allowMultiple = false,
    this.allowedTypes = const [MediaType.image, MediaType.video, MediaType.document],
    this.imageCompressionSettings,
    this.videoCompressionSettings,
    this.allowedDocumentExtensions,
    this.customButton,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPickerThemeProvider>(
      builder: (context, themeProvider, child) {
        return widget.customButton ??
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _showMediaPicker,
              icon: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.add_a_photo),
              label: Text(widget.allowMultiple ? 'Pick Media' : 'Pick File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.currentColorScheme.primary,
                foregroundColor: themeProvider.currentColorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: themeProvider.theme.borderRadius ??
                      BorderRadius.circular(8),
                ),
              ),
            );
      },
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<MediaPickerThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            decoration: BoxDecoration(
              color: themeProvider.currentColorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: themeProvider.currentColorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Select Media',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: themeProvider.currentColorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPickerOptions(themeProvider),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickerOptions(MediaPickerThemeProvider themeProvider) {
    List<Widget> options = [];

    if (widget.allowedTypes.contains(MediaType.image)) {
      options.addAll([
        if(!widget.allowMultiple)
        _buildPickerOption(
          icon: Icons.camera_alt,
          title: 'Camera',
          subtitle: 'Take a photo',
          onTap: () => _pickImage(ImageSource.camera),
          themeProvider: themeProvider,
        ),
        _buildPickerOption(
          icon: Icons.photo_library,
          title: 'Gallery',
          subtitle: widget.allowMultiple ? 'Select photos' : 'Select a photo',
          onTap: () => widget.allowMultiple ? _pickMultipleImages() : _pickImage(ImageSource.gallery),
          themeProvider: themeProvider,
        ),
      ]);
    }

    if (widget.allowedTypes.contains(MediaType.video)) {
      options.addAll([
        if(!widget.allowMultiple)
        _buildPickerOption(
          icon: Icons.videocam,
          title: 'Record Video',
          subtitle: 'Record a new video',
          onTap: () => _pickVideo(ImageSource.camera),
          themeProvider: themeProvider,
        ),
        _buildPickerOption(
          icon: Icons.video_library,
          title: 'Video Gallery',
          subtitle: widget.allowMultiple ? 'Select videos': 'Select a video',
          onTap: () {
            widget.allowMultiple ? _pickMultiVideo(ImageSource.gallery) : _pickVideo(ImageSource.gallery);
          },
          themeProvider: themeProvider,
        ),
      ]);
    }

    if (widget.allowedTypes.contains(MediaType.document)) {
      options.add(
        _buildPickerOption(
          icon: Icons.folder,
          title: 'Documents',
          subtitle: widget.allowMultiple ? 'Select documents' : 'Select a document',
          onTap: () => widget.allowMultiple ? _pickMultipleDocuments() : _pickDocument(),
          themeProvider: themeProvider,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: options),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required MediaPickerThemeProvider themeProvider,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: themeProvider.currentColorScheme.surfaceVariant,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.currentColorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: themeProvider.currentColorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.currentColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: themeProvider.currentColorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: themeProvider.currentColorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final themeProvider = Provider.of<MediaPickerThemeProvider>(context, listen: false);
      final mediaFile = await ImageService.pickImage(
        source: source,
        enableCropping: true,
        compressionSettings: widget.imageCompressionSettings,
        isDarkMode: themeProvider.isDarkMode,
      );

      if (mediaFile != null) {
        widget.onMediaSelected?.call(mediaFile);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultipleImages() async {
    setState(() => _isLoading = true);

    try {
      final mediaFiles = await ImageService.pickMultipleImages(
        compressionSettings: widget.imageCompressionSettings,
      );

      if (mediaFiles.isNotEmpty) {
        widget.onMultipleMediaSelected?.call(mediaFiles);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final mediaFile = await VideoService.pickVideo(
        source: source,
        compressionSettings: widget.videoCompressionSettings,
      );

      if (mediaFile != null) {
        widget.onMediaSelected?.call(mediaFile);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultiVideo(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
     List<MediaFile> mediaFile = await VideoService.pickMultipleVideos(
        compressionSettings: widget.videoCompressionSettings,
        compressed: (total, count){
        }
      );

      if (mediaFile != null) {
        widget.onMultipleMediaSelected?.call(mediaFile);
      }
    }catch(e){
      if (kDebugMode) {
        print("here is error: $e");
      }

    }

    finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDocument() async {
    setState(() => _isLoading = true);

    try {
      final mediaFile = await DocumentService.pickDocument(
        allowedExtensions: widget.allowedDocumentExtensions,
        type: FileType.custom
      );

      if (mediaFile != null) {
        widget.onMediaSelected?.call(mediaFile);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultipleDocuments() async {
    setState(() => _isLoading = true);
    try {
      final mediaFiles = await DocumentService.pickMultipleDocuments(
        allowedExtensions:  widget.allowedDocumentExtensions,
      );

      if (mediaFiles.isNotEmpty) {
        widget.onMultipleMediaSelected?.call(mediaFiles);
      }
    } catch(e){
      if (kDebugMode) {
        print("here are media files3: $e");
      }
    }

    finally {
      setState(() => _isLoading = false);
    }
  }
}

class MediaPreviewWidget extends StatelessWidget {
  final MediaFile mediaFile;
  final VoidCallback? onRemove;
  final double size;

  const MediaPreviewWidget({
    super.key,
    required this.mediaFile,
    this.onRemove,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPickerThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: themeProvider.currentColorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPreviewContent(themeProvider),
              ),
              if (onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(MediaPickerThemeProvider themeProvider) {
    switch (mediaFile.type) {
      case MediaType.image:
        if (mediaFile.file != null) {
          return Image.file(
            mediaFile.file!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        } else if (mediaFile.bytes != null) {
          return Image.memory(
            mediaFile.bytes!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        }
        break;
      case MediaType.video:
        return Container(
          width: size,
          height: size,
          color: themeProvider.currentColorScheme.surfaceVariant,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_filled,
                size: size * 0.4,
                color: themeProvider.currentColorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                'Video',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.currentColorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      case MediaType.document:
        final extension = mediaFile.metadata?['extension'] as String?;
        return Container(
          width: size,
          height: size,
          color: themeProvider.currentColorScheme.surfaceVariant,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                DocumentService.getDocumentIcon(extension),
                size: size * 0.4,
                color: themeProvider.currentColorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                extension?.toUpperCase() ?? 'FILE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
    }

    return Container(
      width: size,
      height: size,
      color: themeProvider.currentColorScheme.surfaceVariant,
      child: Icon(
        Icons.error,
        color: themeProvider.currentColorScheme.error,
      ),
    );
  }
}

class MediaGridWidget extends StatelessWidget {
  final List<MediaFile> mediaFiles;
  final Function(MediaFile)? onRemove;
  final double itemSize;
  final int crossAxisCount;

  const MediaGridWidget({
    super.key,
    required this.mediaFiles,
    this.onRemove,
    this.itemSize = 100,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final mediaFile = mediaFiles[index];
        return MediaPreviewWidget(
          mediaFile: mediaFile,
          size: itemSize,
          onRemove: onRemove != null ? () => onRemove!(mediaFile) : null,
        );
      },
    );
  }
}