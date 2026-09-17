import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as filePicker;
import '../models/project_file.dart';
import '../providers/project_provider.dart';
import '../services/hjson_engine.dart';
import '../providers/locale_provider.dart';
import 'type_properties/type_properties_dispatcher.dart';
import 'type_properties/drawer_builder_widget.dart';
import 'common_properties_widget.dart';

class VisualFormWidget extends ConsumerStatefulWidget {
  const VisualFormWidget({super.key});

  @override
  ConsumerState<VisualFormWidget> createState() => _VisualFormWidgetState();
}

class _VisualFormWidgetState extends ConsumerState<VisualFormWidget> {
  String tr(String key) => ref.read(localeProvider.notifier).tr(key);

  Map<String, dynamic> _properties = {};
  List<String> _syntaxErrors = [];
  String _loadedFileId = "";
  Timer? _autoSaveTimer;
  bool _isDirty = false;
  DateTime _lastSaved = DateTime.now();

  final List<String> _blockTypes = [
    "Wall", "ShieldWall", "Door", "MendProjector", "OverdriveProjector", "OverdriveDome",
    "ForceProjector", "Conveyor", "ArmoredConveyor", "PlastaniumConveyor", "StackConveyor",
    "Duct", "MassDriver", "Drill", "BurstDrill", "ImpactDrill", "Pump", "SolidPump", "Fracker",
    "BeamDrill", "GenericCrafter", "HeatCrafter", "Separator", "Incinerator", "ItemTurret", "LiquidTurret", "PowerTurret",
    "ContinuousTurret", "PointDefenseTurret", "LaserTurret", "PowerNode", "SurgeTower", "BeamNode", "Battery",
    "SolarGenerator", "ThermalGenerator", "ConsumeGenerator", "NuclearReactor", "ImpactReactor", "LiquidRouter", "LiquidJunction",
    "Router", "Junction", "Sorter", "LogicSorter", "ItemBridge", "Conduit", "ArmoredConduit", "LiquidBridge",
    "UnitFactory", "Reconstructor", "UnitAssembler", "MessageBlock", "LogicBlock", "MemoryBlock", "StorageBlock", "CoreBlock"
  ];

  final List<String> _unitTypes = [
    "flying", "mech", "legs", "naval", "payload", "crawl", "tether", "unit"
  ];

  static const List<String> _vanillaItems = [
    "copper", "lead", "metaglass", "graphite", "sand", "coal",
    "titanium", "thorium", "silicon", "plastanium", "phase-fabric",
    "surge-alloy", "spore-pod", "blast-compound", "pyratite",
    "beryllium", "tungsten", "oxide", "carbide"
  ];

  static const List<String> _vanillaLiquids = [
    "water", "slag", "oil", "cryofluid", "neoplasm", "arkycite",
    "ozone", "hydrogen", "nitrogen", "@gallium"
  ];

  static const Set<String> _blockCommonKeys = {
    "name", "description", "details", "size", "health", "buildCostMultiplier", 
    "category", "research", "alwaysUnlocked", "requirements", 
    "hasItems", "itemCapacity", "hasLiquids", "liquidCapacity", 
    "hasPower", "outputsPower", "consumesPower", 
    "solid", "targetable", "destructible", "canOverdrive", "update", "type"
  };

  static const Set<String> _unitCommonKeys = {
    "name", "description", "research", "health", "armor", "speed", 
    "hitSize", "accel", "drag", "rotateSpeed", "itemCapacity", 
    "buildSpeed", "mineSpeed", "mineTier", "flying", "lowAltitude", 
    "isEnemy", "targetable", "hittable", "playerControllable", 
    "logicControllable", "useUnitCap", "type"
  };

  final Set<String> _numberProps = {
    "size", "health", "buildCostMultiplier", "itemCapacity", "liquidCapacity",
    "speed", "displayedSpeed", "range", "reload", "inaccuracy", "shootCone",
    "armor", "hitSize", "accel", "drag", "rotateSpeed", "buildSpeed", "mineSpeed",
    "mineTier", "craftTime", "powerProduction", "emptyPower", "maxNodes", "laserRange",
    "tier", "drillTime", "warmupSpeed", "liquidBoostIntensity", "cost", "hardness",
    "flammability", "explosiveness", "radioactivity", "charge", "capacity", "damage"
  };

