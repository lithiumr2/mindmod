import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';

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
        key: ValueKey('block_common_$fileId'),
        fileId: fileId,
        properties: properties,
        onChanged: onChanged,
      );
    } else if (type == FileType.unit) {
      return CommonUnitPropertiesWidget(
        key: ValueKey('unit_common_$fileId'),
        fileId: fileId,
        properties: properties,
        onChanged: onChanged,
      );
    }
    return const SizedBox.shrink();
  }
}

class CommonBlockPropertiesWidget extends StatefulWidget {
  final String fileId;
  final Map<String, dynamic> properties;
  final Function(String, dynamic) onChanged;

  const CommonBlockPropertiesWidget({
    super.key,
    required this.fileId,
    required this.properties,
    required this.onChanged,
  });

  @override
  State<CommonBlockPropertiesWidget> createState() => _CommonBlockPropertiesWidgetState();
}

class _CommonBlockPropertiesWidgetState extends State<CommonBlockPropertiesWidget> {
  static const List<String> categories = [
    "turret", "production", "distribution", "liquid", "power", "defense", 
    "crafting", "units", "effect", "logic"
  ];

  void _update(String key, dynamic value) {
    widget.onChanged(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.properties;
    final bool hasItems = props['hasItems'] == true || props['hasItems']?.toString().toLowerCase() == 'true';
    final bool hasLiquids = props['hasLiquids'] == true || props['hasLiquids']?.toString().toLowerCase() == 'true';
    final bool hasPower = props['hasPower'] == true || props['hasPower']?.toString().toLowerCase() == 'true';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Información General"),
        _buildCard([
          _buildTextField('name', 'Name', props['name'], (v) => _update('name', v)),
          _buildTextField('description', 'Description', props['description'], (v) => _update('description', v), multiline: true),
          _buildTextField('details', 'Details', props['details'], (v) => _update('details', v), multiline: true),
        ]),

        _buildSectionHeader("Dimensiones y Resistencia"),
        _buildCard([
          _buildNumField('size', 'Size (1-16)', props['size'], (v) => _update('size', v?.toInt() ?? 1)),
          _buildNumField('health', 'Health (HP Base)', props['health'], (v) => _update('health', v?.toInt() ?? 100)),
          _buildNumField('buildCostMultiplier', 'Build Cost Multiplier', props['buildCostMultiplier'], (v) => _update('buildCostMultiplier', v ?? 1.0), isDouble: true),
        ]),

        _buildSectionHeader("Construcción e Investigación"),
        _buildCard([
          _buildDropdown('category', 'Category', props['category']?.toString(), categories, (v) => _update('category', v)),
          _buildTextField('research', 'Research (Parent Node)', props['research'], (v) => _update('research', v)),
          _buildSwitch('alwaysUnlocked', 'Always Unlocked', props['alwaysUnlocked'], (v) => _update('alwaysUnlocked', v)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          RequirementsBuilder(
            requirements: props['requirements'],
            onChanged: (v) => _update('requirements', v),
          ),
        ]),

        _buildSectionHeader("Almacenamiento y Capacidades"),
        _buildCard([
          _buildSwitch('hasItems', 'Has Items', props['hasItems'], (v) {
            _update('hasItems', v);
            setState(() {});
          }),
          if (hasItems) _buildNumField('itemCapacity', 'Item Capacity', props['itemCapacity'], (v) => _update('itemCapacity', v?.toInt() ?? 10)),
          const Divider(color: Colors.white12),
          _buildSwitch('hasLiquids', 'Has Liquids', props['hasLiquids'], (v) {
            _update('hasLiquids', v);
            setState(() {});
          }),
          if (hasLiquids) _buildNumField('liquidCapacity', 'Liquid Capacity', props['liquidCapacity'], (v) => _update('liquidCapacity', v ?? 10.0), isDouble: true),
          const Divider(color: Colors.white12),
          _buildSwitch('hasPower', 'Has Power', props['hasPower'], (v) {
            _update('hasPower', v);
            setState(() {});
          }),
          if (hasPower) ...[
            _buildSwitch('outputsPower', 'Outputs Power', props['outputsPower'], (v) => _update('outputsPower', v)),
            _buildSwitch('consumesPower', 'Consumes Power', props['consumesPower'], (v) => _update('consumesPower', v)),
          ],
        ]),

        _buildSectionHeader("Físicas y Comportamiento"),
        _buildCard([
          _buildSwitch('solid', 'Solid', props['solid'], (v) => _update('solid', v), defaultVal: true),
          _buildSwitch('targetable', 'Targetable', props['targetable'], (v) => _update('targetable', v), defaultVal: true),
          _buildSwitch('destructible', 'Destructible', props['destructible'], (v) => _update('destructible', v), defaultVal: true),
          _buildSwitch('canOverdrive', 'Can Overdrive', props['canOverdrive'], (v) => _update('canOverdrive', v), defaultVal: true),
          _buildSwitch('update', 'Update', props['update'], (v) => _update('update', v), defaultVal: true),
        ]),
      ],
    );
  }
}

