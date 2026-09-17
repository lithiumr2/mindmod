import 'dart:async';
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

  void setAll(Map<String, dynamic> initial) {
    state = Map<String, dynamic>.from(initial);
  }

  void updateField(String key, dynamic value, Function(String, dynamic) onExternalChange) {
    state = {...state, key: value};
    onExternalChange(key, value);
  }

  void removeField(String key, Function(String, dynamic) onExternalChange) {
    final updated = Map<String, dynamic>.from(state);
    updated.remove(key);
    state = updated;
    onExternalChange(key, null);
  }
}

class CommonPropertiesContainer extends ConsumerStatefulWidget {
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
  ConsumerState<CommonPropertiesContainer> createState() => _CommonPropertiesContainerState();
}

class _CommonPropertiesContainerState extends ConsumerState<CommonPropertiesContainer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commonPropsProvider(widget.fileId).notifier).setAll(widget.properties);
    });
  }

  @override
  void didUpdateWidget(covariant CommonPropertiesContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileId != widget.fileId || oldWidget.properties != widget.properties) {
      ref.read(commonPropsProvider(widget.fileId).notifier).setAll(widget.properties);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == FileType.block) {
      return CommonBlockPropertiesWidget(
        fileId: widget.fileId,
        onChanged: widget.onChanged,
      );
    } else if (widget.type == FileType.unit) {
      return CommonUnitPropertiesWidget(
        fileId: widget.fileId,
        onChanged: widget.onChanged,
      );
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
        _buildSectionHeader("Información General", Icons.info_outline),
        _buildCard([
          _buildTextField(fileId, 'name', 'Name', state['name'], (v) => update('name', v)),
          _buildTextField(fileId, 'description', 'Description', state['description'], (v) => update('description', v), multiline: true),
          _buildTextField(fileId, 'details', 'Details', state['details'], (v) => update('details', v), multiline: true),
        ]),

        _buildSectionHeader("Dimensiones y Resistencia", Icons.shield_outlined),
        _buildCard([
          _buildNumField(fileId, 'size', 'Size (1-16)', state['size'], (v) => update('size', v?.toInt() ?? 1)),
          _buildNumField(fileId, 'health', 'Health (HP Base)', state['health'], (v) => update('health', v?.toInt() ?? 100)),
          _buildNumField(fileId, 'buildCostMultiplier', 'Build Cost Multiplier', state['buildCostMultiplier'], (v) => update('buildCostMultiplier', v ?? 1.0), isDouble: true),
        ]),

        _buildSectionHeader("Construcción e Investigación", Icons.construction_outlined),
        _buildCard([
          _buildDropdown(fileId, 'category', 'Category', state['category']?.toString(), categories, (v) => update('category', v)),
          _buildTextField(fileId, 'research', 'Research (Padre en Árbol)', state['research'], (v) => update('research', v)),
          _buildSwitch('alwaysUnlocked', 'Always Unlocked (Siempre Desbloqueado)', state['alwaysUnlocked'], (v) => update('alwaysUnlocked', v)),
          const Divider(color: Colors.white12, height: 24),
          RequirementsBuilder(
            fileId: fileId,
            requirements: state['requirements'],
            onChanged: (v) => update('requirements', v),
          ),
        ]),

        _buildSectionHeader("Almacenamiento y Capacidades", Icons.inventory_2_outlined),
        _buildCard([
          _buildSwitch('hasItems', 'Has Items (Almacena Ítems)', state['hasItems'], (v) => update('hasItems', v)),
          if (hasItems) 
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: _buildNumField(fileId, 'itemCapacity', 'Item Capacity', state['itemCapacity'], (v) => update('itemCapacity', v?.toInt() ?? 10)),
            ),
          const Divider(color: Colors.white12, height: 16),
          _buildSwitch('hasLiquids', 'Has Liquids (Almacena Líquidos)', state['hasLiquids'], (v) => update('hasLiquids', v)),
          if (hasLiquids)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: _buildNumField(fileId, 'liquidCapacity', 'Liquid Capacity', state['liquidCapacity'], (v) => update('liquidCapacity', v ?? 10.0), isDouble: true),
            ),
          const Divider(color: Colors.white12, height: 16),
          _buildSwitch('hasPower', 'Has Power (Gestiona Energía)', state['hasPower'], (v) => update('hasPower', v)),
          if (hasPower) ...[
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Column(
                children: [
                  _buildSwitch('outputsPower', 'Outputs Power (Produce Energía)', state['outputsPower'], (v) => update('outputsPower', v)),
                  _buildSwitch('consumesPower', 'Consumes Power (Consume Energía)', state['consumesPower'], (v) => update('consumesPower', v)),
                ],
              ),
            ),
          ],
        ]),

        _buildSectionHeader("Físicas y Comportamiento", Icons.settings_input_component_outlined),
        _buildCard([
          _buildSwitch('solid', 'Solid (Sólido)', state['solid'], (v) => update('solid', v), defaultVal: true),
          _buildSwitch('targetable', 'Targetable (Apuntable por Enemigos)', state['targetable'], (v) => update('targetable', v), defaultVal: true),
          _buildSwitch('destructible', 'Destructible', state['destructible'], (v) => update('destructible', v), defaultVal: true),
          _buildSwitch('canOverdrive', 'Can Overdrive (Acelerable por Overdrive)', state['canOverdrive'], (v) => update('canOverdrive', v), defaultVal: true),
          _buildSwitch('update', 'Update (Lógica Activa en Cada Tick)', state['update'], (v) => update('update', v), defaultVal: true),
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
        _buildSectionHeader("Información General", Icons.info_outline),
        _buildCard([
          _buildTextField(fileId, 'name', 'Name', state['name'], (v) => update('name', v)),
          _buildTextField(fileId, 'description', 'Description', state['description'], (v) => update('description', v), multiline: true),
          _buildTextField(fileId, 'research', 'Research (Padre en Árbol)', state['research'], (v) => update('research', v)),
        ]),

        _buildSectionHeader("Estadísticas Vitales", Icons.favorite_border),
        _buildCard([
          _buildNumField(fileId, 'health', 'Health (HP)', state['health'], (v) => update('health', v ?? 100.0), isDouble: true),
          _buildNumField(fileId, 'armor', 'Armor (Blindaje)', state['armor'], (v) => update('armor', v ?? 0.0), isDouble: true),
          _buildNumField(fileId, 'speed', 'Speed (Velocidad)', state['speed'], (v) => update('speed', v ?? 1.0), isDouble: true),
          _buildNumField(fileId, 'hitSize', 'Hit Size (Radio de Impacto)', state['hitSize'], (v) => update('hitSize', v ?? 8.0), isDouble: true),
          _buildNumField(fileId, 'accel', 'Acceleration (Aceleración)', state['accel'], (v) => update('accel', v ?? 0.5), isDouble: true),
          _buildNumField(fileId, 'drag', 'Drag (Fricción/Resistencia)', state['drag'], (v) => update('drag', v ?? 0.1), isDouble: true),
          _buildNumField(fileId, 'rotateSpeed', 'Rotate Speed (Velocidad de Giro)', state['rotateSpeed'], (v) => update('rotateSpeed', v ?? 2.0), isDouble: true),
        ]),

        _buildSectionHeader("Capacidades Operativas", Icons.handyman_outlined),
        _buildCard([
          _buildNumField(fileId, 'itemCapacity', 'Item Capacity', state['itemCapacity'], (v) => update('itemCapacity', v?.toInt() ?? 0)),
          _buildNumField(fileId, 'buildSpeed', 'Build Speed (Vel. Construcción)', state['buildSpeed'], (v) => update('buildSpeed', v ?? 0.5), isDouble: true),
          _buildNumField(fileId, 'mineSpeed', 'Mine Speed (Vel. Minado)', state['mineSpeed'], (v) => update('mineSpeed', v ?? 1.0), isDouble: true),
          _buildNumField(fileId, 'mineTier', 'Mine Tier (Nivel de Minado)', state['mineTier'], (v) => update('mineTier', v?.toInt() ?? 1)),
        ]),

        _buildSectionHeader("Flags y Control", Icons.tune),
        _buildCard([
          _buildSwitch('flying', 'Flying (Unidad Voladora)', state['flying'], (v) => update('flying', v)),
          _buildSwitch('lowAltitude', 'Low Altitude (Baja Altura)', state['lowAltitude'], (v) => update('lowAltitude', v)),
          _buildSwitch('isEnemy', 'Is Enemy (Enemigo por Defecto)', state['isEnemy'], (v) => update('isEnemy', v), defaultVal: true),
          _buildSwitch('targetable', 'Targetable (Apuntable)', state['targetable'], (v) => update('targetable', v), defaultVal: true),
          _buildSwitch('hittable', 'Hittable (Recibe Daño)', state['hittable'], (v) => update('hittable', v), defaultVal: true),
          _buildSwitch('playerControllable', 'Player Controllable (Controlable por Jugador)', state['playerControllable'], (v) => update('playerControllable', v), defaultVal: true),
          _buildSwitch('logicControllable', 'Logic Controllable (Controlable por Procesador)', state['logicControllable'], (v) => update('logicControllable', v), defaultVal: true),
          _buildSwitch('useUnitCap', 'Use Unit Cap (Usa Límite de Unidades)', state['useUnitCap'], (v) => update('useUnitCap', v), defaultVal: true),
        ]),
      ],
    );
  }
}