  final Set<String> _boolProps = {
    "alwaysUnlocked", "hasItems", "hasLiquids", "hasPower", "outputsPower", "consumesPower",
    "solid", "targetable", "destructible", "canOverdrive", "update", "flying", "lowAltitude",
    "isEnemy", "hittable", "playerControllable", "logicControllable", "useUnitCap",
    "insulated", "absorbLasers", "flashHit", "transparent", "targetAir", "targetGround"
  };

  @override
  void initState() {
    super.initState();
    // Auto-save cada 2 segundos continuamente en background
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isDirty) {
        _forceFlushSave();
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_isDirty) {
      _forceFlushSave();
    }
    super.dispose();
  }

  void _forceFlushSave() {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile != null) {
      final hjsonString = HjsonEngine.stringify(_properties);
      ref.read(projectProvider.notifier).updateActiveFileContent(hjsonString);
      if (mounted) {
        setState(() {
          _isDirty = false;
          _lastSaved = DateTime.now();
          _syntaxErrors = HjsonEngine.validateSyntax(hjsonString);
        });
      }
    }
  }

  void _saveChanges() {
    _isDirty = true;
    _forceFlushSave();
  }

  void _addProperty(String key) {
    setState(() {
      if (_numberProps.contains(key)) {
        _properties[key] = 0;
      } else if (_boolProps.contains(key)) {
        _properties[key] = false;
      } else if (key == "requirements" || key == "outputItems" || key == "results") {
        _properties[key] = ["copper/20"];
      } else {
        _properties[key] = "";
      }
    });
    _saveChanges();
  }

  void _removeProperty(String key) {
    setState(() {
      _properties.remove(key);
    });
    _saveChanges();
  }

  List<String> _getAllAvailableItems() {
    final files = ref.watch(projectProvider).files;
    final customItems = files
        .where((f) => f.type == FileType.item)
        .map((f) => f.name.replaceAll('.hjson', ''))
        .toList();
    return [..._vanillaItems, ...customItems];
  }

  List<String> _getAllAvailableLiquids() {
    final files = ref.watch(projectProvider).files;
    final customLiquids = files
        .where((f) => f.type == FileType.liquid)
        .map((f) => f.name.replaceAll('.hjson', ''))
        .toList();
    return [..._vanillaLiquids, ...customLiquids];
  }

  Future<void> _pickSprite(String cleanBase) async {
    filePicker.FilePickerResult? result = await filePicker.FilePicker.platform.pickFiles(
      type: filePicker.FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final base64Image = base64Encode(bytes);
      ref.read(projectProvider.notifier).addFile(
        ProjectFile(
          name: '$cleanBase.png',
          type: FileType.image,
          content: base64Image,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) return const SizedBox.shrink();

    if (_loadedFileId != activeFile.name) {
      _loadedFileId = activeFile.name;
      _properties.clear();
      _syntaxErrors.clear();
      _syntaxErrors = HjsonEngine.validateSyntax(activeFile.content);
      final parsed = HjsonEngine.parse(activeFile.content);

      if (!parsed.containsKey("name") || parsed["name"].toString().trim().isEmpty) {
        parsed["name"] = activeFile.name.replaceAll(".hjson", "");
      }
      if (activeFile.type == FileType.block && !parsed.containsKey("type")) {
        parsed["type"] = "Wall";
      }
      if (activeFile.type == FileType.unit && !parsed.containsKey("type")) {
        parsed["type"] = "flying";
      }
      _properties = parsed;
      _isDirty = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    final cleanBase = activeFile.name.replaceAll(".hjson", "");
    final files = ref.watch(projectProvider).files;
    final matchingSprites = files.where((f) => f.isImage && (f.name == "$cleanBase.png" || f.name == "sprites/$cleanBase.png")).toList();
    final matchingSprite = matchingSprites.isNotEmpty ? matchingSprites.first : null;

    final isBlock = activeFile.type == FileType.block;
    final isUnit = activeFile.type == FileType.unit;

    // Filter properties not handled in common widgets
    final customEntries = _properties.entries.where((entry) {
      if (isBlock && _blockCommonKeys.contains(entry.key)) return false;
      if (isUnit && _unitCommonKeys.contains(entry.key)) return false;
      if (entry.key == "name" || entry.key == "type") return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Validation Bar
        if (_syntaxErrors.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.red.withOpacity(0.2),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _syntaxErrors.first,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // Compact Top Toolbar (Type selector + Sprite + Autosave indicator)
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E24),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              // Type Dropdown (Mindustry Specific Subtype)
              if (isBlock || isUnit) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282832),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (isBlock ? _blockTypes : _unitTypes).contains(_properties["type"]?.toString())
                          ? _properties["type"].toString()
                          : (isBlock ? _blockTypes.first : _unitTypes.first),
                      dropdownColor: const Color(0xFF222228),
                      style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                      isDense: true,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _properties["type"] = v);
                          _saveChanges();
                        }
                      },
                      items: (isBlock ? _blockTypes : _unitTypes)
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Sprite Button
              InkWell(
                onTap: () => _pickSprite(cleanBase),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: matchingSprite != null ? Colors.green.withOpacity(0.15) : const Color(0xFF2A2A32),
                    border: Border.all(
                      color: matchingSprite != null ? Colors.greenAccent.withOpacity(0.5) : Colors.white24,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        matchingSprite != null ? Icons.image : Icons.add_photo_alternate_outlined,
                        size: 15,
                        color: matchingSprite != null ? Colors.greenAccent : Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        matchingSprite != null ? "Sprite OK" : "Añadir Sprite",
                        style: TextStyle(
                          color: matchingSprite != null ? Colors.greenAccent : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Auto-save Indicator Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isDirty ? Colors.amber.withOpacity(0.15) : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isDirty ? Colors.amber.withOpacity(0.4) : Colors.greenAccent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isDirty ? Icons.sync : Icons.cloud_done_outlined,
                      size: 13,
                      color: _isDirty ? Colors.amber : Colors.greenAccent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isDirty ? "Guardando..." : "Autoguardado",
                      style: TextStyle(
                        color: _isDirty ? Colors.amber : Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main Form Body
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Universal Common Properties Component
                if (isBlock || isUnit)
                  CommonPropertiesContainer(
                    fileId: _loadedFileId,
                    type: activeFile.type,
                    properties: _properties,
                    onChanged: (key, val) {
                      setState(() {
                        if (val == null) {
                          _properties.remove(key);
                        } else {
                          _properties[key] = val;
                        }
                      });
                      _saveChanges();
                    },
                  )
                else
                  // Other file types (Items, Liquids, etc.) - standard key/value list
                  ..._properties.entries.map((e) => _buildGenericPropertyRow(e.key, e.value)),

                // 2. Extra/Custom Properties Section
                if (isBlock || isUnit) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Propiedades Adicionales Personalizadas",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddPropertyDialog(context),
                        icon: const Icon(Icons.add, color: Colors.amber, size: 16),
                        label: const Text("Nueva Propiedad", style: TextStyle(color: Colors.amber, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (customEntries.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Text(
                        "No hay propiedades adicionales. Puedes pulsar '+ Nueva Propiedad' para añadir campos avanzados específicos de Mindustry.",
                        style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    ...customEntries.map((e) => _buildGenericPropertyRow(e.key, e.value)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericPropertyRow(String key, dynamic value) {
    final isNum = _numberProps.contains(key) || value is num;
    final isBool = _boolProps.contains(key) || value is bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              key,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isBool
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Switch(
                      value: value is bool ? value : value.toString().toLowerCase() == "true",
                      activeColor: Colors.amber,
                      onChanged: (v) {
                        setState(() => _properties[key] = v);
                        _saveChanges();
                      },
                    ),
                  )
                : TextFormField(
                    key: ValueKey("${_loadedFileId}_$key"),
                    initialValue: value?.toString() ?? '',
                    keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Color(0xFF262630),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) {
                      if (isNum) {
                        final n = double.tryParse(v);
                        if (n != null) {
                          _properties[key] = n % 1 == 0 ? n.toInt() : n;
                        } else {
                          _properties[key] = v;
                        }
                      } else {
                        _properties[key] = v;
                      }
                      _saveChanges();
                    },
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            onPressed: () => _removeProperty(key),
          ),
        ],
      ),
    );
  }

  void _showAddPropertyDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF202026),
        title: const Text("Añadir Propiedad", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nombre de propiedad (ej. reload, rotateSpeed)",
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            onPressed: () {
              final prop = controller.text.trim();
              if (prop.isNotEmpty) {
                _addProperty(prop);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Añadir"),
          ),
        ],
      ),
    );
  }
}
