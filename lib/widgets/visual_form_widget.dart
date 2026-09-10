import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/project_provider.dart';

class VisualFormWidget extends ConsumerStatefulWidget {
  const VisualFormWidget({super.key});

  @override
  ConsumerState<VisualFormWidget> createState() => _VisualFormWidgetState();
}

class _VisualFormWidgetState extends ConsumerState<VisualFormWidget> {
  final Map<String, TextEditingController> _controllers = {};

  // Esquema de propiedades según la categoría o tipo
  final Map<String, List<String>> _categorySuggestions = {
    'blocks': ['health', 'size', 'solid', 'destructible', 'canOverdrive', 'hasItems', 'hasLiquids'],
    'items': ['cost', 'flammability', 'explosiveness', 'radioactivity', 'charge'],
    'liquids': ['color', 'viscosity', 'temperature', 'heatCapacity', 'explosiveness', 'flammability'],
  };

  final List<String> _booleanKeys = [
    'solid', 'destructible', 'canOverdrive', 'hasItems', 'hasLiquids', 'hasPower'
  ];

  final List<String> _numberKeys = [
    'health', 'size', 'cost', 'flammability', 'explosiveness', 'radioactivity', 'charge', 'viscosity', 'temperature', 'heatCapacity'
  ];

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> _parseHjson(String content) {
    final Map<String, String> map = {};
    final lines = content.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('}') || trimmed.isEmpty) continue;
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim().replaceAll('"', '');
        map[key] = value;
      }
    }
    return map;
  }

  String _toHjson(Map<String, String> map) {
    final buffer = StringBuffer('{\n');
    map.forEach((key, value) {
      if (_booleanKeys.contains(key) || _numberKeys.contains(key)) {
        buffer.writeln('  $key: $value');
      } else {
        buffer.writeln('  $key: "$value"');
      }
    });
    buffer.write('}');
    return buffer.toString();
  }

  void _updateProperty(Map<String, String> map, String key, String newValue) {
    map[key] = newValue;
    ref.read(projectProvider.notifier).updateActiveFileContent(_toHjson(map));
  }

  void _removeProperty(Map<String, String> map, String key) {
    map.remove(key);
    _controllers[key]?.dispose();
    _controllers.remove(key);
    ref.read(projectProvider.notifier).updateActiveFileContent(_toHjson(map));
  }

  void _addProperty(Map<String, String> map, String key) {
    if (!map.containsKey(key)) {
      if (_booleanKeys.contains(key)) {
        map[key] = 'true';
      } else if (_numberKeys.contains(key)) {
        map[key] = '1';
      } else if (key == 'color') {
        map[key] = 'ff0000';
      } else {
        map[key] = '';
      }
      ref.read(projectProvider.notifier).updateActiveFileContent(_toHjson(map));
    }
  }

  void _openColorPicker(BuildContext context, Map<String, String> map, String key, String currentColor) {
    Color pickerColor = Colors.red;
    try {
      pickerColor = Color(int.parse('0xFF${currentColor.replaceAll('#', '')}'));
    } catch (_) {}

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202026),
        title: const Text('Pick Color', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBC02D), foregroundColor: Colors.black),
            onPressed: () {
              final hexString = pickerColor.value.toRadixString(16).substring(2);
              _updateProperty(map, key, hexString);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final activeFile = projectState.activeFile;

    if (activeFile == null) {
      return const Center(child: Text('No file selected', style: TextStyle(color: Colors.white54)));
    }

    final properties = _parseHjson(activeFile.content);

    // Determinar categoría por el nombre del archivo
    String category = 'blocks';
    if (activeFile.name.contains('item') || properties['type'] == 'Item') {
      category = 'items';
    } else if (activeFile.name.contains('liquid') || properties['type'] == 'Liquid') {
      category = 'liquids';
    }

    final suggestions = _categorySuggestions[category] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Properties (${category.toUpperCase()}):',
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((prop) {
              final isAdded = properties.containsKey(prop);
              return ActionChip(
                backgroundColor: isAdded ? Colors.amber.withOpacity(0.2) : const Color(0xFF202026),
                label: Text(
                  '+ $prop',
                  style: TextStyle(
                    color: isAdded ? Colors.amber : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                onPressed: isAdded ? null : () => _addProperty(properties, prop),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Renderizado dinámico de controles
          ...properties.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;

            Widget valueControl;

            // 1. Caso Booleano: Switch Toggle
            if (_booleanKeys.contains(key)) {
              final boolVal = value.toLowerCase() == 'true';
              valueControl = Container(
                alignment: Alignment.centerLeft,
                child: Switch(
                  value: boolVal,
                  activeColor: const Color(0xFFFBC02D),
                  onChanged: (val) => _updateProperty(properties, key, val.toString()),
                ),
              );
            } 
            // 2. Caso Color: Color Picker Button
            else if (key == 'color') {
              valueControl = GestureDetector(
                onTap: () => _openColorPicker(context, properties, key, value),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF202026),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(int.tryParse('0xFF${value.replaceAll('#', '')}') ?? 0xFFFF0000),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('#$value', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              );
            } 
            // 3. Caso Numérico o Texto General
            else {
              if (!_controllers.containsKey(key)) {
                _controllers[key] = TextEditingController(text: value);
              } else if (_controllers[key]!.text != value && value.isNotEmpty) {
                _controllers[key]!.text = value;
              }

              final isNumber = _numberKeys.contains(key);

              valueControl = TextField(
                controller: _controllers[key],
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF202026),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (val) => _updateProperty(properties, key, val),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202026),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        key,
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: valueControl,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeProperty(properties, key),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
