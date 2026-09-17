import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module_schema.dart';
import '../providers/module_registry_provider.dart';

/// Renderizador Polimórfico de Formularios Dinámicos guiados por Esquemas (Schema-Driven UI)
class DynamicTypeFormWidget extends ConsumerWidget {
  final CustomTypeSchema schema;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool isNested;

  const DynamicTypeFormWidget({
    super.key,
    required this.schema,
    required this.data,
    required this.onChanged,
    this.isNested = false,
  });

  void _updateValue(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(data);
    if (value == null) {
      updated.remove(key);
    } else {
      updated[key] = value;
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Detectamos claves duplicadas para aislamiento y protección
    final Set<String> seenKeys = {};
    final List<Widget> fieldWidgets = [];

    for (final prop in schema.properties) {
      if (seenKeys.contains(prop.key)) {
        fieldWidgets.add(
          _buildErrorFallback(
            'Clave duplicada: "${prop.key}". Esta propiedad ha sido aislada para evitar colisiones.',
          ),
        );
        continue;
      }
      seenKeys.add(prop.key);

      try {
        fieldWidgets.add(_buildPropertyField(context, ref, prop));
      } catch (e) {
        fieldWidgets.add(
          _buildErrorFallback(
            'Error renderizando propiedad "${prop.label}" (${prop.key}): $e',
          ),
        );
      }
    }

    if (isNested) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fieldWidgets,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF388BFD).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del tipo dinámico con etiqueta de Schema
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF388BFD).withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.extension_outlined, size: 15, color: Color(0xFF58A6FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    schema.displayName,
                    style: const TextStyle(
                      color: Color(0xFF58A6FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    'type: ${schema.typeId}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fieldWidgets.isEmpty
                  ? [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Este tipo dinámico no define propiedades personalizadas.',
                            style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    ]
                  : fieldWidgets,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyField(BuildContext context, WidgetRef ref, PropertyDefinition prop) {
    final rawValue = data[prop.key] ?? prop.defaultValue;

    Widget control;

    switch (prop.type) {
      case PropertyDataType.numberInt:
        control = _buildIntInput(prop, rawValue);
        break;
      case PropertyDataType.numberFloat:
        control = _buildFloatInput(prop, rawValue);
        break;
      case PropertyDataType.text:
        control = _buildTextInput(prop, rawValue);
        break;
      case PropertyDataType.boolean:
        control = _buildBooleanSwitch(prop, rawValue);
        break;
      case PropertyDataType.colorHex:
        control = _buildColorHexInput(context, prop, rawValue);
        break;
      case PropertyDataType.itemPicker:
        control = _buildItemPicker(ref, prop, rawValue);
        break;
      case PropertyDataType.liquidPicker:
        control = _buildLiquidPicker(ref, prop, rawValue);
        break;
      case PropertyDataType.enumDropdown:
        control = _buildEnumDropdown(prop, rawValue);
        break;
      case PropertyDataType.primitiveList:
        control = _buildPrimitiveList(prop, rawValue);
        break;
      case PropertyDataType.objectList:
        control = _buildObjectList(prop, rawValue);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                prop.label,
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              if (prop.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              const SizedBox(width: 6),
              Text(
                '(${prop.key})',
                style: const TextStyle(color: Colors.white30, fontSize: 10, fontFamily: 'monospace'),
              ),
              if (prop.tooltip != null && prop.tooltip!.isNotEmpty) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: prop.tooltip!,
                  child: const Icon(Icons.info_outline, size: 13, color: Colors.white38),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          control,
        ],
      ),
    );
  }

  // --- Controles Específicos ---

  Widget _buildIntInput(PropertyDefinition prop, dynamic rawValue) {
    final initialStr = rawValue?.toString() ?? '';
    return TextFormField(
      initialValue: initialStr,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*')),
      ],
      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
      decoration: _inputDecoration(hint: 'ej: 10'),
      onChanged: (val) {
        if (val.trim().isEmpty) {
          _updateValue(prop.key, null);
        } else {
          final n = int.tryParse(val.trim());
          if (n != null) _updateValue(prop.key, n);
        }
      },
    );
  }

  Widget _buildFloatInput(PropertyDefinition prop, dynamic rawValue) {
    final initialStr = rawValue?.toString() ?? '';
    return TextFormField(
      initialValue: initialStr,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*')),
      ],
      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
      decoration: _inputDecoration(hint: 'ej: 60.0'),
      onChanged: (val) {
        if (val.trim().isEmpty) {
          _updateValue(prop.key, null);
        } else {
          final n = double.tryParse(val.trim());
          if (n != null) _updateValue(prop.key, n);
        }
      },
    );
  }

  Widget _buildTextInput(PropertyDefinition prop, dynamic rawValue) {
    final initialStr = rawValue?.toString() ?? '';
    return TextFormField(
      initialValue: initialStr,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: _inputDecoration(hint: 'Texto...'),
      onChanged: (val) {
        _updateValue(prop.key, val.trim().isEmpty ? null : val);
      },
    );
  }

