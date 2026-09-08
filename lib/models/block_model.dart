import 'item_requirement.dart';

class BlockModel {
  String name;
  String type;
  int health;
  int size;
  String description;
  List<ItemRequirement> requirements;
  Map<String, dynamic> extraProperties;

  BlockModel({
    required this.name,
    required this.type,
    this.health = 100,
    this.size = 1,
    this.description = '',
    List<ItemRequirement>? requirements,
    Map<String, dynamic>? extraProperties,
  })  : requirements = requirements ?? [],
        extraProperties = extraProperties ?? {};

  factory BlockModel.fromHjsonMap(Map<String, dynamic> map) {
    final name = map['name']?.toString() ?? 'custom-block';
    final type = map['type']?.toString() ?? 'Wall';
    final health = int.tryParse(map['health']?.toString() ?? '100') ?? 100;
    final size = int.tryParse(map['size']?.toString() ?? '1') ?? 1;
    final description = map['description']?.toString() ?? '';

    List<ItemRequirement> reqs = [];
    if (map['requirements'] is List) {
      reqs = (map['requirements'] as List)
          .map((e) => ItemRequirement.fromHjson(e))
          .toList();
    }

    final knownKeys = {'name', 'type', 'health', 'size', 'description', 'requirements'};
    final extras = <String, dynamic>{};
    map.forEach((key, value) {
      if (!knownKeys.contains(key)) {
        extras[key] = value;
      }
    });

    return BlockModel(
      name: name,
      type: type,
      health: health,
      size: size,
      description: description,
      requirements: reqs,
      extraProperties: extras,
    );
  }

  Map<String, dynamic> toHjsonMap() {
    final map = <String, dynamic>{
      'type': type,
      'name': name,
    };
    if (description.isNotEmpty) map['description'] = description;
    map['size'] = size;
    map['health'] = health;
    if (requirements.isNotEmpty) {
      map['requirements'] = requirements.map((r) => r.toHjsonFormat()).toList();
    }
    map.addAll(extraProperties);
    return map;
  }
}
