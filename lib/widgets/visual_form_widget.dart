import 'package:file_picker/file_picker.dart' as filePicker;
import "dart:convert";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_colorpicker/flutter_colorpicker.dart";
import "../providers/project_provider.dart";
import "../models/project_file.dart";
import "../services/hjson_engine.dart";

class VisualFormWidget extends ConsumerStatefulWidget {
  const VisualFormWidget({super.key});

  @override
  ConsumerState<VisualFormWidget> createState() => _VisualFormWidgetState();
}

class _VisualFormWidgetState extends ConsumerState<VisualFormWidget> {
  Map<String, dynamic> _properties = {};
  String? _loadedFileId;
  List<String> _syntaxErrors = [];

  // ==========================================
  // DEFINICIONES MASIVAS DE MINDUSTRY V7/V8
  // ==========================================

  // 1. Tipos de bloques masivos ampliados
  final List<String> _blockTypes = [
    // Defensa
    "Wall", "ShieldWall", "Door", "MendProjector", "OverdriveProjector", "ForceProjector", "ShockMine",
    // Distribución
    "Conveyor", "ArmoredConveyor", "Plastoconveyor", "StackConveyor", "Duct", "ArmoredDuct",
    "Router", "Distributor", "Junction", "DuctJunction", "ItemBridge", "DuctBridge",
    "Sorter", "InvertedSorter", "OverflowGate", "UnderflowGate", "MassDriver", "PayloadConveyor", "PayloadRouter",
    // Líquidos
    "Conduit", "ArmoredConduit", "PlatedConduit", "LiquidRouter", "LiquidJunction", "BridgeConduit", "LiquidTank",
    // Producción y Minería
    "Drill", "BurstDrill", "ImpactDrill", "BeamDrill", "GenericCrafter", "Separator", "Incinerator",
    // Energía
    "PowerNode", "SurgeTower", "BeamNode", "Battery", "SolarPanel", "CombustionGenerator", 
    "ThermalGenerator", "SteamGenerator", "NuclearReactor", "ImpactReactor",
    // Torretas
    "ItemTurret", "LiquidTurret", "PowerTurret", "LaserTurret", "PointDefenseTurret", "TractorBeamTurret",
    // Unidades y Cargas
    "UnitFactory", "Reconstructor", "UnitAssembler", "PayloadLoader", "PayloadUnloader", "Constructor",
    // Lógica e Interactivos
    "MessageBlock", "SwitchBlock", "LogicProcessor", "MemoryBlock", "LogicDisplay", "Canvas"
  ];

