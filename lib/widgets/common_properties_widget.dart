import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_file.dart';
import '../providers/locale_provider.dart';

final commonPropsProvider = StateNotifierProvider.family<CommonPropsNotifier, Map<String, dynamic>, String>((ref, id) {
  return CommonPropsNotifier();
});

class CommonPropsNotifier extends StateNotifier<Map<String, dynamic>> {
  CommonPropsNotifier() : super({});

  void init(Map<String, dynamic> initial) {
    if (state.isEmpty && initial.isNotEmpty) {
      state = Map<String, dynamic>.from(initial);
    } else if (state.isEmpty) {
      state = {};
    }
  }

  void updateField(String key, dynamic value, Function(String, dynamic) onExternalChange) {
    state = {...state, key: value};
    onExternalChange(key, value);
  }

  void removeField(String key, Function(String, dynamic) onExternalChange) {
    final updated = Map<String, dynamic>.from(state);
    updated.remove(key);
    state = updated;
    onExternalChange(key, null); // passing null to signify removal, or handle it
  }
}

class CommonPropertiesContainer extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commonPropsProvider(fileId).notifier).init(properties);
    });

    if (type == FileType.block) {
      return CommonBlockPropertiesWidget(fileId: fileId, onChanged: onChanged);
    } else if (type == FileType.unit) {
      return CommonUnitPropertiesWidget(fileId: fileId, onChanged: onChanged);
    }
    return const SizedBox.shrink();
  }
}

class CommonBlockPropertiesWidget extends ConsumerWidget {
  final String fileId;
  final Function(String, dynamic) onChanged;

  static const List<String> categories = [
    "turret", "production", "distribution", "liquid", "power", "defense", 
    "crafting", "units", "effect", "logic"
  ];

  const CommonBlockPropertiesWidget({super.key, required this.fileId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commonPropsProvider(fileId));
    final notifier = ref.read(commonPropsProvider(fileId).notifier);

    void update(String k, dynamic v) => notifier.updateField(k, v, onChanged);

    final bool hasItems = state['hasItems'] == true || state['hasItems'] == 'true';
    final bool hasLiquids = state['hasLiquids'] == true || state['hasLiquids'] == 'true';
    final bool hasPower = state['hasPower'] == true || state['hasPower'] == 'true';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Información General"),
        _buildCard([
          _buildTextField('name', 'Name', state['name'], (v) => update('name', v)),
          _buildTextField('description', 'Description', state['description'], (v) => update('description', v), multiline: true),
          _buildTextField('details', 'Details', state['details'], (v) => update('details', v), multiline: true),
        ]),

        _buildSectionHeader("Dimensiones y Resistencia"),
        _buildCard([
          _buildNumField('size', 'Size (1-16)', state['size'], (v) => update('size', v?.toInt() ?? 1)),
          _buildNumField('health', 'Health', state['health'], (v) => update('health', v?.toInt() ?? 100)),
          _buildNumField('buildCostMultiplier', 'Build Cost Multiplier', state['buildCostMultiplier'], (v) => update('buildCostMultiplier', v ?? 1.0), isDouble: true),
        ]),

        _buildSectionHeader("Construcción e Investigación"),
        _buildCard([
          _buildDropdown('category', 'Category', state['category']?.toString(), categories, (v) => update('category', v)),
          _buildTextField('research', 'Research (Parent Node)', state['research'], (v) => update('research', v)),
          _buildSwitch('alwaysUnlocked', 'Always Unlocked', state['alwaysUnlocked'], (v) => update('alwaysUnlocked', v)),
          const Divider(color: Colors.white12),
          RequirementsBuilder(
            requirements: state['requirements'],
            onChanged: (v) => update('requirements', v),
          ),
        ]),

        _buildSectionHeader("Almacenamiento y Capacidades"),
        _buildCard([
          _buildSwitch('hasItems', 'Has Items', state['hasItems'], (v) => update('hasItems', v)),
          if (hasItems) _buildNumField('itemCapacity', 'Item Capacity', state['itemCapacity'], (v) => update('itemCapacity', v?.toInt() ?? 10)),
          const Divider(color: Colors.white12),
          _buildSwitch('hasLiquids', 'Has Liquids', state['hasLiquids'], (v) => update('hasLiquids', v)),
          if (hasLiquids) _buildNumField('liquidCapacity', 'Liquid Capacity', state['liquidCapacity'], (v) => update('liquidCapacity', v ?? 10.0), isDouble: true),
          const Divider(color: Colors.white12),
          _buildSwitch('hasPower', 'Has Power', state['hasPower'], (v) => update('hasPower', v)),
          if (hasPower) ...[
            _buildSwitch('outputsPower', 'Outputs Power', state['outputsPower'], (v) => update('outputsPower', v)),
            _buildSwitch('consumesPower', 'Consumes Power', state['consumesPower'], (v) => update('consumesPower', v)),
          ],
        ]),

        _buildSectionHeader("Físicas y Comportamiento"),
        _buildCard([
          _buildSwitch('solid', 'Solid', state['solid'], (v) => update('solid', v), defaultVal: true),
          _buildSwitch('targetable', 'Targetable', state['targetable'], (v) => update('targetable', v), defaultVal: true),
          _buildSwitch('destructible', 'Destructible', state['destructible'], (v) => update('destructible', v), defaultVal: true),
          _buildSwitch('canOverdrive', 'Can Overdrive', state['canOverdrive'], (v) => update('canOverdrive', v), defaultVal: true),
          _buildSwitch('update', 'Update', state['update'], (v) => update('update', v), defaultVal: true),
        ]),
      ],
    );
  }
}