class CommonUnitPropertiesWidget extends StatefulWidget {
  final String fileId;
  final Map<String, dynamic> properties;
  final Function(String, dynamic) onChanged;

  const CommonUnitPropertiesWidget({
    super.key,
    required this.fileId,
    required this.properties,
    required this.onChanged,
  });

  @override
  State<CommonUnitPropertiesWidget> createState() => _CommonUnitPropertiesWidgetState();
}

class _CommonUnitPropertiesWidgetState extends State<CommonUnitPropertiesWidget> {
  void _update(String key, dynamic value) {
    widget.onChanged(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.properties;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Información General"),
        _buildCard([
          _buildTextField('name', 'Name', props['name'], (v) => _update('name', v)),
          _buildTextField('description', 'Description', props['description'], (v) => _update('description', v), multiline: true),
          _buildTextField('research', 'Research (Parent Node)', props['research'], (v) => _update('research', v)),
        ]),

        _buildSectionHeader("Estadísticas Vitales"),
        _buildCard([
          _buildNumField('health', 'Health (HP)', props['health'], (v) => _update('health', v ?? 100.0), isDouble: true),
          _buildNumField('armor', 'Armor', props['armor'], (v) => _update('armor', v ?? 0.0), isDouble: true),
          _buildNumField('speed', 'Speed', props['speed'], (v) => _update('speed', v ?? 1.0), isDouble: true),
          _buildNumField('hitSize', 'Hit Size', props['hitSize'], (v) => _update('hitSize', v ?? 8.0), isDouble: true),
          _buildNumField('accel', 'Acceleration', props['accel'], (v) => _update('accel', v ?? 0.5), isDouble: true),
          _buildNumField('drag', 'Drag', props['drag'], (v) => _update('drag', v ?? 0.1), isDouble: true),
          _buildNumField('rotateSpeed', 'Rotate Speed', props['rotateSpeed'], (v) => _update('rotateSpeed', v ?? 2.0), isDouble: true),
        ]),

        _buildSectionHeader("Capacidades Operativas"),
        _buildCard([
          _buildNumField('itemCapacity', 'Item Capacity', props['itemCapacity'], (v) => _update('itemCapacity', v?.toInt() ?? 0)),
          _buildNumField('buildSpeed', 'Build Speed', props['buildSpeed'], (v) => _update('buildSpeed', v ?? 0.5), isDouble: true),
          _buildNumField('mineSpeed', 'Mine Speed', props['mineSpeed'], (v) => _update('mineSpeed', v ?? 1.0), isDouble: true),
          _buildNumField('mineTier', 'Mine Tier', props['mineTier'], (v) => _update('mineTier', v?.toInt() ?? 1)),
        ]),

        _buildSectionHeader("Flags y Control"),
        _buildCard([
          _buildSwitch('flying', 'Flying', props['flying'], (v) => _update('flying', v)),
          _buildSwitch('lowAltitude', 'Low Altitude', props['lowAltitude'], (v) => _update('lowAltitude', v)),
          _buildSwitch('isEnemy', 'Is Enemy', props['isEnemy'], (v) => _update('isEnemy', v), defaultVal: true),
          _buildSwitch('targetable', 'Targetable', props['targetable'], (v) => _update('targetable', v), defaultVal: true),
          _buildSwitch('hittable', 'Hittable', props['hittable'], (v) => _update('hittable', v), defaultVal: true),
          _buildSwitch('playerControllable', 'Player Controllable', props['playerControllable'], (v) => _update('playerControllable', v), defaultVal: true),
          _buildSwitch('logicControllable', 'Logic Controllable', props['logicControllable'], (v) => _update('logicControllable', v), defaultVal: true),
          _buildSwitch('useUnitCap', 'Use Unit Cap', props['useUnitCap'], (v) => _update('useUnitCap', v), defaultVal: true),
        ]),
      ],
    );
  }
}

