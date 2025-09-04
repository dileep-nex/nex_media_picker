# Nex Media Picker

A comprehensive Flutter package for picking images, videos, and documents with compression, cropping, and theming support.

## Features

- 📸 **Image Picking**: Camera and gallery support with cropping capabilities
- 🎥 **Video Picking**: Record or select videos with compression options
- 📄 **Document Picking**: Support for various document formats
- 🗜️ **Compression**: Built-in image and video compression
- 🎨 **Theming**: Customizable light/dark themes
- 📱 **Multiple Selection**: Pick multiple files at once
- 🔧 **Highly Configurable**: Extensive customization options

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  nex_media_picker: ^0.0.1
```

Run:

```bash
flutter pub get
```

## Platform Configuration

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to record videos</string>
```

## Basic Usage

### 1. Setup Theme Provider

Wrap your app with the `MediaPickerThemeProvider`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nex_media_picker/nex_media_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaPickerThemeProvider(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
```

### 2. Single Media Selection

```dart
MediaPickerWidget(
  onMediaSelected: (MediaFile mediaFile) {
    print('Selected: ${mediaFile.name}');
    // Handle the selected media file
  },
  allowedTypes: [MediaType.image, MediaType.video, MediaType.document],
)
```

### 3. Multiple Media Selection

```dart
MediaPickerWidget(
  allowMultiple: true,
  onMultipleMediaSelected: (List<MediaFile> mediaFiles) {
    print('Selected ${mediaFiles.length} files');
    // Handle multiple media files
  },
  allowedTypes: [MediaType.image, MediaType.document],
)
```

## Advanced Configuration

### Image Compression Settings

```dart
MediaPickerWidget(
  imageCompressionSettings: ImageCompressionSettings(
    quality: 80,
    maxWidth: 1920,
    maxHeight: 1080,
    format: CompressFormat.jpeg,
  ),
  onMediaSelected: (mediaFile) {
    // Handle compressed image
  },
)
```

### Video Compression Settings

```dart
MediaPickerWidget(
  videoCompressionSettings: VideoCompressionSettings(
    quality: VideoQuality.MediumQuality,
    includeAudio: true,
    deleteOrigin: false,
  ),
  onMediaSelected: (mediaFile) {
    // Handle compressed video
  },
)
```

### Document Type Restrictions

```dart
MediaPickerWidget(
  allowedTypes: [MediaType.document],
  allowedDocumentExtensions: ['pdf', 'doc', 'docx', 'txt'],
  onMediaSelected: (mediaFile) {
    // Handle document
  },
)
```

### Custom Theme

```dart
final themeProvider = Provider.of<MediaPickerThemeProvider>(context);
themeProvider.updateTheme(
  MediaPickerTheme(
    themeMode: ThemeMode.dark,
    lightColorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    darkColorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
);
```

## Widgets

### MediaPreviewWidget

Display a preview of selected media:

```dart
MediaPreviewWidget(
  mediaFile: selectedMediaFile,
  size: 100,
  onRemove: () {
    // Remove media file
  },
)
```

### MediaGridWidget

Display multiple media files in a grid:

```dart
MediaGridWidget(
  mediaFiles: selectedMediaFiles,
  crossAxisCount: 3,
  itemSize: 100,
  onRemove: (mediaFile) {
    // Remove specific media file
  },
)
```

## MediaFile Model

The `MediaFile` class contains information about selected media:

```dart
class MediaFile {
  final File? file;           // File object (mobile platforms)
  final Uint8List? bytes;     // File bytes (web platform)
  final String? name;         // File name
  final String? path;         // File path
  final MediaType type;       // image, video, or document
  final int? size;           // File size in bytes
  final String? mimeType;    // MIME type
  final Map<String, dynamic>? metadata; // Additional metadata
}
```

## Services

You can also use the individual services directly:

### ImageService

```dart
// Pick single image
MediaFile? image = await ImageService.pickImage(
  source: ImageSource.camera,
  enableCropping: true,
  compressionSettings: ImageCompressionSettings(quality: 85),
);

// Pick multiple images
List<MediaFile> images = await ImageService.pickMultipleImages(
  compressionSettings: ImageCompressionSettings(quality: 80),
);
```

### VideoService

```dart
MediaFile? video = await VideoService.pickVideo(
  source: ImageSource.gallery,
  compressionSettings: VideoCompressionSettings(
    quality: VideoQuality.MediumQuality,
  ),
);
```

### DocumentService

```dart
// Pick single document
MediaFile? document = await DocumentService.pickDocument(
  allowedExtensions: ['pdf', 'doc'],
);

// Pick multiple documents
List<MediaFile> documents = await DocumentService.pickMultipleDocuments();
```

## Example

Check out the `/example` folder for a complete example app demonstrating all features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.