class CommonUnitPropertiesWidget extends ConsumerWidget {
  final String fileId;
  final Function(String, dynamic) onChanged;

  const CommonUnitPropertiesWidget({super.key, required this.fileId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commonPropsProvider(fileId));
    final notifier = ref.read(commonPropsProvider(fileId).notifier);

    void update(String k, dynamic v) => notifier.updateField(k, v, onChanged);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Información General"),
        _buildCard([
          _buildTextField('name', 'Name', state['name'], (v) => update('name', v)),
          _buildTextField('description', 'Description', state['description'], (v) => update('description', v), multiline: true),
          _buildTextField('research', 'Research (Parent Node)', state['research'], (v) => update('research', v)),
        ]),

        _buildSectionHeader("Estadísticas Vitales"),
        _buildCard([
          _buildNumField('health', 'Health', state['health'], (v) => update('health', v ?? 100.0), isDouble: true),
          _buildNumField('armor', 'Armor', state['armor'], (v) => update('armor', v ?? 0.0), isDouble: true),
          _buildNumField('speed', 'Speed', state['speed'], (v) => update('speed', v ?? 1.0), isDouble: true),
          _buildNumField('hitSize', 'Hit Size', state['hitSize'], (v) => update('hitSize', v ?? 8.0), isDouble: true),
          _buildNumField('accel', 'Acceleration', state['accel'], (v) => update('accel', v ?? 0.5), isDouble: true),
          _buildNumField('drag', 'Drag', state['drag'], (v) => update('drag', v ?? 0.1), isDouble: true),
          _buildNumField('rotateSpeed', 'Rotate Speed', state['rotateSpeed'], (v) => update('rotateSpeed', v ?? 2.0), isDouble: true),
        ]),

        _buildSectionHeader("Capacidades Operativas"),
        _buildCard([
          _buildNumField('itemCapacity', 'Item Capacity', state['itemCapacity'], (v) => update('itemCapacity', v?.toInt() ?? 0)),
          _buildNumField('buildSpeed', 'Build Speed', state['buildSpeed'], (v) => update('buildSpeed', v ?? 0.5), isDouble: true),
          _buildNumField('mineSpeed', 'Mine Speed', state['mineSpeed'], (v) => update('mineSpeed', v ?? 1.0), isDouble: true),
          _buildNumField('mineTier', 'Mine Tier', state['mineTier'], (v) => update('mineTier', v?.toInt() ?? 1)),
        ]),

        _buildSectionHeader("Flags y Control"),
        _buildCard([
          _buildSwitch('flying', 'Flying', state['flying'], (v) => update('flying', v)),
          _buildSwitch('lowAltitude', 'Low Altitude', state['lowAltitude'], (v) => update('lowAltitude', v)),
          _buildSwitch('isEnemy', 'Is Enemy', state['isEnemy'], (v) => update('isEnemy', v), defaultVal: true),
          _buildSwitch('targetable', 'Targetable', state['targetable'], (v) => update('targetable', v), defaultVal: true),
          _buildSwitch('hittable', 'Hittable', state['hittable'], (v) => update('hittable', v), defaultVal: true),
          _buildSwitch('playerControllable', 'Player Controllable', state['playerControllable'], (v) => update('playerControllable', v), defaultVal: true),
          _buildSwitch('logicControllable', 'Logic Controllable', state['logicControllable'], (v) => update('logicControllable', v), defaultVal: true),
          _buildSwitch('useUnitCap', 'Use Unit Cap', state['useUnitCap'], (v) => update('useUnitCap', v), defaultVal: true),
        ]),
      ],
    );
  }
}

// --- HELPER WIDGETS ---

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
    child: Text(
      title,
      style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildCard(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E24),
      borderRadius: BorderRadius.circular(12),
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
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      initialValue: value?.toString() ?? '',
      style: const TextStyle(color: Colors.white, fontSize: 14),
      maxLines: multiline ? 3 : 1,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: onChanged,
    ),
  );
}

Widget _buildNumField(String key, String label, dynamic value, Function(num?) onChanged, {bool isDouble = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*'))],
      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
    value: boolVal,
    activeColor: Colors.amber,
    contentPadding: EdgeInsets.zero,
    onChanged: onChanged,
  );
}

Widget _buildDropdown(String key, String label, String? value, List<String> options, Function(String) onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: (value != null && options.contains(value)) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      dropdownColor: const Color(0xFF262630),
      style: const TextStyle(color: Colors.white, fontSize: 14),
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
        const Text("Requirements", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 12),
        ..._reqList.asMap().entries.map((entry) {
          int idx = entry.key;
          String reqStr = entry.value;
          List<String> parts = reqStr.split('/');
          String item = parts.isNotEmpty ? parts[0] : 'copper';
          String qty = parts.length > 1 ? parts[1] : '1';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: vanillaItems.contains(item) ? item : (vanillaItems.isNotEmpty ? vanillaItems.first : null),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF262630),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
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
          icon: const Icon(Icons.add, color: Colors.amber),
          label: const Text("Add Requirement", style: TextStyle(color: Colors.amber)),
        )
      ],
    );
  }
}
