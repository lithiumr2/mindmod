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
  String? _lastLoadedFileName;

  // === DICCIONARIOS COMPLETOS DE MINDUSTRY ===

  // 1. Propiedades base estrictas por categoría
  final List<String> _itemProps = [
    'color', 'explosiveness', 'flammability', 'radioactivity', 
    'charge', 'cost', 'alwaysUnlocked', 'frames', 'transitionDamage'
  ];

  final List<String> _liquidProps = [
    'color', 'temperature', 'flammability', 'explosiveness', 
    'viscosity', 'heatCapacity', 'barColor', 'lightColor', 'effect'
  ];

  final List<String> _baseBlockProps = [
    'type', 'health', 'size', 'requirements', 'category', 
    'solid', 'destructible', 'hasItems', 'hasLiquids', 
    'hasPower', 'consumesPower', 'outputsPower', 'itemCapacity', 'liquidCapacity'
  ];

  // 2. Tipos ampliados de bloques en Mindustry
  final List<String> _blockTypes = [
    'Wall', 'Drill', 'BeamDrill', 'Conveyor', 'Router', 'Junction', 
    'BridgeConveyor', 'GenericCrafter', 'ItemTurret', 'LiquidTurret', 
    'PowerNode', 'Battery', 'Generator', 'NuclearReactor', 'Mender', 'OverdriveProjector'
  ];

  // 3. Propiedades específicas por tipo de bloque
  final Map<String, List<String>> _blockSpecificProps = {
    'Wall': ['chanceDeflect', 'flashHit', 'insulated', 'absorbLasers'],
    'Drill': ['tier', 'drillTime', 'warmupSpeed', 'liquidBoostIntensity', 'drawMineItem', 'updateEffect'],
    'BeamDrill': ['tier', 'drillTime', 'range', 'sparkColor', 'pulse', 'consumeTime'],
    'Conveyor': ['speed', 'displayedSpeed'],
    'GenericCrafter': ['craftTime', 'outputItem', 'outputLiquid', 'consumes'],
    'ItemTurret': ['range', 'reload', 'inaccuracy', 'targetAir', 'targetGround', 'shootSound', 'ammoTypes'],
    'LiquidTurret': ['range', 'reload', 'inaccuracy', 'shootSound', 'ammoType'],
    'PowerNode': ['maxNodes', 'laserRange'],
    'Battery': ['emptyPower'],
    'Generator': ['powerProduction', 'itemDuration'],
    'NuclearReactor': ['heating', 'itemDuration', 'smokeThreshold'],
    'Mender': ['range', 'reload', 'healPercent'],
    'OverdriveProjector': ['range', 'speedBoost', 'useTime', 'phaseBoost', 'phaseRangeBoost'],
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

  // Analiza y limpia las propiedades estrictamente según el archivo actual
  void _parseCurrentFile() {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile == null) return;

    // Si cambió de archivo, forzamos recarga limpia
    if (_lastLoadedFileName != activeFile.name) {
      _lastLoadedFileName = activeFile.name;
      _properties.clear();
    }

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
          map[key] = valueStr;
        }
      }
    }
    
    // Asegurar propiedad name inicial
    if (!map.containsKey('name')) {
      map['name'] = activeFile.name.replaceAll('.hjson', '');
    }

    // Si es bloque y no tiene 'type', inicializarlo por defecto según su nombre o Wall
    if (activeFile.type == FileType.block && !map.containsKey('type')) {
      map['type'] = 'Wall';
    }

    setState(() {
      _properties = map;
    });
  }

  void _saveToFile() {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile == null) return;

    final buffer = StringBuffer();
    _properties.forEach((key, value) {
      if (value is bool) {
        buffer.writeln('$key: $value');
      } else if (key == 'name' || key == 'description' || key == 'color' || key == 'type' || key == 'shootSound') {
        buffer.writeln('$key: "$value"');
      } else {
        buffer.writeln('$key: $value');
      }
    });

    ref.read(projectProvider.notifier).updateActiveFileContent(buffer.toString());
  }

  // Genera recomendaciones limpias y sin contaminación cruzada entre categorías
  List<String> _getRecommendedProperties(FileType fileType) {
    List<String> recommended = [];
    
    if (fileType == FileType.item) {
      recommended = List.from(_itemProps);
    } else if (fileType == FileType.liquid) {
      recommended = List.from(_liquidProps);
    } else if (fileType == FileType.block) {
      recommended = List.from(_baseBlockProps);
      
      // Añadir propiedades específicas del tipo de bloque seleccionado
      if (_properties.containsKey('type')) {
        final currentType = _properties['type'].toString().replaceAll('"', '');
        if (_blockSpecificProps.containsKey(currentType)) {
          recommended.addAll(_blockSpecificProps[currentType]!);
        }
      }
    }

    // Retorna únicamente las propiedades que NO estén ya escritas en el mapa
    return recommended.where((prop) => !_properties.containsKey(prop)).toList();
  }

  void _addProperty(String key) {
    setState(() {
      if (key == 'solid' || key == 'destructible' || key == 'hasItems' || key == 'hasLiquids' || key == 'hasPower' || key == 'consumesPower' || key == 'outputsPower' || key == 'alwaysUnlocked' || key == 'insulated' || key == 'absorbLasers' || key == 'flashHit') {
        _properties[key] = true;
      } else if (key == 'type') {
        _properties[key] = 'Wall';
      } else if (key == 'size' || key == 'tier' || key == 'drillTime' || key == 'health') {
        _properties[key] = '1';
      } else {
        _properties[key] = '';
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
    
    String categoryName = activeFile.type == FileType.item ? "ITEMS" 
                        : activeFile.type == FileType.liquid ? "LIQUIDS" 
                        : "BLOCKS";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel de Recomendaciones dinámicas
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

        // Lista de propiedades actuales del archivo
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
                    Container(
                      width: 140,
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        key,
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w500),
                      ),
                    ),
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
                    // Permitir borrar cualquier propiedad (incluso type o name si lo desean recrear)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _removeProperty(key),
                      padding: const EdgeInsets.only(top: 8, left: 8),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String key, dynamic value, FileType fileType) {
    // Selector Dropdown estricto para la propiedad 'type' en bloques
    if (key == 'type' && fileType == FileType.block) {
      String currentValue = value.toString().replaceAll('"', '');
      if (!_blockTypes.contains(currentValue)) {
        currentValue = _blockTypes.first;
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