// --- HELPER WIDGETS ---

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget _buildCard(List<Widget> children) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E24),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget _buildTextField(String key, String label, dynamic value, Function(String) onChanged, {bool multiline = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      initialValue: value?.toString() ?? '',
      style: const TextStyle(color: Colors.white, fontSize: 13),
      maxLines: multiline ? 3 : 1,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: onChanged,
    ),
  );
}

Widget _buildNumField(String key, String label, dynamic value, Function(num?) onChanged, {bool isDouble = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*'))],
      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: (val) {
        if (val.isEmpty || val == '-') {
          onChanged(null);
          return;
        }
        if (isDouble) {
          onChanged(double.tryParse(val));
        } else {
          onChanged(int.tryParse(val));
        }
      },
    ),
  );
}

Widget _buildSwitch(String key, String label, dynamic value, Function(bool) onChanged, {bool defaultVal = false}) {
  bool boolVal = defaultVal;
  if (value != null) {
    if (value is bool) boolVal = value;
    else if (value.toString().toLowerCase() == 'true') boolVal = true;
    else if (value.toString().toLowerCase() == 'false') boolVal = false;
  }
  return SwitchListTile(
    title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    value: boolVal,
    activeColor: Colors.amber,
    contentPadding: EdgeInsets.zero,
    dense: true,
    onChanged: onChanged,
  );
}

Widget _buildDropdown(String key, String label, String? value, List<String> options, Function(String) onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField<String>(
      value: (value != null && options.contains(value)) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      dropdownColor: const Color(0xFF262630),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}

// --- Requirements Builder ---
class RequirementsBuilder extends StatefulWidget {
  final dynamic requirements;
  final Function(List<dynamic>) onChanged;

  const RequirementsBuilder({super.key, required this.requirements, required this.onChanged});

  @override
  State<RequirementsBuilder> createState() => _RequirementsBuilderState();
}

class _RequirementsBuilderState extends State<RequirementsBuilder> {
  static const List<String> vanillaItems = [
    "copper", "lead", "metaglass", "graphite", "sand", "coal",
    "titanium", "thorium", "silicon", "plastanium", "phase-fabric",
    "surge-alloy", "spore-pod", "blast-compound", "pyratite",
    "beryllium", "tungsten", "oxide", "carbide"
  ];

  List<String> _reqList = [];

  @override
  void initState() {
    super.initState();
    _parseReqs();
  }

  @override
  void didUpdateWidget(covariant RequirementsBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.requirements != oldWidget.requirements) {
      _parseReqs();
    }
  }

  void _parseReqs() {
    if (widget.requirements is List) {
      _reqList = (widget.requirements as List).map((e) => e.toString()).toList();
    } else {
      _reqList = [];
    }
  }

  void _notify() {
    widget.onChanged(_reqList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Requirements (Costes de Construcción)", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._reqList.asMap().entries.map((entry) {
          int idx = entry.key;
          String reqStr = entry.value;
          List<String> parts = reqStr.split('/');
          String item = parts.isNotEmpty ? parts[0] : 'copper';
          String qty = parts.length > 1 ? parts[1] : '1';

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: vanillaItems.contains(item) ? item : (vanillaItems.isNotEmpty ? vanillaItems.first : null),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF262630),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    dropdownColor: const Color(0xFF262630),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: vanillaItems.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _reqList[idx] = "$v/$qty");
                        _notify();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: qty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF262630),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      hintText: "Qty",
                    ),
                    onChanged: (val) {
                      final n = int.tryParse(val) ?? 1;
                      setState(() => _reqList[idx] = "$item/$n");
                      _notify();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    setState(() => _reqList.removeAt(idx));
                    _notify();
                  },
                ),
              ],
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: () {
            setState(() => _reqList.add("copper/10"));
            _notify();
          },
          icon: const Icon(Icons.add, color: Colors.amber, size: 16),
          label: const Text("Añadir Requerimiento", style: TextStyle(color: Colors.amber, fontSize: 12)),
        )
      ],
    );
  }
}
