import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../providers/module_registry_provider.dart';

// =====================================================================
// 1. COMPONENTES BASE (Seguros contra nulos y tipos estrictos)
// =====================================================================

class PropTextField extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool isInt;
  final bool isFloat;
  final Function(dynamic) onChanged;

  const PropTextField({
    super.key,
    required this.label,
    required this.value,
    this.isInt = false,
    this.isFloat = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        keyboardType: (isInt || isFloat) ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          isDense: true,
        ),
        onChanged: (val) {
          if (val.isEmpty) {
            onChanged(null);
            return;
          }
          if (isInt) {
            final parsed = int.tryParse(val);
            if (parsed != null) onChanged(parsed);
          } else if (isFloat) {
            final parsed = double.tryParse(val);
            if (parsed != null) onChanged(parsed);
          } else {
            onChanged(val);
          }
        },
      ),
    );
  }
}

class PropSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const PropSwitch({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class PropDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final Function(String) onChanged;

  const PropDropdown({super.key, required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    String? validValue = options.contains(value) ? value : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: validValue,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// =====================================================================
// 2. CONSTRUCTOR DE REQUERIMIENTOS
// =====================================================================

class RequirementsBuilder extends ConsumerWidget {
  final List<dynamic> requirements;
  final Function(List<dynamic>) onUpdate;

  const RequirementsBuilder({super.key, required this.requirements, required this.onUpdate});

  List<Map<String, dynamic>> _getNormalized() {
    final List<Map<String, dynamic>> list = [];
    for (final entry in requirements) {
      if (entry == null) continue;
      if (entry is Map) {
        final item = entry['item']?.toString().replaceAll('@', '').trim() ?? 'copper';
        final amount = int.tryParse(entry['amount']?.toString().trim() ?? '10') ?? 10;
        if (item.isNotEmpty && item != '{' && item != '}' && !item.contains('{') && !item.contains('}')) {
          list.add({'item': item, 'amount': amount});
        }
      } else if (entry is String) {
        final str = entry.trim();
        if (str.isEmpty || str == '{' || str == '}' || str == '""') continue;
        final clean = str.replaceAll('@', '').trim();
        final parts = clean.split('/');
        if (parts.length >= 2) {
          final item = parts[0].trim();
          final amount = int.tryParse(parts[1].trim()) ?? 10;
          if (item.isNotEmpty && item != '{' && item != '}' && !item.contains('{') && !item.contains('}')) {
            list.add({'item': item, 'amount': amount});
          }
        } else if (clean.isNotEmpty && clean != '{' && clean != '}' && !clean.contains(':')) {
          list.add({'item': clean, 'amount': 10});
        }
      }
    }
    return list;
  }

  void _emitChanges(List<Map<String, dynamic>> items) {
    final formatted = items
        .where((r) => r['item'] != null && r['item'].toString().trim().isNotEmpty && r['item'] != '{' && r['item'] != '}')
        .map((r) => "${r['item']}/${r['amount']}")
        .toList();
    onUpdate(formatted);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableItems = ref.watch(allAvailableItemsProvider);
    final normalized = _getNormalized();

    return Card(
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.amber.withOpacity(0.5)), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('requirements (Ítems de Construcción)', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Añadir', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                  onPressed: () {
                    final defaultItem = availableItems.isNotEmpty ? availableItems.first : 'copper';
                    final updated = List<Map<String, dynamic>>.from(normalized)
                      ..add({'item': defaultItem, 'amount': 10});
                    _emitChanges(updated);
                  },
                )
              ],
            ),
            const Divider(),
            if (normalized.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('Sin requisitos (Gratuito o Bloque Base)', style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ...normalized.asMap().entries.map((entry) {
              final index = entry.key;
              final req = entry.value;
              final currentItem = req['item']?.toString() ?? 'copper';
              final itemOptions = List<String>.from(availableItems);
              if (!itemOptions.contains(currentItem)) {
                itemOptions.insert(0, currentItem);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: currentItem,
                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                        items: itemOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          final updated = List<Map<String, dynamic>>.from(normalized);
                          updated[index] = {...req, 'item': v};
                          _emitChanges(updated);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: req['amount']?.toString() ?? '10',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cant.', isDense: true, border: OutlineInputBorder()),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed >= 0) {
                            final updated = List<Map<String, dynamic>>.from(normalized);
                            updated[index] = {...req, 'amount': parsed};
                            _emitChanges(updated);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        tooltip: 'Eliminar requerimiento',
                        onPressed: () {
                          final updated = List<Map<String, dynamic>>.from(normalized)..removeAt(index);
                          _emitChanges(updated);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// 3. WIDGET DE PROPIEDADES COMUNES DE BLOQUES (Block)
// =====================================================================

class CommonBlockPropertiesWidget extends ConsumerWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onUpdate;

  const CommonBlockPropertiesWidget({super.key, required this.data, required this.onUpdate});

  void _showCustomTypeDialog(BuildContext context, String currentType) {
    final controller = TextEditingController(text: currentType);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escribir Tipo Personalizado'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tipo de Bloque',
            hintText: 'ej. CustomCrafter, MyModdedBlock',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                onUpdate('type', val);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasItems = data['hasItems'] == true || data['hasItems'] == 'true';
    final hasLiquids = data['hasLiquids'] == true || data['hasLiquids'] == 'true';
    final hasPower = data['hasPower'] == true || data['hasPower'] == 'true';
    final reqs = data['requirements'] is List ? data['requirements'] as List : [];
    
    // Lista dinámica de tipos de bloques (Base Mindustry exhaustivo + Módulos activos)
    final availableBlockTypes = ref.watch(allAvailableBlockTypesProvider);
    final availableCategories = ref.watch(allAvailableCategoriesProvider);

    final safeType = data['type']?.toString().replaceAll('"', '').trim();
    final blockTypesList = List<String>.from(availableBlockTypes);
    if (safeType != null && safeType.isNotEmpty && !blockTypesList.contains(safeType)) {
      blockTypesList.insert(0, safeType);
    }

    final safeCategory = data['category']?.toString().replaceAll('"', '').trim();
    final categoryList = List<String>.from(availableCategories);
    if (safeCategory != null && safeCategory.isNotEmpty && !categoryList.contains(safeCategory)) {
      categoryList.insert(0, safeCategory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. IDENTIDAD Y TIPO ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: PropTextField(label: 'name (ID Interno)', value: data['name'], onChanged: (v) => onUpdate('name', v))),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: PropDropdown(
                          label: 'type (Tipo de Bloque)', 
                          value: (safeType != null && safeType.isNotEmpty) ? safeType : null, 
                          options: blockTypesList, 
                          onChanged: (v) => onUpdate('type', v),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Escribir tipo personalizado',
                        icon: const Icon(Icons.edit_note, color: Colors.amber),
                        onPressed: () => _showCustomTypeDialog(context, safeType ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- 2. ESTADÍSTICAS VITALES ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estadísticas Vitales', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                Row(
                  children: [
                    Expanded(child: PropTextField(label: 'health', value: data['health'], isInt: true, onChanged: (v) => onUpdate('health', v))),
                    const SizedBox(width: 8),
                    Expanded(child: PropTextField(label: 'size', value: data['size'], isInt: true, onChanged: (v) => onUpdate('size', v))),
                    const SizedBox(width: 8),
                    Expanded(child: PropDropdown(
                      label: 'category', 
                      value: (safeCategory != null && safeCategory.isNotEmpty) ? safeCategory : null, 
                      options: categoryList, 
                      onChanged: (v) => onUpdate('category', v)
                    )),
                  ],
                ),
                PropTextField(label: 'buildCostMultiplier', value: data['buildCostMultiplier'], isFloat: true, onChanged: (v) => onUpdate('buildCostMultiplier', v)),
              ],
            ),
          ),
        ),

        // --- 3. REQUERIMIENTOS ---
        RequirementsBuilder(requirements: reqs, onUpdate: (v) => onUpdate('requirements', v)),

        // --- 4. ALMACENAMIENTO Y CAPACIDADES ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text('Capacidades (Items / Líquidos / Energía)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                 const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: PropSwitch(label: 'hasItems', value: hasItems, onChanged: (v) => onUpdate('hasItems', v))),
                    if (hasItems) Expanded(child: PropTextField(label: 'itemCapacity', value: data['itemCapacity'], isInt: true, onChanged: (v) => onUpdate('itemCapacity', v))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: PropSwitch(label: 'hasLiquids', value: hasLiquids, onChanged: (v) => onUpdate('hasLiquids', v))),
                    if (hasLiquids) Expanded(child: PropTextField(label: 'liquidCapacity', value: data['liquidCapacity'], isFloat: true, onChanged: (v) => onUpdate('liquidCapacity', v))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(flex: 2, child: PropSwitch(label: 'hasPower', value: hasPower, onChanged: (v) => onUpdate('hasPower', v))),
                    if (hasPower) Expanded(child: PropSwitch(label: 'consumesPower', value: data['consumesPower'] == true || data['consumesPower'] == 'true', onChanged: (v) => onUpdate('consumesPower', v))),
                    if (hasPower) Expanded(child: PropSwitch(label: 'outputsPower', value: data['outputsPower'] == true || data['outputsPower'] == 'true', onChanged: (v) => onUpdate('outputsPower', v))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// 4. WIDGET DE PROPIEDADES COMUNES DE UNIDADES (Unit)
// =====================================================================

class CommonUnitPropertiesWidget extends ConsumerWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onUpdate;

  const CommonUnitPropertiesWidget({super.key, required this.data, required this.onUpdate});

  void _showCustomUnitTypeDialog(BuildContext context, String currentType) {
    final controller = TextEditingController(text: currentType);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escribir Tipo de Unidad'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tipo de Unidad',
            hintText: 'ej. flying, mech, missile, custom-unit',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                onUpdate('type', val);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableUnitTypes = ref.watch(allAvailableUnitTypesProvider);
    final safeType = data['type']?.toString().replaceAll('"', '').trim();
    final unitTypesList = List<String>.from(availableUnitTypes);
    if (safeType != null && safeType.isNotEmpty && !unitTypesList.contains(safeType)) {
      unitTypesList.insert(0, safeType);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: PropTextField(label: 'name (ID Interno)', value: data['name'], onChanged: (v) => onUpdate('name', v))),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: PropDropdown(
                          label: 'type (Tipo de Unidad)', 
                          value: (safeType != null && safeType.isNotEmpty) ? safeType : null, 
                          options: unitTypesList, 
                          onChanged: (v) => onUpdate('type', v),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Escribir tipo de unidad personalizado',
                        icon: const Icon(Icons.edit_note, color: Colors.amber),
                        onPressed: () => _showCustomUnitTypeDialog(context, safeType ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estadísticas Vitales de Unidad', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                Row(
                  children: [
                    Expanded(child: PropTextField(label: 'health', value: data['health'], isFloat: true, onChanged: (v) => onUpdate('health', v))),
                    const SizedBox(width: 8),
                    Expanded(child: PropTextField(label: 'armor', value: data['armor'], isFloat: true, onChanged: (v) => onUpdate('armor', v))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: PropTextField(label: 'speed', value: data['speed'], isFloat: true, onChanged: (v) => onUpdate('speed', v))),
                    const SizedBox(width: 8),
                    Expanded(child: PropTextField(label: 'hitSize', value: data['hitSize'], isFloat: true, onChanged: (v) => onUpdate('hitSize', v))),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Banderas de Comportamiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                Row(
                  children: [
                    Expanded(child: PropSwitch(label: 'flying', value: data['flying'] == true, onChanged: (v) => onUpdate('flying', v))),
                    Expanded(child: PropSwitch(label: 'isEnemy', value: data['isEnemy'] == true, onChanged: (v) => onUpdate('isEnemy', v))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: PropSwitch(label: 'targetable', value: data['targetable'] != false, onChanged: (v) => onUpdate('targetable', v))),
                    Expanded(child: PropSwitch(label: 'lowAltitude', value: data['lowAltitude'] == true, onChanged: (v) => onUpdate('lowAltitude', v))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// 5. CONTENEDOR PRINCIPAL
// =====================================================================

class CommonPropertiesContainer extends StatelessWidget {
  final String fileId;
  final FileType type;
  final Map<String, dynamic> properties;
  final Function(String, dynamic) onChanged;

  const CommonPropertiesContainer({
    super.key,
    required this.fileId,
    required this.type,
    required this.properties,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (type == FileType.block) {
      return CommonBlockPropertiesWidget(
        data: properties,
        onUpdate: onChanged,
      );
    } else if (type == FileType.unit) {
      return CommonUnitPropertiesWidget(
        data: properties,
        onUpdate: onChanged,
      );
    }
    return const SizedBox.shrink();
  }
}
