import 'dart:typed_data';

enum FileType { hjson, image, json }

class ProjectFile {
  String name;
  String content;
  Uint8List? binaryContent;
  FileType type;

  ProjectFile({
    required this.name,
    this.content = '',
    this.binaryContent,
    required this.type,
  });

  bool get isImage => type == FileType.image;
}
