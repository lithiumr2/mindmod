import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as filePicker;
import '../models/project_file.dart';
import '../providers/project_provider.dart';
import '../services/hjson_engine.dart';
import '../providers/locale_provider.dart';

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

  // 30 tipos de bloques nativos de Mindustry
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

  // Tipos de unidades de Mindustry
  final List<String> _unitTypes = [
    "flying", "mech", "legs", "naval", "payload", "crawl", "tether", "unit"
  ];

  // Ítems vanilla nativos de Mindustry con prefijo @
  static const List<String> _vanillaItems = [
    "@copper", "@lead", "@metaglass", "@graphite", "@sand", "@coal",
    "@titanium", "@thorium", "@silicon", "@plastanium", "@phase-fabric",
    "@surge-alloy", "@spore-pod", "@blast-compound", "@pyratite",
    "@beryllium", "@tungsten", "@oxide", "@carbide"
  ];

  // Líquidos vanilla nativos de Mindustry con prefijo @
  static const List<String> _vanillaLiquids = [
    "@water", "@slag", "@oil", "@cryofluid", "@neoplasm", "@arkycite",
    "@ozone", "@hydrogen", "@nitrogen", "@gallium"
  ];

  final Map<String, List<String>> _blockSpecificProps = {
    "Wall": ["chanceDeflect", "flashHit", "insulated", "absorbLasers"],
    "ShieldWall": ["chanceDeflect", "flashHit", "insulated", "absorbLasers", "shieldHealth", "cooldown"],
    "Door": ["openfx", "closefx"],
    "MendProjector": ["range", "reload", "healPercent", "phaseRangeBoost", "phaseBoost"],
    "OverdriveProjector": ["range", "speedBoost", "useTime", "phaseBoost", "phaseRangeBoost"],
    "ForceProjector": ["radius", "shieldHealth", "cooldownNormal", "cooldownLiquid", "cooldownBrokenBase"],
    "Conveyor": ["speed", "displayedSpeed"],
    "ArmoredConveyor": ["speed"],
    "Plastoconveyor": ["speed"],
    "StackConveyor": ["speed", "itemCapacity"],
    "Duct": ["speed", "transparent"],
    "MassDriver": ["range", "rotateSpeed", "translation", "minDist", "bulletSpeed"],
    "Drill": ["tier", "drillTime", "warmupSpeed", "liquidBoostIntensity", "drawMineItem"],
    "BurstDrill": ["tier", "drillTime", "itemCapacity", "arrows"],
    "ImpactDrill": ["tier", "drillTime"],
    "BeamDrill": ["tier", "drillTime", "range", "sparkColor", "pulse", "consumeTime"],
    "GenericCrafter": ["craftTime", "outputItem", "outputLiquid", "hasItems", "itemCapacity", "hasLiquids", "liquidCapacity"],
    "ItemTurret": ["range", "reload", "inaccuracy", "shootCone", "targetAir", "targetGround", "shootSound", "ammoTypes"],
    "LiquidTurret": ["range", "reload", "inaccuracy", "shootCone", "targetAir", "targetGround", "shootSound", "ammoType"],
    "PowerTurret": ["range", "reload", "shootType", "targetAir", "targetGround", "shootSound"],
    "LaserTurret": ["range", "reload", "firingMoveFract", "shootDuration", "shootSound"],
    "PowerNode": ["maxNodes", "laserRange", "laserColor1", "laserColor2"],
    "SurgeTower": ["maxNodes", "laserRange"],
    "BeamNode": ["range", "laserColor1"],
    "Battery": ["emptyPower"],
    "SolarPanel": ["powerProduction"],
    "NuclearReactor": ["itemDuration", "heating", "smokeThreshold", "explosionRadius", "explosionDamage", "fuelItem"],
    "ImpactReactor": ["warmupSpeed", "itemDuration", "powerProduction"],
    "LiquidRouter": ["liquidCapacity"],
    "LiquidJunction": ["capacity"]
  };

  final List<String> _itemProps = [
    "cost", "color", "flammability", "explosiveness", "radioactivity", "charge", "hardness"
  ];

  final List<String> _liquidProps = [
    "temperature", "viscosity", "flammability", "explosiveness", "heatCapacity", "color", "gas", "coolant"
  ];

  final List<String> _unitProps = [
    "type", "health", "armor", "hitSize", "speed", "rotateSpeed", "itemCapacity", "outlineColor", 
    "isEnemy", "coreUnitDock", "flying", "engineOffset", "engineSize", "lowAltitude", "circleTarget",
    "mechStepParticles", "mechLegColor", "stepShake", "legCount", "legLength", "legSpeed", "legForwardScl",
    "legMoveSpace", "hovering", "allowLegStep", "trailLength", "trailX", "trailY", "trailScl", "waterVision",
    "mineTier", "mineSpeed", "buildSpeed", "payloadCapacity", "controller", "targetAir", "targetGround", "faceTarget",
    "weapons", "abilities", "hasItems", "hasLiquids", "liquidCapacity", "requirements", "shadowElevation", "drag", "accel", "description", "details"
  ];

  final List<String> _statusProps = [
    "color", "damage", "damageMultiplier", "speedMultiplier", "armorMultiplier", "effect"
  ];

  final List<String> _sectorProps = [
    "sector", "planet", "captureWave", "difficulty", "alwaysUnlocked"
  ];

  final List<String> _weatherProps = [
    "type", "color", "noiseColor", "opacity", "duration", "sound"
  ];

  final List<String> _baseBlockProps = [
    "type", "health", "size", "requirements", "category",
    "solid", "destructible", "hasItems", "itemCapacity", "hasLiquids", "liquidCapacity",
    "hasPower", "consumesPower", "outputsPower", "alwaysUnlocked", "buildVisibility", "research", "envEnabled", "envDisabled",
    "floating", "placeableLiquid", "consumes", "outputItem", "outputItems", "outputLiquid", "outputLiquids"
  ];

  final Set<String> _numberProps = {
    "health", "size", "tier", "drillTime", "speed", "displayedSpeed", "craftTime",
    "range", "reload", "inaccuracy", "maxNodes", "laserRange", "powerProduction",
    "itemDuration", "heating", "smokeThreshold", "emptyPower", "instructionsPerTick",
    "memoryCapacity", "displaySize", "itemCapacity", "liquidCapacity", "hardness",
    "cost", "explosiveness", "flammability", "radioactivity", "charge", "temperature",
    "viscosity", "heatCapacity", "healPercent", "speedBoost", "radius", "shieldHealth",
    "armor", "hitSize", "drag", "accel", "capacity", "amount", "warmupSpeed", "liquidBoostIntensity", "consumeTime", "pumpAmount",
    "itemUseTime", "transportTime", "knockback", "bulletSpeed", "liquidPressure", "heatRequirement", "maxEfficiency", "flashThreshold", "explosionRadius",
    "explosionDamage", "chanceDeflect", "lightningChance", "lightningDamage", "cooldownNormal", "cooldownLiquid", "phaseRadiusBoost", "phaseShieldBoost",
    "speedBoostPhase", "useTime", "healAmount", "recoil", "restitution", "chargeTime", "chargeEffects", "bulletDamage", "constructTime",
    "dronesCreated", "maxInstructionsPerTick", "unitCapModifier", "thrusterLength", "rotateSpeed", "engineOffset", "engineSize",
    "stepShake", "legCount", "legLength", "legSpeed", "legForwardScl", "legMoveSpace", "trailLength", "trailX", "trailY", "trailScl",
    "mineTier", "mineSpeed", "buildSpeed", "payloadCapacity", "shootCone", "splashDamage", "splashDamageRadius", "statusDuration",
    "homingPower", "homingRange", "fragBullets", "pierceCap", "lifetime"
  };

  final Set<String> _boolProps = {
    "solid", "destructible", "hasItems", "hasLiquids", "hasPower", "consumesPower",
    "outputsPower", "alwaysUnlocked", "insulated", "absorbLasers", "flashHit",
    "targetAir", "targetGround", "gas", "coolant", "transparent", "flying", "hovering",
    "drawMineItem", "pulse", "invert", "leaks", "extinguish", "coreMerge", "incinerateNonBuildable",
    "isEnemy", "coreUnitDock", "lowAltitude", "circleTarget", "mechStepParticles", "allowLegStep", "waterVision",
    "faceTarget", "mirror", "rotate", "pierce", "pierceBuilding"
  };

  final Set<String> _colorProps = {
    "color", "barColor", "lightColor", "laserColor1", "laserColor2", "sparkColor",
    "emptyLightColor", "fullLightColor", "flameColor", "outlineColor", "mechLegColor", "noiseColor"
  };

  void _cleanInvalidProperties(FileType type, Map<String, dynamic> parsed) {
    if (type == FileType.item) {
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !_itemProps.contains(k));
    } else if (type == FileType.liquid) {
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !_liquidProps.contains(k));
    } else if (type == FileType.unit) {
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !_unitProps.contains(k));
    } else if (type == FileType.status) {
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !_statusProps.contains(k));
    } else if (type == FileType.sector) {
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !_sectorProps.contains(k));
    } else if (type == FileType.weather) {
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !_weatherProps.contains(k));
    } else if (type == FileType.block) {
      final currentType = parsed["type"]?.toString().replaceAll("\"", "") ?? "Wall";
      final allowed = Set<String>.from(_baseBlockProps)..addAll(_blockSpecificProps[currentType] ?? []);
      parsed.removeWhere((k, v) => k != "name" && k != "description" && !allowed.contains(k));
    }
  }

  void _saveChanges() {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile != null) {
      final hjsonString = HjsonEngine.stringify(_properties);
      ref.read(projectProvider.notifier).updateActiveFileContent(hjsonString);
      setState(() {
        _syntaxErrors = HjsonEngine.validateSyntax(hjsonString);
      });
    }
  }

  void _addProperty(String key) {
    setState(() {
      if (_numberProps.contains(key)) {
        _properties[key] = 0;
      } else if (_boolProps.contains(key)) {
        _properties[key] = false;
      } else if (_colorProps.contains(key)) {
        _properties[key] = "ffffff";
      } else if (key == "requirements" || key == "outputItems" || key == "results") {
        _properties[key] = ["@copper/20"];
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
    final Set<String> items = Set.from(_vanillaItems);
    for (var f in files) {
      if (f.type == FileType.item) {
        final clean = f.name.replaceAll(".hjson", "");
        items.add("@$clean");
        items.add(clean);
      }
    }
    return items.toList();
  }

  List<String> _getAllAvailableLiquids() {
    final files = ref.watch(projectProvider).files;
    final Set<String> liquids = Set.from(_vanillaLiquids);
    for (var f in files) {
      if (f.type == FileType.liquid) {
        final clean = f.name.replaceAll(".hjson", "");
        liquids.add("@$clean");
        liquids.add(clean);
      }
    }
    return liquids.toList();
  }

  void _applyPreset(String presetKey) {
    final activeFile = ref.read(projectProvider).activeFile;
    if (activeFile == null) return;
    final cleanName = activeFile.name.replaceAll(".hjson", "");
    setState(() {
      if (presetKey == "drill") {
        _properties = {
          "name": cleanName,
          "type": "Drill",
          "size": 2,
          "health": 240,
          "tier": 2,
          "drillTime": 400,
          "hasPower": true,
          "consumesPower": true,
          "category": "production",
          "requirements": ["@copper/30", "@lead/20"]
        };
      } else if (presetKey == "turret") {
        _properties = {
          "name": cleanName,
          "type": "ItemTurret",
          "size": 2,
          "health": 800,
          "range": 160,
          "reload": 20,
          "inaccuracy": 2,
          "targetAir": true,
          "targetGround": true,
          "shootSound": "shoot",
          "category": "turret",
          "requirements": ["@copper/75", "@lead/50"]
        };
      } else if (presetKey == "crafter") {
        _properties = {
          "name": cleanName,
          "type": "GenericCrafter",
          "size": 2,
          "health": 320,
          "craftTime": 60,
          "hasItems": true,
          "itemCapacity": 20,
          "hasLiquids": true,
          "liquidCapacity": 20,
          "hasPower": true,
          "category": "crafting",
          "outputItem": "@silicon",
          "requirements": ["@lead/60", "@copper/40"]
        };
      } else if (presetKey == "unit_flying") {
        _properties = {
          "name": cleanName,
          "type": "flying",
          "flying": true,
          "speed": 2.5,
          "health": 150,
          "range": 80,
          "hitSize": 8,
          "itemCapacity": 20,
          "hasItems": true,
          "requirements": ["@silicon/15"]
        };
      } else if (presetKey == "unit_mech") {
        _properties = {
          "name": cleanName,
          "type": "mech",
          "flying": false,
          "speed": 0.6,
          "health": 220,
          "range": 100,
          "hitSize": 10,
          "itemCapacity": 10,
          "hasItems": true,
          "requirements": ["@silicon/20", "@graphite/10"]
        };
      } else if (presetKey == "item_basic") {
        _properties = {
          "name": cleanName,
          "cost": 1.0,
          "color": "ffcc00",
          "flammability": 0.0,
          "explosiveness": 0.0,
          "radioactivity": 0.0,
          "charge": 0.0
        };
      }
    });
    _saveChanges();
  }

  void _openColorPicker(String key, String currentColorHex) {
    Color pickerColor;
    try {
      final clean = currentColorHex.replaceAll("#", "").trim();
      pickerColor = Color(int.parse(clean.length == 6 ? "FF$clean" : clean, radix: 16));
    } catch (_) {
      pickerColor = Colors.amber;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222228),
          title: Text("${tr('color_for')} $key", style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Colors.amber, Colors.orange, Colors.redAccent, Colors.pinkAccent,
                Colors.purpleAccent, Colors.deepPurpleAccent, Colors.indigoAccent,
                Colors.blueAccent, Colors.cyanAccent, Colors.tealAccent,
                Colors.greenAccent, Colors.lightGreenAccent, Colors.limeAccent,
                Colors.yellowAccent, Colors.brown, Colors.white, Colors.grey,
              ].map((c) {
                return InkWell(
                  onTap: () {
                    final hex = c.value.toRadixString(16).substring(2);
                    setState(() {
                      _properties[key] = hex;
                    });
                    _saveChanges();
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr('close'), style: const TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  List<String> _getRecommendedProperties(FileType fileType) {
    List<String> base = [];
    if (fileType == FileType.item) {
      base = List.from(_itemProps);
    } else if (fileType == FileType.liquid) {
      base = List.from(_liquidProps);
    } else if (fileType == FileType.unit) {
      base = List.from(_unitProps);
    } else if (fileType == FileType.status) {
      base = List.from(_statusProps);
    } else if (fileType == FileType.sector) {
      base = List.from(_sectorProps);
    } else if (fileType == FileType.weather) {
      base = List.from(_weatherProps);
    } else if (fileType == FileType.block) {
      base = List.from(_baseBlockProps);
      final currentType = _properties["type"]?.toString().replaceAll("\"", "") ?? "Wall";
      if (_blockSpecificProps.containsKey(currentType)) {
        base.addAll(_blockSpecificProps[currentType]!);
      }
    }
    return base.where((p) => !_properties.containsKey(p)).toList();
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
      if (mounted) setState(() {});
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
      _cleanInvalidProperties(activeFile.type, parsed);

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    final recommendedProps = _getRecommendedProperties(activeFile.type);
    final cleanBase = activeFile.name.replaceAll(".hjson", "");
    final files = ref.watch(projectProvider).files;
    final matchingSprites = files.where((f) => f.isImage && (f.name == "$cleanBase.png" || f.name == "sprites/$cleanBase.png")).toList();
    final matchingSprite = matchingSprites.isNotEmpty ? matchingSprites.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de Validación Sintáctica
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

        // Barra de Herramientas Compacta (Sprite + Plantillas + Recomendadas en una sola fila)
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E24),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              // Botón Compacto Sprite con ícono + y selector
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
                      Text(matchingSprite != null ? tr('png_ok') : tr('add_sprite'),
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
              const SizedBox(width: 8),
              Container(height: 20, width: 1, color: Colors.white12),
              const SizedBox(width: 8),
              // Scroll Horizontal con Plantillas y Recomendadas
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(tr('presets'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(width: 4),
                      if (activeFile.type == FileType.block) ...[
                        _buildPresetChip(tr('preset_drill'), () => _applyPreset("drill")),
                        const SizedBox(width: 4),
                        _buildPresetChip(tr('preset_turret'), () => _applyPreset("turret")),
                        const SizedBox(width: 4),
                        _buildPresetChip(tr('preset_crafter'), () => _applyPreset("crafter")),
                      ] else if (activeFile.type == FileType.unit) ...[
                        _buildPresetChip(tr('preset_flying'), () => _applyPreset("unit_flying")),
                        const SizedBox(width: 4),
                        _buildPresetChip(tr('preset_mech'), () => _applyPreset("unit_mech")),
                      ] else if (activeFile.type == FileType.item) ...[
                        _buildPresetChip(tr('preset_basic_item'), () => _applyPreset("item_basic")),
                      ],
                      if (recommendedProps.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(height: 18, width: 1, color: Colors.white12),
                        const SizedBox(width: 10),
                        Text(tr('add_prop'), style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        ...recommendedProps.take(12).map((prop) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: ActionChip(
                              backgroundColor: const Color(0xFF222228),
                              side: const BorderSide(color: Colors.white24, width: 0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              label: Text("+ $prop", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              onPressed: () => _addProperty(prop),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de Propiedades Activas
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._properties.entries
                        .where((e) => e.key != "consumes" && e.key != "outputItem")
                        .map((entry) {

                    final key = entry.key;
                    final value = entry.value;
                    final isVital = key == "name" || (key == "type" && (activeFile.type == FileType.block || activeFile.type == FileType.unit));
                    final isComplex = key == "requirements" || key == "outputItems" || key == "results" || key == "description" || key == "details" || key == "weapons" || key == "abilities" || key == "consumes";
                    final itemWidth = (isWide && !isComplex) ? (constraints.maxWidth / 2.0) - 6.0 : constraints.maxWidth;

              // Editor multilínea especial para requirements
              if (key == "requirements") {
                return SizedBox(width: constraints.maxWidth, child: _buildRequirementsCard(key, value, isVital));
              }

              return SizedBox(
      width: itemWidth,
      child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              key,
                              style: TextStyle(
                                color: isVital ? Colors.amber : Colors.white70,
                                fontWeight: isVital ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVital)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.lock_outline, size: 12, color: Colors.amber),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF222228),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: _buildInputField(key, value, activeFile.type),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isVital ? Icons.lock_outline : Icons.delete_outline,
                        color: isVital ? Colors.white24 : Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: isVital ? null : () => _removeProperty(key),
                    ),
                  ],
                ),
              );
            
                    }).toList(),
                    if (activeFile.type == FileType.block)
                      SizedBox(width: constraints.maxWidth, child: _buildConsumesAndOutputsCard()),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      backgroundColor: const Color(0xFF2A2A32),
      side: const BorderSide(color: Colors.amber, width: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      label: Text(label, style: const TextStyle(color: Colors.amber, fontSize: 11)),
      onPressed: onTap,
    );
  }

  // Componente interactivo para Requerimientos de Ítems (Mindustry Requirements)
  Widget _buildRequirementsCard(String key, dynamic value, bool isVital) {
    List<Map<String, dynamic>> itemsList = [];
    if (value is List) {
      for (var r in value) {
        final str = r.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          itemsList.add({
            'item': parts[0].trim(),
            'amount': int.tryParse(parts[1].trim()) ?? 10,
          });
        } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
          itemsList.add({
            'item': parts[0].trim(),
            'amount': 10,
          });
        }
      }
    } else if (value is String && value.isNotEmpty) {
      final clean = value.replaceAll('[', '').replaceAll(']', '').trim();
      for (var p in clean.split(',')) {
        final parts = p.trim().split('/');
        if (parts.length >= 2) {
          itemsList.add({
            'item': parts[0].trim(),
            'amount': int.tryParse(parts[1].trim()) ?? 10,
          });
        }
      }
    }

    final availableItems = _getAllAvailableItems();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222228),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text("$key${tr('items_req')}",
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 15, color: Colors.amber),
                label: Text(tr('add'), style: const TextStyle(color: Colors.amber, fontSize: 11)),
                onPressed: () {
                  final defaultItem = availableItems.isNotEmpty ? availableItems.first : "@copper";
                  itemsList.add({'item': defaultItem, 'amount': 20});
                  _updateRequirements(itemsList);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (itemsList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(tr('no_reqs'),
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            )
          else
            ...itemsList.asMap().entries.map((entry) {
              final idx = entry.key;
              final req = entry.value;
              final currentItem = req['item'].toString();
              final currentAmount = req['amount']?.toString() ?? '10';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Selector de ítem con @ y soporte vanilla/mod
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181C),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: availableItems.contains(currentItem) ? currentItem : null,
                            hint: Text(currentItem, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            dropdownColor: const Color(0xFF222228),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: availableItems.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                itemsList[idx]['item'] = newVal;
                                _updateRequirements(itemsList);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Cantidad requerida
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181C),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextFormField(
                          initialValue: currentAmount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: tr('qty'),
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                          ),
                          onChanged: (val) {
                            itemsList[idx]['amount'] = int.tryParse(val) ?? 0;
                            _updateRequirements(itemsList);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Botón de eliminar
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      onPressed: () {
                        itemsList.removeAt(idx);
                        _updateRequirements(itemsList);
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }


  Widget _buildConsumesAndOutputsCard() {
    // Lectura de datos
    final consumes = _properties["consumes"];
    double? power;
    List<Map<String, dynamic>> itemsList = [];
    
    if (consumes is Map) {
      if (consumes['power'] != null) {
        power = double.tryParse(consumes['power'].toString());
      }
      final itemsField = consumes['items'];
      List<dynamic> rawList = [];
      if (itemsField is List) {
        rawList = itemsField;
      } else if (itemsField is Map && itemsField['items'] is List) {
        rawList = itemsField['items'];
      }
      
      for (var item in rawList) {
        final str = item.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          itemsList.add({
            'item': parts[0].trim(),
            'amount': int.tryParse(parts[1].trim()) ?? 1,
          });
        }
      }
    }

    final outputItemStr = _properties["outputItem"]?.toString().trim() ?? "";
    String currentOutputItem = "";
    int currentOutputAmount = 1;
    if (outputItemStr.isNotEmpty) {
      final parts = outputItemStr.split('/');
      if (parts.length >= 2) {
        currentOutputItem = parts[0].trim();
        currentOutputAmount = int.tryParse(parts[1].trim()) ?? 1;
      } else {
        currentOutputItem = outputItemStr;
      }
    }

    final availableItems = _getAllAvailableItems();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222228),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_alt, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Text(tr('consumes_and_outputs'), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          
          // === SECCIÓN DE CONSUMO ===
          Text(tr('consumes_title'), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // Consumo de energía
          Row(
            children: [
              Text(tr('power_energy'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181C),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextFormField(
                    key: ValueKey("consumes_power_${power ?? 'none'}"),
                    initialValue: power?.toString() ?? "",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "0.0",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                    onChanged: (val) {
                      _updateConsumes(double.tryParse(val), itemsList);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Consumo de ítems
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('input_items'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 14, color: Colors.amber),
                label: Text(tr('add'), style: const TextStyle(color: Colors.amber, fontSize: 11)),
                onPressed: () {
                  final defaultItem = availableItems.isNotEmpty ? availableItems.first : "@copper";
                  itemsList.add({'item': defaultItem, 'amount': 1});
                  _updateConsumes(power, itemsList);
                },
              ),
            ],
          ),
          
          if (itemsList.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(tr('no_input_items'), style: const TextStyle(color: Colors.white38, fontSize: 11)),
            )
          else
            ...itemsList.asMap().entries.map((entry) {
              final idx = entry.key;
              final req = entry.value;
              final currentItem = req['item'].toString();
              final currentAmount = req['amount']?.toString() ?? '1';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181C),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: availableItems.contains(currentItem) ? currentItem : null,
                            hint: Text(currentItem, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            dropdownColor: const Color(0xFF222228),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: availableItems.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                itemsList[idx]['item'] = newVal;
                                _updateConsumes(power, itemsList);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF18181C),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextFormField(
                          initialValue: currentAmount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: tr('qty'),
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                          ),
                          onChanged: (val) {
                            itemsList[idx]['amount'] = int.tryParse(val) ?? 1;
                            _updateConsumes(power, itemsList);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      onPressed: () {
                        itemsList.removeAt(idx);
                        _updateConsumes(power, itemsList);
                      },
                    ),
                  ],
                ),
              );
            }),
            
          const Divider(color: Colors.white12, height: 24),

          // === SECCIÓN DE SALIDA ===
          Text(tr('output_title'), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          if (currentOutputItem.isEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('no_output_configured'), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14, color: Colors.amber),
                  label: Text(tr('add_output_item'), style: const TextStyle(color: Colors.amber, fontSize: 11)),
                  onPressed: () {
                    final defaultItem = availableItems.isNotEmpty ? availableItems.first : "@copper";
                    _updateOutputItem(defaultItem, 1);
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: availableItems.contains(currentOutputItem) ? currentOutputItem : null,
                        hint: Text(currentOutputItem, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        dropdownColor: const Color(0xFF222228),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        items: availableItems.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            _updateOutputItem(newVal, currentOutputAmount);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18181C),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextFormField(
                      initialValue: currentOutputAmount.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: tr('qty'),
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                      onChanged: (val) {
                        final amt = int.tryParse(val) ?? 1;
                        _updateOutputItem(currentOutputItem, amt);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                  onPressed: () {
                    setState(() {
                      _properties.remove("outputItem");
                    });
                    _saveChanges();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _updateConsumes(double? power, List<Map<String, dynamic>> itemsList) {
    setState(() {
      if (power == null && itemsList.isEmpty) {
        _properties.remove("consumes");
      } else {
        Map<String, dynamic> consumesObj = {};
        if (power != null) {
          consumesObj["power"] = power;
        }
        if (itemsList.isNotEmpty) {
          consumesObj["items"] = itemsList.map((r) => "\${r['item']}/\${r['amount']}").toList();
        }
        _properties["consumes"] = consumesObj;
      }
    });
    _saveChanges();
  }

  void _updateOutputItem(String item, int amount) {
    setState(() {
      _properties["outputItem"] = "$item/$amount";
    });
    _saveChanges();
  }


  void _updateRequirements(List<Map<String, dynamic>> itemsList) {
    final formatted = itemsList.map((r) => "${r['item']}/${r['amount']}").toList();
    setState(() {
      _properties["requirements"] = formatted;
    });
    _saveChanges();
  }

  Widget _buildInputField(String key, dynamic value, FileType fileType) {
    // 1. Selector masivo para la propiedad type en Bloques
    if (key == "type" && fileType == FileType.block) {
      String current = value.toString().replaceAll("\"", "");
      if (!_blockTypes.contains(current)) {
        current = _blockTypes.first;
      }
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          dropdownColor: const Color(0xFF222228),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _properties[key] = val;
              });
              _saveChanges();
            }
          },
          items: _blockTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        ),
      );
    }

    // 2. Selector masivo para la propiedad type en Unidades
    if (key == "type" && fileType == FileType.unit) {
      String current = value.toString().replaceAll("\"", "");
      if (!_unitTypes.contains(current)) {
        current = _unitTypes.first;
      }
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          dropdownColor: const Color(0xFF222228),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _properties[key] = val;
              });
              _saveChanges();
            }
          },
          items: _unitTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        ),
      );
    }

    // 3. Selector visual interactivo de color (ColorPicker)
    if (_colorProps.contains(key)) {
      final colorHex = value.toString().replaceAll("#", "").trim();
      Color previewColor;
      try {
        previewColor = Color(int.parse(colorHex.length == 6 ? "FF$colorHex" : colorHex, radix: 16));
      } catch (_) {
        previewColor = Colors.amber;
      }
      return InkWell(
        onTap: () => _openColorPicker(key, colorHex),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: previewColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "#$colorHex",
              style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: "monospace"),
            ),
            const Spacer(),
            const Icon(Icons.palette_outlined, color: Colors.amber, size: 18),
          ],
        ),
      );
    }

    // 4. Menú desplegable para recursos: ítems y líquidos
    
    if (key == "outputItem") {
      final candidates = _getAllAvailableItems();
      String currentItem = "copper";
      int currentAmount = 1;
      
      final str = value.toString().trim();
      final parts = str.split('/');
      if (parts.length >= 2) {
        currentItem = parts[0].trim();
        currentAmount = int.tryParse(parts[1].trim()) ?? 1;
      } else if (str.isNotEmpty) {
        currentItem = str;
      }

      return Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: candidates.contains(currentItem) ? currentItem : null,
                hint: Text(tr('preset_basic_item'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                dropdownColor: const Color(0xFF222228),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _properties[key] = "$v/$currentAmount");
                    _saveChanges();
                  }
                },
                items: candidates.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c as String, child: Text(c as String))).toList(),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: Colors.white12, margin: const EdgeInsets.symmetric(horizontal: 8)),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: currentAmount.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: tr('qty'),
              ),
              onChanged: (val) {
                final amt = int.tryParse(val) ?? 1;
                setState(() => _properties[key] = "$currentItem/$amt");
                _saveChanges();
              },
            ),
          ),
        ],
      );
    }

    if (key == "item" || key == "fuelItem") {
      final candidates = _getAllAvailableItems();
      final current = value.toString().trim();
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: candidates.contains(current) ? current : null,
          hint: Text(current.isEmpty ? tr('select_item') : current, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          dropdownColor: const Color(0xFF222228),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (v) {
            if (v != null) {
              setState(() => _properties[key] = v);
              _saveChanges();
            }
          },
          items: candidates.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c as String, child: Text(c as String))).toList(),
        ),
      );
    }

    if (key == "outputLiquid" || key == "liquid") {
      final candidates = _getAllAvailableLiquids();
      final current = value.toString().trim();
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: candidates.contains(current) ? current : null,
          hint: Text(current.isEmpty ? tr('select_liquid') : current, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          dropdownColor: const Color(0xFF222228),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (v) {
            if (v != null) {
              setState(() => _properties[key] = v);
              _saveChanges();
            }
          },
          items: candidates.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c as String, child: Text(c as String))).toList(),
        ),
      );
    }

    if (key == "ammoType" || key == "ammoTypes") {
      List<String> candidates = [..._getAllAvailableItems(), ..._getAllAvailableLiquids()];
      final current = value.toString().trim();
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: candidates.contains(current) ? current : null,
          hint: Text(current.isEmpty ? tr('select_ammo') : current, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          dropdownColor: const Color(0xFF222228),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (v) {
            if (v != null) {
              setState(() => _properties[key] = v);
              _saveChanges();
            }
          },
          items: candidates.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c as String, child: Text(c as String))).toList(),
        ),
      );
    }

    // 5. Booleanos estrictos
    if (value is bool || _boolProps.contains(key)) {
      final bool val = value is bool ? value : value.toString().toLowerCase() == "true";
      return Align(
        alignment: Alignment.centerLeft,
        child: Switch(
          value: val,
          activeColor: Colors.amber,
          onChanged: (bool newVal) {
            setState(() {
              _properties[key] = newVal;
            });
            _saveChanges();
          },
        ),
      );
    }

    // 6. Entradas de texto o números puros
    final isNum = _numberProps.contains(key);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: TextFormField(
        key: ValueKey("${_loadedFileId}_$key"),
        initialValue: value.toString(),
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
        inputFormatters: isNum
            ? [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*'))]
            : null,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: isNum ? "0" : tr('value'),
          hintStyle: const TextStyle(color: Colors.white24),
        ),
        onChanged: (newVal) {
          if (isNum) {
            final cleanVal = (newVal.isEmpty || newVal == '-') ? '0' : newVal;
            if (int.tryParse(cleanVal) != null) {
              _properties[key] = int.parse(cleanVal);
            } else if (double.tryParse(cleanVal) != null) {
              _properties[key] = double.parse(cleanVal);
            } else {
              _properties[key] = cleanVal;
            }
          } else {
            _properties[key] = newVal;
          }
          _saveChanges();
        },
      ),
    );
  }
}
