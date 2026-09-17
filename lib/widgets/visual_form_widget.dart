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

/// Widget unificado del Formulario Visual para Mindustry v7/v8.
/// Unifica en una sola vista continua con alta densidad visual:
/// 1. Cabecera con selector de subtipo y autoguardado continuo en tiempo real.
/// 2. Propiedades comunes universales organizadas en pares (2 por fila).
/// 3. Propiedades específicas por tipo de entidad (TypePropertiesDispatcher).
/// 4. Renderizado Visual avanzado (DrawerBuilderWidget para bloques).
/// 5. Propiedades adicionales personalizadas con modal para añadir nuevas claves.
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
    "Wall", "ShieldWall", "Door", "MendProjector", "OverdriveProjector", "OverdriveDome", "ForceProjector",
    "GenericCrafter", "HeatCrafter", "Incinerator", "Separator",
    "ConsumeGenerator", "ThermalGenerator", "SolarGenerator", "NuclearReactor", "ImpactReactor", "PowerNode", "SurgeTower", "BeamNode",
    "ItemTurret", "LiquidTurret", "PowerTurret", "LaserTurret", "ContinuousTurret", "PointDefenseTurret",
    "Drill", "BurstDrill", "ImpactDrill", "BeamDrill", "Pump", "SolidPump", "Fracker",
    "Conveyor", "ArmoredConveyor", "PlastaniumConveyor", "StackConveyor", "Duct", "MassDriver",
  ];

  final List<String> _unitTypes = [
    "flying", "mech", "legs", "naval", "payload", "tether", "crawl"
  ];

  // Set de propiedades comunes ya manejadas por el widget de comunes
  final Set<String> _handledCommonProps = {
    'localizedName', 'name', 'description', 'details', 'size', 'health',
    'buildCostMultiplier', 'category', 'research', 'alwaysUnlocked', 'solid',
    'destructible', 'targetable', 'canOverdrive', 'update', 'hasItems',
    'itemCapacity', 'hasLiquids', 'liquidCapacity', 'hasPower', 'outputsPower',
    'consumesPower', 'requirements', 'hitSize', 'armor', 'speed', 'rotateSpeed',
    'accel', 'drag', 'mineSpeed', 'mineTier', 'buildSpeed', 'flying',
    'lowAltitude', 'isEnemy', 'hittable', 'playerControllable', 'logicControllable',
    'useUnitCap', 'type', 'drawer'
  };

  @override
  void initState() {
    super.initState();
    // Autoguardado periódico en segundo plano cada 1.5 segundos
    _autoSaveTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_isDirty && mounted) {
        _commitSave();
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_isDirty) {
      _commitSave();
    }
    super.dispose();
  }

  List<String> _getAllAvailableItems() {
    final proj = ref.read(projectProvider);
    final Set<String> items = {
      'copper', 'lead', 'metaglass', 'graphite', 'sand', 'coal', 'titanium',
      'thorium', 'scrap', 'silicon', 'plastanium', 'phase-fabric', 'surge-alloy',
      'spore-pod', 'blast-compound', 'pyratite', 'beryllium', 'tungsten',
      'oxide', 'carbide', 'fissile-matter', 'dormant-cyst'
    };
    if (proj != null) {
      for (final f in proj.files) {
        if (f.type == FileType.item) {
          items.add(f.name.replaceAll('.hjson', '').replaceAll('.json', ''));
        }
      }
    }
    return items.toList();
  }

  List<String> _getAllAvailableLiquids() {
    final proj = ref.read(projectProvider);
    final Set<String> liquids = {
      'water', 'slag', 'oil', 'cryofluid', 'gallium', 'neoplasm', 'arkycite', 'ozone', 'hydrogen', 'nitrogen'
    };
    if (proj != null) {
      for (final f in proj.files) {
        if (f.type == FileType.liquid) {
          liquids.add(f.name.replaceAll('.hjson', '').replaceAll('.json', ''));
        }
      }
    }
    return liquids.toList();
  }

  void _loadProperties(ProjectFile file) {
    if (_loadedFileId == file.id) return;
    _loadedFileId = file.id;

    if (file.content.trim().isEmpty) {
      _properties = {};
      _syntaxErrors = [];
      _isDirty = false;
      return;
    }

    try {
      final parsed = HjsonEngine.parse(file.content);
      if (parsed is Map<String, dynamic>) {
        _properties = Map<String, dynamic>.from(parsed);
        _syntaxErrors = [];
      } else {
        _properties = {};
        _syntaxErrors = ["El contenido raíz debe ser un objeto JSON/HJSON."];
      }
    } catch (e) {
      _properties = {};
      _syntaxErrors = ["Error de sintaxis: $e"];
    }
    _isDirty = false;
  }

  void _markDirtyAndSave() {
    _isDirty = true;
    _saveChanges();
  }

  void _saveChanges() {
    _isDirty = true;
  }

  void _commitSave() {
    final activeFile = ref.read(projectProvider)?.activeFile;
    if (activeFile == null) return;

    try {
      final newContent = HjsonEngine.stringify(_properties);
      ref.read(projectProvider.notifier).updateFileContent(activeFile.id, newContent);
      setState(() {
        _isDirty = false;
        _lastSaved = DateTime.now();
      });
    } catch (e) {
      debugPrint("Error guardando Hjson: $e");
    }
  }

  void _onCommonPropertyChange(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _properties.remove(key);
      } else {
        _properties[key] = value;
      }
    });
    _markDirtyAndSave();
  }

  void _onTypePropertiesChange(Map<String, dynamic> newProps) {
    setState(() {
      _properties = newProps;
    });
    _markDirtyAndSave();
  }

  void _onTypeSelected(String newType) {
    setState(() {
      _properties['type'] = newType;
    });
    _markDirtyAndSave();
  }

  void _addProperty(String key) {
    if (key.trim().isEmpty) return;
    setState(() {
      _properties[key.trim()] = "";
    });
    _markDirtyAndSave();
  }

  void _removeProperty(String key) {
    setState(() {
      _properties.remove(key);
    });
    _markDirtyAndSave();
  }

  Widget _buildSectionBanner(String title, IconData icon, {Color color = const Color(0xFF58A6FF)}) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFile = ref.watch(projectProvider.select((p) => p?.activeFile));

    if (activeFile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize_outlined, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(tr('no_file_open'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    _loadProperties(activeFile);

    if (_syntaxErrors.isNotEmpty) {
      return Container(
        color: const Color(0xFF0D1117),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text("Error al interpretar HJSON", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ..._syntaxErrors.map((err) => Text(err, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _properties = {};
                    _syntaxErrors = [];
                  });
                  _saveChanges();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Reiniciar a Estructura Limpia"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    final isBlock = activeFile.type == FileType.block;
    final isUnit = activeFile.type == FileType.unit;
    final currentType = _properties['type']?.toString().replaceAll('"', '').trim() ?? (isBlock ? 'GenericCrafter' : (isUnit ? 'flying' : ''));

    // Propiedades adicionales (las que no están cubiertas por los widgets dedicados)
    final customEntries = _properties.entries.where((e) => !_handledCommonProps.contains(e.key)).toList();

    return Column(
      children: [
        // -------------------------------------------------------------
        // BARRA SUPERIOR DE ACCIONES Y AUTOGUARDADO
        // -------------------------------------------------------------
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              Icon(
                isBlock ? Icons.grid_view : (isUnit ? Icons.smart_toy_outlined : Icons.description_outlined),
                size: 16,
                color: const Color(0xFF58A6FF),
              ),
              const SizedBox(width: 8),
              Text(
                activeFile.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 12),
              // Selector de Subtipo para Bloques y Unidades
              if (isBlock || isUnit) ...[
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (isBlock ? _blockTypes : _unitTypes).contains(currentType) ? currentType : null,
                      hint: Text(
                        isBlock ? "Tipo de Bloque" : "Tipo de Unidad",
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      dropdownColor: const Color(0xFF21262D),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                      style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 11, fontWeight: FontWeight.bold),
                      items: (isBlock ? _blockTypes : _unitTypes).map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) _onTypeSelected(val);
                      },
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Indicador de Estado de Autoguardado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isDirty ? Colors.amber.withValues(alpha: 0.15) : Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDirty ? Colors.amber.withValues(alpha: 0.4) : Colors.greenAccent.withValues(alpha: 0.3),
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

        // -------------------------------------------------------------
        // CUERPO PRINCIPAL DEL FORMULARIO UNIFICADO
        // -------------------------------------------------------------
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PROPIEDADES COMUNES (Bloques y Unidades)
                if (isBlock || isUnit) ...[
                  _buildSectionBanner(
                    isBlock ? "Propiedades Comunes de Bloque" : "Propiedades Comunes de Unidad",
                    Icons.tune,
                    color: const Color(0xFF58A6FF),
                  ),
                  CommonPropertiesContainer(
                    fileId: _loadedFileId,
                    type: activeFile.type,
                    properties: _properties,
                    onChanged: _onCommonPropertyChange,
                  ),
                ] else ...[
                  // Para ítems, líquidos, etc.
                  ..._properties.entries.map((e) => _buildGenericPropertyRow(e.key, e.value)),
                ],

                // 2. PROPIEDADES ESPECÍFICAS SEGÚN EL TIPO (TypePropertiesDispatcher)
                if (isBlock || isUnit) ...[
                  _buildSectionBanner(
                    "Configuración Específica: $currentType",
                    Icons.settings_input_component,
                    color: const Color(0xFFF778BA),
                  ),
                  TypePropertiesDispatcher(
                    fileType: activeFile.type,
                    properties: _properties,
                    availableItems: _getAllAvailableItems(),
                    availableLiquids: _getAllAvailableLiquids(),
                    onChanged: _onTypePropertiesChange,
                  ),
                ],

                // 3. RENDERIZADO VISUAL (DrawerBuilderWidget para Bloques)
                if (isBlock) ...[
                  _buildSectionBanner(
                    "Renderizado Visual (Drawer)",
                    Icons.layers_outlined,
                    color: const Color(0xFFE3B341),
                  ),
                  DrawerBuilderWidget(
                    key: ValueKey("${activeFile.name}_$currentType"),
                    blockProperties: _properties,
                    availableLiquids: _getAllAvailableLiquids(),
                    onChanged: (newDrawer) {
                      setState(() {
                        if (newDrawer == null) {
                          _properties.remove("drawer");
                        } else {
                          _properties["drawer"] = newDrawer;
                        }
                      });
                      _markDirtyAndSave();
                    },
                  ),
                ],

                // 4. PROPIEDADES ADICIONALES PERSONALIZADAS
                if (isBlock || isUnit) ...[
                  _buildSectionBanner(
                    "Propiedades Adicionales Personalizadas",
                    Icons.add_circle_outline,
                    color: const Color(0xFF7EE787),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Campos y modificadores extra de Mindustry",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddPropertyDialog(context),
                        icon: const Icon(Icons.add, color: Color(0xFF7EE787), size: 15),
                        label: const Text(
                          "Nueva Propiedad",
                          style: TextStyle(color: Color(0xFF7EE787), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (customEntries.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Text(
                        "No hay propiedades adicionales. Pulsa '+ Nueva Propiedad' para añadir claves avanzadas personalizadas.",
                        style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
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
    final isNum = value is num;
    final isBool = value is bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
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
                      activeColor: const Color(0xFF58A6FF),
                      onChanged: (v) {
                        setState(() => _properties[key] = v);
                        _markDirtyAndSave();
                      },
                    ),
                  )
                : TextFormField(
                    key: ValueKey("${_loadedFileId}_$key"),
                    initialValue: value?.toString() ?? '',
                    keyboardType: isNum
                        ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                        : TextInputType.text,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      filled: true,
                      fillColor: Color(0xFF21262D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide.none,
                      ),
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
                      _markDirtyAndSave();
                    },
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
            visualDensity: VisualDensity.compact,
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
        backgroundColor: const Color(0xFF161B22),
        title: const Text("Añadir Propiedad Personalizada", style: TextStyle(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: "ej: reload, rotateSpeed, shootSound",
            hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58A6FF),
              foregroundColor: Colors.white,
            ),
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
