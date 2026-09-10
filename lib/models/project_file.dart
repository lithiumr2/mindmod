import 'dart:convert';
import 'dart:typed_data';

enum FileType {
  block,
  item,
  liquid,
  modJson,
  image,
  other,
}

class ProjectFile {
  final String name;
  String content;
  final FileType type;

  ProjectFile({
    required this.name,
    this.content = '',
    required this.type,
  });

  bool get isImage => type == FileType.image || name.startsWith('sprites/');

  Uint8List? get binaryContent {
    if (!isImage || content.isEmpty) return null;
    try {
      return base64Decode(content);
    } catch (_) {
      return null;
    }
  }
}
