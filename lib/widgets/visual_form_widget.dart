import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../models/project_file.dart';

class VisualFormWidget extends ConsumerStatefulWidget {
  const VisualFormWidget({super.key});

  @override
  ConsumerState<VisualFormWidget> createState() => _VisualFormWidgetState();
}

class _VisualFormWidgetState extends ConsumerState<VisualFormWidget> {
  Map<String, dynamic> _properties = {};

  // === DICCIONARIOS DE PROPIEDADES ===

  // 1. Propiedades base por categoría
  final List<String> _itemProps = ['color', 'explosiveness', 'flammability', 'radioactivity', 'charge', 'hardness', 'cost', 'alwaysUnlocked'];
  final List<String> _liquidProps = ['color', 'temperature', 'flammability', 'explosiveness', 'viscosity', 'heatCapacity', 'barColor', 'lightColor'];
  final List<String> _baseBlockProps = ['type', 'health', 'size', 'requirements', 'category', 'solid', 'destructible', 'hasItems', 'hasLiquids', 'hasPower', 'consumesPower', 'outputsPower'];

  // 2. Tipos de bloques disponibles para el seleccionador (Dropdown)
  final List<String> _blockTypes = ['Wall', 'Drill', 'BeamDrill', 'Conveyor', 'GenericCrafter', 'ItemTurret', 'PowerNode', 'Battery', 'Router', 'Junction'];

  // 3. Propiedades específicas dependiendo del 'type' del bloque
  final Map<String, List<String>> _blockSpecificProps = {
    'Wall': ['chanceDeflect', 'flashHit'],
    'Drill': ['tier', 'drillTime', 'drawMineItem', 'liquidBoostIntensity', 'warmupSpeed'],
    'BeamDrill': ['tier', 'drillTime', 'range', 'sparkColor'],
    'Conveyor': ['speed', 'displayedSpeed'],
    'GenericCrafter': ['craftTime', 'itemCapacity', 'outputItem'],
    'ItemTurret': ['range', 'reload', 'inaccuracy', 'ammoTypes'],
  };

  @override
  void initState() {
    super.initState();
    _parseCurrentFile();
  }

  @override
  void didUpdateWidget(covariant VisualFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _parseCurrentFile();
  }

  // Analiza el texto HJSON plano y lo convierte en un mapa para la UI
  void _parseCurrentFile() {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile == null) return;

    final map = <String, dynamic>{};
    final lines = activeFile.content.split('\n');
    
