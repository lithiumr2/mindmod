import 'dart:convert';

/// Tipos de datos soportados por las propiedades dinámicas de los esquemas
enum PropertyDataType {
  numberInt,
  numberFloat,
  text,
  boolean,
  colorHex,
  itemPicker,
  liquidPicker,
  enumDropdown,
  primitiveList,
  objectList,
}

/// Categorías de tipos custom compatibles con Mindustry
enum CustomTypeCategory {
  block,
  unit,
  item,
  liquid,
  status,
}

/// Definición de una propiedad individual dentro de un CustomTypeSchema
class PropertyDefinition {
  final String key;
  final String label;
  final PropertyDataType type;
  final dynamic defaultValue;
  final List<String>? options;
  final List<PropertyDefinition>? nestedSchema;
  final bool isRequired;
  final String? tooltip;

  const PropertyDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.options,
    this.nestedSchema,
    this.isRequired = false,
    this.tooltip,
  });

  PropertyDefinition copyWith({
    String? key,
    String? label,
    PropertyDataType? type,
    dynamic defaultValue,
    List<String>? options,
    List<PropertyDefinition>? nestedSchema,
    bool? isRequired,
    String? tooltip,
  }) {
    return PropertyDefinition(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? (this.options != null ? List<String>.from(this.options!) : null),
      nestedSchema: nestedSchema ?? (this.nestedSchema != null ? List<PropertyDefinition>.from(this.nestedSchema!) : null),
      isRequired: isRequired ?? this.isRequired,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type.name,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (options != null) 'options': options,
      if (nestedSchema != null) 'nestedSchema': nestedSchema!.map((p) => p.toJson()).toList(),
      'isRequired': isRequired,
      if (tooltip != null) 'tooltip': tooltip,
    };
  }

  factory PropertyDefinition.fromJson(Map<String, dynamic> json) {
    PropertyDataType parsedType;
    try {
      parsedType = PropertyDataType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PropertyDataType.text,
      );
    } catch (_) {
      parsedType = PropertyDataType.text;
    }

    List<String>? parsedOptions;
    if (json['options'] is List) {
      parsedOptions = (json['options'] as List).map((e) => e.toString()).toList();
    }

    List<PropertyDefinition>? parsedNested;
    if (json['nestedSchema'] is List) {
      parsedNested = (json['nestedSchema'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => PropertyDefinition.fromJson(e))
          .toList();
    }

    return PropertyDefinition(
      key: json['key'] as String? ?? 'prop_${DateTime.now().millisecondsSinceEpoch}',
      label: json['label'] as String? ?? json['key'] as String? ?? 'Propiedad',
      type: parsedType,
      defaultValue: json['defaultValue'],
      options: parsedOptions,
      nestedSchema: parsedNested,
      isRequired: json['isRequired'] as bool? ?? false,
      tooltip: json['tooltip'] as String?,
    );
  }
}

/// Esquema para un nuevo subtipo dinámico (ej: Multi-Crafter, Flying-Boss, etc.)
class CustomTypeSchema {
  final String typeId;
  final String displayName;
  final CustomTypeCategory category;
  final List<PropertyDefinition> properties;

  const CustomTypeSchema({
    required this.typeId,
    required this.displayName,
    required this.category,
    required this.properties,
  });

  CustomTypeSchema copyWith({
    String? typeId,
    String? displayName,
    CustomTypeCategory? category,
    List<PropertyDefinition>? properties,
  }) {
    return CustomTypeSchema(
      typeId: typeId ?? this.typeId,
      displayName: displayName ?? this.displayName,
      category: category ?? this.category,
      properties: properties ?? List<PropertyDefinition>.from(this.properties),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeId': typeId,
      'displayName': displayName,
      'category': category.name,
      'properties': properties.map((p) => p.toJson()).toList(),
    };
  }

