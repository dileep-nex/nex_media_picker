import 'dart:io';
import 'dart:typed_data';

enum MediaType { image, video, document }

class MediaFile {
  final File? file;
  final Uint8List? bytes;
  final String? name;
  final String? path;
  final MediaType type;
  final int? size;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  MediaFile({
    this.file,
    this.bytes,
    this.name,
    this.path,
    required this.type,
    this.size,
    this.mimeType,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'type': type.toString(),
      'size': size,
      'mimeType': mimeType,
      'metadata': metadata,
    };
  }

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      name: map['name'],
      path: map['path'],
      type: MediaType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => MediaType.document,
      ),
      size: map['size'],
      mimeType: map['mimeType'],
      metadata: map['metadata'],
    );
  }

  @override
  String toString() {
    return 'MediaFile(name: $name, path: $path, type: $type, size: $size, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaFile &&
        other.path == path &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(path, name, type);
}