    for (var line in lines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex != -1) {
        final key = line.substring(0, colonIndex).trim();
        var valueStr = line.substring(colonIndex + 1).trim();
        
        if (valueStr.startsWith('"') && valueStr.endsWith('"')) {
          map[key] = valueStr.substring(1, valueStr.length - 1);
        } else if (valueStr == 'true') {
          map[key] = true;
        } else if (valueStr == 'false') {
          map[key] = false;
        } else {
          map[key] = valueStr; // Números o strings sin comillas
        }
      }
    }
    
    // Asegurar que siempre exista la propiedad 'name'
    if (!map.containsKey('name')) {
      map['name'] = activeFile.name.replaceAll('.hjson', '');
    }

    setState(() {
      _properties = map;
    });
  }

  // Convierte el mapa modificado de vuelta a texto HJSON y lo guarda
  void _saveToFile() {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile == null) return;

    final buffer = StringBuffer();
    _properties.forEach((key, value) {
      if (value is bool) {
        buffer.writeln('$key: $value');
      } else if (key == 'name' || key == 'description' || key == 'color' || key == 'type') {
        buffer.writeln('$key: "$value"'); // Forzar comillas en textos comunes
      } else {
        buffer.writeln('$key: $value');
      }
    });

    ref.read(projectProvider.notifier).updateActiveFileContent(buffer.toString());
  }

  // Genera la lista de propiedades recomendadas según el tipo de archivo y bloque
  List<String> _getRecommendedProperties(FileType fileType) {
    List<String> recommended = [];
    
    if (fileType == FileType.item) {
      recommended = List.from(_itemProps);
    } else if (fileType == FileType.liquid) {
      recommended = List.from(_liquidProps);
    } else if (fileType == FileType.block) {
      recommended = List.from(_baseBlockProps);
      
      // Si es un bloque y tiene un 'type' definido, añadir sus propiedades específicas
      if (_properties.containsKey('type')) {
        final currentType = _properties['type'].toString().replaceAll('"', '');
        if (_blockSpecificProps.containsKey(currentType)) {
          recommended.addAll(_blockSpecificProps[currentType]!);
        }
      }
    }

    // Filtrar las que ya están agregadas en el mapa actual
    return recommended.where((prop) => !_properties.containsKey(prop)).toList();
  }

  void _addProperty(String key) {
    setState(() {
      if (key == 'solid' || key == 'destructible' || key == 'hasItems' || key == 'hasLiquids' || key == 'alwaysUnlocked') {
        _properties[key] = true; // Por defecto booleanos a true
      } else if (key == 'type') {
        _properties[key] = 'Wall'; // Por defecto Wall
      } else {
        _properties[key] = ''; // Por defecto string vacío
      }
    });
    _saveToFile();
  }

  void _removeProperty(String key) {
    setState(() {
      _properties.remove(key);
    });
    _saveToFile();
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) return const SizedBox.shrink();

    final recommendedProps = _getRecommendedProperties(activeFile.type);
    
    // Título dinámico para la sección de recomendaciones
    String categoryName = activeFile.type == FileType.item ? "ITEMS" 
                        : activeFile.type == FileType.liquid ? "LIQUIDS" 
                        : "BLOCKS";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === PANEL DE RECOMENDACIONES DEDICADO ===
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommended Properties ($categoryName):',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recommendedProps.map((prop) {
                  return InkWell(
                    onTap: () => _addProperty(prop),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+ $prop',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // === LISTA DE CAMPOS ACTUALES ===
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _properties.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la propiedad
                    Container(
                      width: 140,
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        key,
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w500),
                      ),
                    ),
                    
                    // Input / Dropdown / Switch
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF222228),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: _buildInputField(key, value, activeFile.type),
                      ),
                    ),

                    // Botón para eliminar propiedad (excepto el nombre base)
                    if (key != 'name')
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeProperty(key),
                        padding: const EdgeInsets.only(top: 8, left: 8),
                      )
                    else
                      const SizedBox(width: 48), // Espacio compensatorio
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Constructor dinámico de campos según el tipo de dato y clave
  Widget _buildInputField(String key, dynamic value, FileType fileType) {
    // 1. Si es la propiedad 'type' y es un Bloque -> Mostrar DROPDOWN (Seleccionador)
    if (key == 'type' && fileType == FileType.block) {
      String currentValue = value.toString().replaceAll('"', '');
      if (!_blockTypes.contains(currentValue)) {
        currentValue = _blockTypes.first; // Fallback por si escribieron algo raro a mano
      }

      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          dropdownColor: const Color(0xFF222228),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _properties[key] = newValue;
              });
              _saveToFile();
            }
          },
          items: _blockTypes.map<DropdownMenuItem<String>>((String typeValue) {
            return DropdownMenuItem<String>(
              value: typeValue,
              child: Text(typeValue),
            );
          }).toList(),
        ),
      );
    }

    // 2. Si es un booleano -> Mostrar SWITCH
    if (value is bool) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Switch(
          value: value,
          activeColor: Colors.amber,
          onChanged: (bool newValue) {
            setState(() {
              _properties[key] = newValue;
            });
            _saveToFile();
          },
        ),
      );
    }

    // 3. Por defecto -> Mostrar TEXTFIELD normal
    return TextFormField(
      initialValue: value.toString(),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (newValue) {
        _properties[key] = newValue;
        _saveToFile();
      },
    );
  }
}
