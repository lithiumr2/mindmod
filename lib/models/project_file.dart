import 'dart:convert';
import 'dart:typed_data';

enum FileType {
  block,
  item,
  liquid,
  modJson,
  image,
  json,
  hjson,
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

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      name: json['name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: FileType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FileType.other,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'content': content,
      'type': type.name,
    };
  }

  ProjectFile copyWith({
    String? name,
    String? content,
    FileType? type,
  }) {
    return ProjectFile(
      name: name ?? this.name,
      content: content ?? this.content,
      type: type ?? this.type,
    );
  }
}