  factory CustomTypeSchema.fromJson(Map<String, dynamic> json) {
    CustomTypeCategory parsedCat;
    try {
      parsedCat = CustomTypeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => CustomTypeCategory.block,
      );
    } catch (_) {
      parsedCat = CustomTypeCategory.block;
    }

    List<PropertyDefinition> parsedProps = [];
    if (json['properties'] is List) {
      parsedProps = (json['properties'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => PropertyDefinition.fromJson(e))
          .toList();
    }

    return CustomTypeSchema(
      typeId: json['typeId'] as String? ?? 'custom-type',
      displayName: json['displayName'] as String? ?? json['typeId'] as String? ?? 'Custom Type',
      category: parsedCat,
      properties: parsedProps,
    );
  }
}

/// Inyecciones a registros globales (ítems, líquidos, categorías) provistas por un módulo
class GlobalRegistryInjection {
  final List<String> customItems;
  final List<String> customLiquids;
  final List<String> customCategories;

  const GlobalRegistryInjection({
    this.customItems = const [],
    this.customLiquids = const [],
    this.customCategories = const [],
  });

  GlobalRegistryInjection copyWith({
    List<String>? customItems,
    List<String>? customLiquids,
    List<String>? customCategories,
  }) {
    return GlobalRegistryInjection(
      customItems: customItems ?? List<String>.from(this.customItems),
      customLiquids: customLiquids ?? List<String>.from(this.customLiquids),
      customCategories: customCategories ?? List<String>.from(this.customCategories),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customItems': customItems,
      'customLiquids': customLiquids,
      'customCategories': customCategories,
    };
  }

  factory GlobalRegistryInjection.fromJson(Map<String, dynamic> json) {
    List<String> extractList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return GlobalRegistryInjection(
      customItems: extractList(json['customItems']),
      customLiquids: extractList(json['customLiquids']),
      customCategories: extractList(json['customCategories']),
    );
  }
}

/// Módulo personalizado completo (ej: MultiLib Extension, Frostburn Plugins, etc.)
class CustomModule {
  final String id;
  final String name;
  final String author;
  final String version;
  final String description;
  final bool enabled;
  final List<CustomTypeSchema> customTypes;
  final GlobalRegistryInjection globalInjections;

  const CustomModule({
    required this.id,
    required this.name,
    this.author = 'Anónimo',
    this.version = '1.0.0',
    this.description = '',
    this.enabled = true,
    this.customTypes = const [],
    this.globalInjections = const GlobalRegistryInjection(),
  });

  CustomModule copyWith({
    String? id,
    String? name,
    String? author,
    String? version,
    String? description,
    bool? enabled,
    List<CustomTypeSchema>? customTypes,
    GlobalRegistryInjection? globalInjections,
  }) {
    return CustomModule(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      version: version ?? this.version,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      customTypes: customTypes ?? List<CustomTypeSchema>.from(this.customTypes),
      globalInjections: globalInjections ?? this.globalInjections.copyWith(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'version': version,
      'description': description,
      'enabled': enabled,
      'customTypes': customTypes.map((t) => t.toJson()).toList(),
      'globalInjections': globalInjections.toJson(),
    };
  }

  factory CustomModule.fromJson(Map<String, dynamic> json) {
    List<CustomTypeSchema> types = [];
    if (json['customTypes'] is List) {
      types = (json['customTypes'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => CustomTypeSchema.fromJson(e))
          .toList();
    }

    GlobalRegistryInjection injections = const GlobalRegistryInjection();
    if (json['globalInjections'] is Map<String, dynamic>) {
      injections = GlobalRegistryInjection.fromJson(json['globalInjections'] as Map<String, dynamic>);
    }

    return CustomModule(
      id: json['id'] as String? ?? 'module_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Nuevo Módulo',
      author: json['author'] as String? ?? 'Desconocido',
      version: json['version'] as String? ?? '1.0.0',
      description: json['description'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      customTypes: types,
      globalInjections: injections,
    );
  }
}
