import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';

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

class RequirementsBuilder extends StatelessWidget {
  final List<dynamic> requirements;
  final Function(List<dynamic>) onUpdate;

  const RequirementsBuilder({super.key, required this.requirements, required this.onUpdate});

  static const List<String> mindustryItems = [
    'copper', 'lead', 'metaglass', 'graphite', 'sand', 'coal', 'titanium', 
    'thorium', 'scrap', 'silicon', 'plastanium', 'phase-fabric', 'surge-alloy',
    'spore-pod', 'blast-compound', 'pyratite', 'beryllium', 'tungsten',
    'oxide', 'carbide', 'fissile-matter', 'dormant-cyst'
  ];

  @override
  Widget build(BuildContext context) {
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
                    final newList = List.from(requirements)..add({'item': 'copper', 'amount': 10});
                    onUpdate(newList);
                  },
                )
              ],
            ),
            const Divider(),
            ...requirements.asMap().entries.map((entry) {
              final index = entry.key;
              final req = entry.value is Map ? (entry.value as Map<String, dynamic>) : {'item': 'copper', 'amount': 10};
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: mindustryItems.contains(req['item']) ? req['item'] : 'copper',
                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                        items: mindustryItems.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) {
                          final newList = List.from(requirements);
                          newList[index] = {...req, 'item': v};
                          onUpdate(newList);
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
                          if (parsed != null) {
                            final newList = List.from(requirements);
                            newList[index] = {...req, 'amount': parsed};
                            onUpdate(newList);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        final newList = List.from(requirements)..removeAt(index);
                        onUpdate(newList);
                      },
                    )
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

  static const List<String> blockTypes = [
    'Wall', 'GenericCrafter', 'HeatCrafter', 'Separator',
    'Drill', 'BeamDrill', 'Pump', 'SolidPump',
    'ItemTurret', 'LiquidTurret', 'PowerTurret',
    'ConsumeGenerator', 'NuclearReactor', 'PowerNode',
    'Conveyor', 'MassDriver', 'ForceProjector'
  ];

  static const List<String> categories = [
    'distribution', 'liquid', 'power', 'production', 'defense',
    'turret', 'units', 'effect', 'logic', 'crafting'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasItems = data['hasItems'] == true || data['hasItems'] == 'true';
    final hasLiquids = data['hasLiquids'] == true || data['hasLiquids'] == 'true';
    final hasPower = data['hasPower'] == true || data['hasPower'] == 'true';
    final reqs = data['requirements'] is List ? data['requirements'] as List : [];
    
    // Cleanup string types correctly
    final safeType = data['type']?.toString().replaceAll('"', '');

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
                Expanded(child: PropDropdown(
                  label: 'type (Tipo)', 
                  value: blockTypes.contains(safeType) ? safeType : null, 
                  options: blockTypes, 
                  onChanged: (v) => onUpdate('type', v)
                )),
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
                      value: categories.contains(data['category']) ? data['category'] : null, 
                      options: categories, 
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

  static const List<String> unitTypes = [
    'flying', 'mech', 'legs', 'naval', 'payload'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeType = data['type']?.toString().replaceAll('"', '');
    
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
                Expanded(child: PropDropdown(
                  label: 'type (Tipo de Unidad)', 
                  value: unitTypes.contains(safeType) ? safeType : null, 
                  options: unitTypes, 
                  onChanged: (v) => onUpdate('type', v)
                )),
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
