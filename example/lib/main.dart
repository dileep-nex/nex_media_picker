import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nex_media_picker/nex_media_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaPickerThemeProvider(),
      child: Consumer<MediaPickerThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Nex Media Picker',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.theme.themeMode,
            home: const MediaPickerDemo(),
          );
        },
      ),
    );
  }
}

class MediaPickerDemo extends StatefulWidget {
  const MediaPickerDemo({super.key});

  @override
  State<MediaPickerDemo> createState() => _MediaPickerDemoState();
}

class _MediaPickerDemoState extends State<MediaPickerDemo> {
  List<MediaFile> selectedMedia = [];
  //
  // final video_compress.Subscription? _progressSubscription = video_compress.VideoCompress.compressProgress$.subscribe((progress) {
  // print('Compression progress: ${(progress ).toStringAsFixed(1)}%');
  // // Update your UI here
  // // progress is a double between 0.0 and 1.0
  // });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<MediaPickerThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nex Media Picker Demo'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleThemeMode(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Single Media Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MediaPickerWidget(
              allowedTypes: const [MediaType.image, MediaType.video, MediaType.document,],
              allowedDocumentExtensions: const ['pdf', 'doc', 'docx', 'txt'],
              imageCompressionSettings: const ImageCompressionSettings(
                quality: 80,
                maxWidth: 1920,
                maxHeight: 1080,
              ),
              videoCompressionSettings:  VideoCompressionSettings(
                quality: VideoQuality.LowQuality,
                includeAudio: true,
              ),
              onMediaSelected: (mediaFile) {
                setState(() {
                  selectedMedia.add(mediaFile);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: ${mediaFile.name}')),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Multiple Media Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MediaPickerWidget(
              allowMultiple: true,
              allowedTypes: const [MediaType.image, MediaType.document, MediaType.video],
              allowedDocumentExtensions: const ['pdf', 'doc', 'docx', 'txt'],
              imageCompressionSettings: const ImageCompressionSettings(
                quality: 80,
                maxWidth: 1920,
                maxHeight: 1080,
              ),
              videoCompressionSettings: VideoCompressionSettings(
                quality: VideoQuality.LowQuality,
                includeAudio: true,
              ),
              onMultipleMediaSelected: (mediaFiles) {
                setState(() {
                  selectedMedia.addAll(mediaFiles);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected ${mediaFiles.length} files')),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Media',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (selectedMedia.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedMedia.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedMedia.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.abc,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No media selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )
            else
              MediaGridWidget(
                mediaFiles: selectedMedia,
                crossAxisCount: 3,
                itemSize: 100,
                onRemove: (mediaFile) {
                  setState(() {
                    selectedMedia.remove(mediaFile);
                  });
                },
              ),
            const SizedBox(height: 32),
            if (selectedMedia.isNotEmpty) ...[
              const Text(
                'Media Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...selectedMedia.map((media) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getMediaIcon(media.type),
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              media.name ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Type: ${media.type.name.toUpperCase()}'),
                      Text('Size: ${_formatFileSize(media.size)}'),
                      if (media.mimeType != null)
                        Text('MIME Type: ${media.mimeType}'),
                      if (media.metadata != null && media.metadata!.isNotEmpty)
                        Text('Metadata: ${media.metadata}'),
                    ],
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMediaIcon(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.video_file;
      case MediaType.document:
        return Icons.description;
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