  Widget _buildBooleanSwitch(PropertyDefinition prop, dynamic rawValue) {
    final boolVal = rawValue == true || rawValue?.toString().toLowerCase() == 'true';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            boolVal ? 'Activado (true)' : 'Desactivado (false)',
            style: TextStyle(
              color: boolVal ? const Color(0xFF58A6FF) : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: boolVal,
              activeColor: const Color(0xFF58A6FF),
              onChanged: (val) => _updateValue(prop.key, val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorHexInput(BuildContext context, PropertyDefinition prop, dynamic rawValue) {
    String hexStr = rawValue?.toString() ?? '#ffffff';
    if (!hexStr.startsWith('#')) hexStr = '#$hexStr';

    Color parsedColor;
    try {
      final clean = hexStr.replaceAll('#', '');
      if (clean.length == 6) {
        parsedColor = Color(int.parse('0xFF$clean'));
      } else if (clean.length == 8) {
        parsedColor = Color(int.parse('0x$clean'));
      } else {
        parsedColor = Colors.white;
      }
    } catch (_) {
      parsedColor = Colors.white;
    }

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: parsedColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            initialValue: hexStr,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
            decoration: _inputDecoration(hint: '#RRGGBB o #RRGGBBAA'),
            onChanged: (val) {
              final trimmed = val.trim();
              final reg = RegExp(r'^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
              if (reg.hasMatch(trimmed)) {
                _updateValue(prop.key, trimmed.startsWith('#') ? trimmed : '#$trimmed');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemPicker(WidgetRef ref, PropertyDefinition prop, dynamic rawValue) {
    final availableItems = ref.watch(allAvailableItemsProvider);
    final current = rawValue?.toString();
    final actual = availableItems.contains(current) ? current : (availableItems.isNotEmpty ? availableItems.first : null);

    return DropdownButtonFormField<String>(
      value: actual,
      dropdownColor: const Color(0xFF21262D),
      decoration: _inputDecoration(),
      style: const TextStyle(color: Colors.white, fontSize: 12),
      items: availableItems.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontFamily: 'monospace')),
        );
      }).toList(),
      onChanged: (val) => _updateValue(prop.key, val),
    );
  }

  Widget _buildLiquidPicker(WidgetRef ref, PropertyDefinition prop, dynamic rawValue) {
    final availableLiquids = ref.watch(allAvailableLiquidsProvider);
    final current = rawValue?.toString();
    final actual = availableLiquids.contains(current) ? current : (availableLiquids.isNotEmpty ? availableLiquids.first : null);

    return DropdownButtonFormField<String>(
      value: actual,
      dropdownColor: const Color(0xFF21262D),
      decoration: _inputDecoration(),
      style: const TextStyle(color: Colors.white, fontSize: 12),
      items: availableLiquids.map((liquid) {
        return DropdownMenuItem(
          value: liquid,
          child: Text(liquid, style: const TextStyle(fontFamily: 'monospace')),
        );
      }).toList(),
      onChanged: (val) => _updateValue(prop.key, val),
    );
  }

  Widget _buildEnumDropdown(PropertyDefinition prop, dynamic rawValue) {
    final opts = prop.options ?? [];
    final current = rawValue?.toString();
    final actual = opts.contains(current) ? current : (opts.isNotEmpty ? opts.first : null);

    return DropdownButtonFormField<String>(
      value: actual,
      dropdownColor: const Color(0xFF21262D),
      decoration: _inputDecoration(),
      style: const TextStyle(color: Colors.white, fontSize: 12),
      items: opts.map((opt) {
        return DropdownMenuItem(
          value: opt,
          child: Text(opt),
        );
      }).toList(),
      onChanged: (val) => _updateValue(prop.key, val),
    );
  }

  Widget _buildPrimitiveList(PropertyDefinition prop, dynamic rawValue) {
    final List<dynamic> list = rawValue is List ? List<dynamic>.from(rawValue) : [];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Lista vacía',
                style: TextStyle(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            )
          else
            ...List.generate(list.length, (idx) {
              final itemVal = list[idx]?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: itemVal,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          fillColor: const Color(0xFF161B22),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onChanged: (newVal) {
                          list[idx] = newVal;
                          _updateValue(prop.key, list);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        list.removeAt(idx);
                        _updateValue(prop.key, list.isEmpty ? null : list);
                      },
                    ),
                  ],
                ),
              );
            }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.add, size: 14, color: Color(0xFF58A6FF)),
              label: const Text('Añadir elemento', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 11)),
              onPressed: () {
                list.add('');
                _updateValue(prop.key, list);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectList(PropertyDefinition prop, dynamic rawValue) {
    final List<Map<String, dynamic>> items = [];
    if (rawValue is List) {
      for (final it in rawValue) {
        if (it is Map) {
          items.add(Map<String, dynamic>.from(it));
        }
      }
    }

    final nestedProps = prop.nestedSchema ?? [];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF21262D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Sin elementos en la lista de objetos.',
                style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            )
          else
            ...List.generate(items.length, (idx) {
              final itemData = items[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: ExpansionTile(
                  key: PageStorageKey('obj_${prop.key}_$idx'),
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  title: Text(
                    'Elemento #${idx + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                        onPressed: () {
                          items.removeAt(idx);
                          _updateValue(prop.key, items.isEmpty ? null : items);
                        },
                      ),
                      const Icon(Icons.expand_more, size: 16, color: Colors.white54),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: DynamicTypeFormWidget(
                        schema: CustomTypeSchema(
                          typeId: '${schema.typeId}_${prop.key}_item',
                          displayName: '${prop.label} #${idx + 1}',
                          category: schema.category,
                          properties: nestedProps,
                        ),
                        data: itemData,
                        isNested: true,
                        onChanged: (newMap) {
                          items[idx] = newMap;
                          _updateValue(prop.key, items);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              icon: const Icon(Icons.add, size: 14, color: Color(0xFF7EE787)),
              label: const Text('Añadir Objeto', style: TextStyle(color: Color(0xFF7EE787), fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () {
                final Map<String, dynamic> newObj = {};
                for (final p in nestedProps) {
                  if (p.defaultValue != null) {
                    newObj[p.key] = p.defaultValue;
                  }
                }
                items.add(newObj);
                _updateValue(prop.key, items);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorFallback(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.amber, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: const Color(0xFF21262D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF58A6FF)),
      ),
    );
  }
}
