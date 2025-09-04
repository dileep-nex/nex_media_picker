import 'package:video_compress/video_compress.dart';

class ImageCompressionSettings {
  final int quality;
  final int? maxWidth;
  final int? maxHeight;
  final bool rotate;
  final CompressFormat format;

  const ImageCompressionSettings({
    this.quality = 85,
    this.maxWidth,
    this.maxHeight,
    this.rotate = false,
    this.format = CompressFormat.jpeg,
  });

  @override
  String toString() {
    return 'ImageCompressionSettings(quality: $quality, maxWidth: $maxWidth, maxHeight: $maxHeight, rotate: $rotate, format: $format)';
  }
}

class VideoCompressionSettings {
  final VideoQuality quality;
  final bool deleteOrigin;
  final int? startTime;
  final int? duration;
  final bool includeAudio;

  const VideoCompressionSettings({
    this.quality = VideoQuality.DefaultQuality,
    this.deleteOrigin = false,
    this.startTime,
    this.duration,
    this.includeAudio = true,
  });

  @override
  String toString() {
    return 'VideoCompressionSettings(quality: $quality, deleteOrigin: $deleteOrigin, startTime: $startTime, duration: $duration, includeAudio: $includeAudio)';
  }
}

enum CompressFormat { jpeg, png, heic, webp }