// --- HELPER WIDGETS ---

Widget _buildSectionHeader(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    ),
  );
}

Widget _buildCard(List<Widget> children) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E24),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget _buildTextField(String fileId, String key, String label, dynamic value, Function(String) onChanged, {bool multiline = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey("${fileId}_$key"),
      initialValue: value?.toString() ?? '',
      style: const TextStyle(color: Colors.white, fontSize: 13),
      maxLines: multiline ? 3 : 1,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      onChanged: (val) => onChanged(val),
    ),
  );
}

Widget _buildNumField(String fileId, String key, String label, dynamic value, Function(num?) onChanged, {bool isDouble = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey("${fileId}_$key"),
      initialValue: value?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*'))],
      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
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
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFF24242C),
      borderRadius: BorderRadius.circular(8),
    ),
    child: SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      value: boolVal,
      activeColor: Colors.amber,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      onChanged: onChanged,
    ),
  );
}

Widget _buildDropdown(String fileId, String key, String label, String? value, List<String> options, Function(String) onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      key: ValueKey("${fileId}_$key"),
      value: (value != null && options.contains(value)) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF262630),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
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
  final String fileId;
  final dynamic requirements;
  final Function(List<dynamic>) onChanged;

  const RequirementsBuilder({super.key, required this.fileId, required this.requirements, required this.onChanged});

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
    if (widget.requirements != oldWidget.requirements || widget.fileId != oldWidget.fileId) {
      _parseReqs();
    }
  }

  void _parseReqs() {
    if (widget.requirements is List) {
      _reqList = (widget.requirements as List).map((e) => e.toString().trim()).toList();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Requirements (Coste de Recursos)", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            TextButton.icon(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: () {
                setState(() => _reqList.add("copper/10"));
                _notify();
              },
              icon: const Icon(Icons.add, color: Colors.amber, size: 16),
              label: const Text("Añadir", style: TextStyle(color: Colors.amber, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_reqList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF262630),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Sin costes asignados. Toca 'Añadir' para requerir ítems.",
              style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          )
        else
          ..._reqList.asMap().entries.map((entry) {
            int idx = entry.key;
            String reqStr = entry.value;
            List<String> parts = reqStr.split('/');
            String item = parts.isNotEmpty ? parts[0].trim() : 'copper';
            String qty = parts.length > 1 ? parts[1].trim() : '1';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: vanillaItems.contains(item) ? item : (vanillaItems.isNotEmpty ? vanillaItems.first : null),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262630),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
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
                    flex: 2,
                    child: TextFormField(
                      initialValue: qty,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF262630),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        isDense: true,
                        hintText: "Cant.",
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                      onChanged: (val) {
                        final n = int.tryParse(val) ?? 1;
                        setState(() => _reqList[idx] = "$item/$n");
                        _notify();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      setState(() => _reqList.removeAt(idx));
                      _notify();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
