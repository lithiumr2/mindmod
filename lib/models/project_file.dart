enum FileType { json, hjson, image }

class ProjectFile {
  final String name;
  final FileType type;
  final String content;

  ProjectFile({
    required this.name,
    required this.type,
    required this.content,
  });

  bool get isImage => type == FileType.image;

  ProjectFile copyWith({String? name, FileType? type, String? content}) {
    return ProjectFile(
      name: name ?? this.name,
      type: type ?? this.type,
      content: content ?? this.content,
    );
  }

  // Convierte el objeto a JSON para guardarlo
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.index,
        'content': content,
      };

  // Crea el objeto desde el JSON guardado
  factory ProjectFile.fromJson(Map<String, dynamic> json) => ProjectFile(
        name: json['name'],
        type: FileType.values[json['type']],
        content: json['content'],
      );
}