  // 2. Propiedades por defecto / específicas según subtipo
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
    "GenericCrafter": ["craftTime", "outputItem", "outputLiquid"],
    "ItemTurret": ["range", "reload", "inaccuracy", "shootCone", "targetAir", "targetGround", "shootSound", "ammoTypes"],
    "LiquidTurret": ["range", "reload", "inaccuracy", "shootCone", "targetAir", "targetGround", "shootSound", "ammoType"],
    "PowerTurret": ["range", "reload", "shootType", "targetAir", "targetGround", "shootSound"],
    "LaserTurret": ["range", "reload", "firingMoveFract", "shootDuration", "shootSound"],
    "PowerNode": ["maxNodes", "laserRange", "laserColor1", "laserColor2"],
    "SurgeTower": ["maxNodes", "laserRange"],
    "BeamNode": ["range", "laserColor1"],
    "Battery": ["emptyPower"],
    "SolarPanel": ["powerProduction"],
    "CombustionGenerator": ["powerProduction", "itemDuration"],
    "ThermalGenerator": ["powerProduction", "generateEffect"],
    "NuclearReactor": ["heating", "itemDuration", "smokeThreshold", "explosionRadius", "explosionDamage"],
    "ImpactReactor": ["powerProduction", "itemDuration", "warmupSpeed"],
    "UnitFactory": ["plans", "produceTime"],
    "Reconstructor": ["constructTime", "upgrades"],
    "LogicProcessor": ["instructionsPerTick", "range"],
    "MemoryBlock": ["memoryCapacity"],
    "LogicDisplay": ["displaySize"],
    "MessageBlock": ["maxTextLength"],
  };

  // Listas de propiedades para Items y Líquidos
  final List<String> _itemProps = [
    "description", "details", "color", "explosiveness", "flammability", "radioactivity", "charge",
    "hardness", "cost", "alwaysUnlocked", "frames", "transitionDamage", "buildable", "hidden"
  ];

  final List<String> _liquidProps = [
    "description", "details", "color", "temperature", "flammability", "explosiveness", "viscosity",
    "heatCapacity", "barColor", "lightColor", "effect", "gas", "coolant", "hidden", "incinerable"
  ];

  
  final List<String> _unitProps = [
    "description", "details", "type", "health", "speed", "flying", "range", "armor", "hitSize", 
    "weapons", "abilities", "controller", "hovering", "shadowElevation", "drag", "accel", "itemCapacity"
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
    "solid", "destructible", "hasItems", "hasLiquids",
    "hasPower", "consumesPower", "outputsPower", "itemCapacity", "liquidCapacity"
  ];

  // Identificadores de tipos de datos estrictos
  final Set<String> _numberProps = {
    "health", "size", "tier", "drillTime", "speed", "displayedSpeed", "craftTime",
    "range", "reload", "inaccuracy", "maxNodes", "laserRange", "powerProduction",
    "itemDuration", "heating", "smokeThreshold", "emptyPower", "instructionsPerTick",
    "memoryCapacity", "displaySize", "itemCapacity", "liquidCapacity", "hardness",
    "cost", "explosiveness", "flammability", "radioactivity", "charge", "temperature",
    "viscosity", "heatCapacity", "healPercent", "speedBoost", "radius", "shieldHealth"
  };

  final Set<String> _boolProps = {
    "solid", "destructible", "hasItems", "hasLiquids", "hasPower", "consumesPower",
    "outputsPower", "alwaysUnlocked", "insulated", "absorbLasers", "flashHit",
    "targetAir", "targetGround", "gas", "coolant", "transparent"
  };

  final Set<String> _colorProps = {
    "color", "barColor", "lightColor", "laserColor1", "laserColor2", "sparkColor"
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VisualFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  
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
    if (activeFile == null) return;

    // Garantizar que name y type (en bloques) nunca desaparezcan
    if (!_properties.containsKey("name") || _properties["name"].toString().trim().isEmpty) {
      _properties["name"] = activeFile.name.replaceAll(".hjson", "");
    }
    if (activeFile.type == FileType.block && !_properties.containsKey("type")) {
      _properties["type"] = "Wall";
    }

    // Tipado estricto al momento de serializar
    final cleaned = <String, dynamic>{};
    _properties.forEach((k, v) {
      if (_boolProps.contains(k)) {
        cleaned[k] = v == true || v.toString() == "true";
      } else if (_numberProps.contains(k)) {
        if (v is num) {
          cleaned[k] = v;
        } else {
          final str = v.toString().trim();
          if (int.tryParse(str) != null) {
            cleaned[k] = int.parse(str);
          } else if (double.tryParse(str) != null) {
            cleaned[k] = double.parse(str);
          } else {
            cleaned[k] = 0; // Forced strict numeric fallback to prevent crashes
          }
        }
      } else {
        cleaned[k] = v;
      }
    });

    final serialized = HjsonEngine.stringify(cleaned);
    _syntaxErrors = HjsonEngine.validateSyntax(serialized);
    ref.read(projectProvider.notifier).updateActiveFileContent(serialized);

    // Gestor automático de localización
    _syncLocalizationKey(activeFile.name.replaceAll(".hjson", ""), _properties["description"]?.toString() ?? "");
  }

  void _syncLocalizationKey(String itemName, String desc) {
    // Sincroniza bundle_es.properties o similar en el proyecto si existe
    final files = ref.read(projectProvider).files;
    final bundleFile = files.where((f) => f.name.endsWith(".properties") || f.name.contains("bundle")).firstOrNull;
    if (bundleFile != null) {
      final key = "item.$itemName.name = $itemName\nitem.$itemName.description = $desc";
      if (!bundleFile.content.contains(itemName)) {
        ref.read(projectProvider.notifier).addFile(bundleFile.copyWith(
          content: "${bundleFile.content}\n$key"
        ));
      }
    }
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
          "requirements": "[copper/30, lead/20]"
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
          "requirements": "[copper/75, lead/50]"
        };
      } else if (presetKey == "crafter") {
        _properties = {
          "name": cleanName,
          "type": "GenericCrafter",
          "size": 2,
          "health": 320,
          "craftTime": 60,
          "hasItems": true,
          "hasPower": true,
          "category": "crafting",
          "requirements": "[lead/60, silicon/40]"
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222228),
        title: Text("Seleccionar color ($key)", style: const TextStyle(color: Colors.amber, fontSize: 16)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              final hex = pickerColor.value.toRadixString(16).padLeft(8, "0").substring(2);
              setState(() {
                _properties[key] = hex;
              });
              _saveChanges();
              Navigator.pop(context);
            },
            child: const Text("Aplicar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addProperty(String key) {
    setState(() {
      if (_boolProps.contains(key)) {
        _properties[key] = true;
      } else if (_numberProps.contains(key)) {
        _properties[key] = (key == "size" || key == "tier") ? 1 : 100;
      } else if (_colorProps.contains(key)) {
        _properties[key] = "ffd37f";
      } else {
        _properties[key] = "";
      }
    });
    _saveChanges();
  }

  void _removeProperty(String key) {
    final activeFile = ref.read(projectProvider).activeFile;

    // Bloqueo estricto de campos vitales
    if (key == "name" || key == "type") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("El campo obligatorio  no puede ser eliminado."),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _properties.remove(key);
    });
    _saveChanges();
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

  Widget _buildSpriteLinkModule(String currentFileName) {
    final cleanBase = currentFileName.replaceAll(".hjson", "");
    final files = ref.watch(projectProvider).files;
    final matchingSprite = files.where((f) => f.isImage && (f.name == "$cleanBase.png" || f.name == "sprites/$cleanBase.png")).firstOrNull;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: matchingSprite != null ? Colors.green.withOpacity(0.4) : Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: matchingSprite != null && matchingSprite.binaryContent != null
                ? Image.memory(matchingSprite.binaryContent!, fit: BoxFit.contain)
                : const Icon(Icons.image_not_supported_outlined, color: Colors.white30, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matchingSprite != null ? "Sprite Vinculado: ${matchingSprite.name}" : "Sin Sprite específico ($cleanBase.png)",
                  style: TextStyle(
                    color: matchingSprite != null ? Colors.greenAccent : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  matchingSprite != null ? "La textura se incluirá automáticamente en la exportación" : "Sube .png en la carpeta sprites",
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.upload_file, size: 16, color: Colors.amber),
            label: const Text("Subir", style: TextStyle(color: Colors.amber, fontSize: 12)),
            onPressed: () async {
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
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider).activeFile;
    if (activeFile == null) return const SizedBox.shrink();

    // AISLAMIENTO ESTRICTO: evaluar sincronamente si el archivo cambió
    if (_loadedFileId != activeFile.name) {
      _loadedFileId = activeFile.name;
      _properties.clear();
      _syntaxErrors.clear();
      
      _syntaxErrors = HjsonEngine.validateSyntax(activeFile.content);
      final parsed = HjsonEngine.parse(activeFile.content);

      // BLOQUEO Y LIMPIEZA DE HERENCIA: elimina propiedades que no corresponden a su tipo
      _cleanInvalidProperties(activeFile.type, parsed);

      if (!parsed.containsKey("name") || parsed["name"].toString().trim().isEmpty) {
        parsed["name"] = activeFile.name.replaceAll(".hjson", "");
      }
      if (activeFile.type == FileType.block && !parsed.containsKey("type")) {
        parsed["type"] = "Wall";
      }

      _properties = parsed;
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) setState(() {});
      });
    }

    final recommendedProps = _getRecommendedProperties(activeFile.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de Validación Sintáctica si hay errores
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

        // Módulo de Asociación de Sprites
        _buildSpriteLinkModule(activeFile.name),

        // Barra de Presets Rápidos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text("Plantillas: ", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(width: 8),
                if (activeFile.type == FileType.block) ...[
                  _buildPresetChip("Taladro", () => _applyPreset("drill")),
                  const SizedBox(width: 6),
                  _buildPresetChip("Torreta", () => _applyPreset("turret")),
                  const SizedBox(width: 6),
                  _buildPresetChip("Fábrica", () => _applyPreset("crafter")),
                ] else if (activeFile.type == FileType.item) ...[
                  _buildPresetChip("Ítem Básico", () => _applyPreset("item_basic")),
                ],
              ],
            ),
          ),
        ),

        // Recomendaciones
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Propiedades recomendadas para añadir:",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: recommendedProps.take(12).map((prop) {
                  return InkWell(
                    onTap: () => _addProperty(prop),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("+ $prop", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Lista de Propiedades Activas
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _properties.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              final isVital = key == "name" || (key == "type" && activeFile.type == FileType.block);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Row(
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                              color: isVital ? Colors.amber : Colors.white70,
                              fontWeight: isVital ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
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
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      backgroundColor: const Color(0xFF2A2A32),
      side: const BorderSide(color: Colors.amber, width: 0.8),
      label: Text(label, style: const TextStyle(color: Colors.amber, fontSize: 11)),
      onPressed: onTap,
    );
  }

  Widget _buildInputField(String key, dynamic value, FileType fileType) {
    // 1. Selector masivo para la propiedad type
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

    // 2. Selector visual interactivo de color (ColorPicker)
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

    // 3. Menú desplegable para referencias cruzadas (requirements, outputItem, etc.)
    if (key == "outputItem" || key == "outputLiquid" || key == "ammoType") {
      final allFiles = ref.watch(projectProvider).files;
      final candidates = allFiles
          .where((f) => f.type == FileType.item || f.type == FileType.liquid)
          .map((f) => f.name.replaceAll(".hjson", ""))
          .toList();

      if (candidates.isNotEmpty) {
        final current = value.toString();
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: candidates.contains(current) ? current : null,
            hint: Text(current.isEmpty ? "Seleccionar ítem/líquido" : current, style: const TextStyle(color: Colors.white70)),
            dropdownColor: const Color(0xFF222228),
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (v) {
              if (v != null) {
                setState(() => _properties[key] = v);
                _saveChanges();
              }
            },
            items: candidates.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          ),
        );
      }
    }

    // 4. Booleanos estrictos
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

    // 5. Entradas de texto o números puros
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
          hintText: isNum ? "0" : "valor",
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
