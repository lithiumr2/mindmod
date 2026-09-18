import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/module_schema.dart';

const String _kCustomModulesKey = 'mindmod_custom_modules';

/// Notifier reactivo para la gestión de Módulos y Plugins
class ModuleRegistryNotifier extends StateNotifier<List<CustomModule>> {
  ModuleRegistryNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_kCustomModulesKey);
      if (savedJson != null && savedJson.trim().isNotEmpty) {
        final decoded = jsonDecode(savedJson);
        if (decoded is List) {
          final modules = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => CustomModule.fromJson(e))
              .toList();
          state = modules;
          return;
        }
      }

      // Módulo inicial de ejemplo (MultiLib Extension Demo) para comenzar de inmediato
      state = [
        CustomModule(
          id: 'multilib_extension',
          name: 'MultiLib Custom Blocks',
          author: 'MultiLib Community',
          version: '1.2.0',
          description: 'Soporte dinámico para crafters multilíquido y multi-ítem de la biblioteca Java/JS MultiLib.',
          enabled: true,
          customTypes: [
            CustomTypeSchema(
              typeId: 'multilib-multi-crafter',
              displayName: 'Multi Crafter (MultiLib)',
              category: CustomTypeCategory.block,
              properties: [
                const PropertyDefinition(
                  key: 'craftTime',
                  label: 'Tiempo de Fabricación (ticks)',
                  type: PropertyDataType.numberFloat,
                  defaultValue: 60.0,
                  isRequired: true,
                  tooltip: '60 ticks = 1 segundo de procesamiento',
                ),
                const PropertyDefinition(
                  key: 'hasSecondaryOutput',
                  label: 'Habilitar Salida Secundaria',
                  type: PropertyDataType.boolean,
                  defaultValue: true,
                  tooltip: 'Permite generar un subproducto adicional',
                ),
                const PropertyDefinition(
                  key: 'primaryOutputItem',
                  label: 'Ítem Principal de Salida',
                  type: PropertyDataType.itemPicker,
                  defaultValue: 'silicon',
                  isRequired: true,
                ),
                const PropertyDefinition(
                  key: 'fluidColor',
                  label: 'Color del Fluido Interno',
                  type: PropertyDataType.colorHex,
                  defaultValue: '#ffaa00',
                  tooltip: 'Tonalidad de la cámara de reacción',
                ),
                const PropertyDefinition(
                  key: 'craftMode',
                  label: 'Modo de Procesamiento',
                  type: PropertyDataType.enumDropdown,
                  defaultValue: 'parallel',
                  options: ['sequential', 'parallel', 'catalytic'],
                ),
              ],
            ),
          ],
          globalInjections: const GlobalRegistryInjection(
            customItems: ['purified-sand', 'refined-phase'],
            customLiquids: ['heavy-oil', 'super-cryo'],
            customCategories: ['multilib-crafting'],
          ),
        ),
      ];
      _persist();
    } catch (e) {
      debugPrint('Error cargando módulos personalizados: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.map((m) => m.toJson()).toList());
      await prefs.setString(_kCustomModulesKey, encoded);
    } catch (e) {
      debugPrint('Error persistiendo módulos personalizados: $e');
    }
  }

  /// Registra un nuevo módulo. Si ya existe un módulo con ese ID, genera un ID único o actualiza.
  Future<void> registerModule(CustomModule module) async {
    final exists = state.any((m) => m.id == module.id);
    if (exists) {
      await updateModule(module);
      return;
    }
    state = [...state, module];
    await _persist();
  }

  /// Actualiza un módulo existente por ID
  Future<void> updateModule(CustomModule module) async {
    state = [
      for (final m in state)
        if (m.id == module.id) module else m
    ];
    await _persist();
  }

  /// Elimina un módulo por ID
  Future<void> deleteModule(String moduleId) async {
    state = state.where((m) => m.id != moduleId).toList();
    await _persist();
  }

  /// Alterna el estado habilitado/deshabilitado de un módulo
  Future<void> toggleModule(String moduleId) async {
    state = [
      for (final m in state)
        if (m.id == moduleId) m.copyWith(enabled: !m.enabled) else m
    ];
    await _persist();
  }

  /// Importa un módulo (reemplaza si existe o añade nuevo)
  Future<void> importModule(CustomModule module) async {
    final index = state.indexWhere((m) => m.id == module.id);
    if (index >= 0) {
      final updated = List<CustomModule>.from(state);
      updated[index] = module;
      state = updated;
    } else {
      state = [...state, module];
    }
    await _persist();
  }
}

/// Provider del Notifier de registro de módulos
final moduleRegistryProvider = StateNotifierProvider<ModuleRegistryNotifier, List<CustomModule>>((ref) {
  return ModuleRegistryNotifier();
});

/// Módulos actualmente activos (enabled == true)
final activeModulesProvider = Provider<List<CustomModule>>((ref) {
  final all = ref.watch(moduleRegistryProvider);
  return all.where((m) => m.enabled).toList();
});

/// Todos los CustomTypeSchema provistos por los módulos activos
final activeCustomTypesProvider = Provider<List<CustomTypeSchema>>((ref) {
  final activeMods = ref.watch(activeModulesProvider);
  final List<CustomTypeSchema> types = [];
  for (final mod in activeMods) {
    types.addAll(mod.customTypes);
  }
  return types;
});

/// Lista combinada de Ítems disponibles (Base Mindustry v7/v8 + Inyecciones dinámicas de módulos activos)
final allAvailableItemsProvider = Provider<List<String>>((ref) {
  final Set<String> items = {
    'copper', 'lead', 'metaglass', 'graphite', 'sand', 'coal', 'titanium',
    'thorium', 'scrap', 'silicon', 'plastanium', 'phase-fabric', 'surge-alloy',
    'spore-pod', 'blast-compound', 'pyratite', 'beryllium', 'tungsten',
    'oxide', 'carbide', 'fissile-matter', 'dormant-cyst'
  };

  final activeMods = ref.watch(activeModulesProvider);
  for (final mod in activeMods) {
    items.addAll(mod.globalInjections.customItems);
  }

  return items.toList();
});

/// Lista combinada de Líquidos disponibles (Base Mindustry v7/v8 + Inyecciones dinámicas)
final allAvailableLiquidsProvider = Provider<List<String>>((ref) {
  final Set<String> liquids = {
    'water', 'slag', 'oil', 'cryofluid', 'gallium', 'neoplasm', 'arkycite', 'ozone', 'hydrogen', 'nitrogen'
  };

  final activeMods = ref.watch(activeModulesProvider);
  for (final mod in activeMods) {
    liquids.addAll(mod.globalInjections.customLiquids);
  }

  return liquids.toList();
});

/// Lista combinada de Categorías de bloques (Base Mindustry + Inyecciones dinámicas)
final allAvailableCategoriesProvider = Provider<List<String>>((ref) {
  final Set<String> categories = {
    'distribution', 'liquid', 'power', 'production', 'defense',
    'turret', 'units', 'effect', 'logic', 'crafting'
  };

  final activeMods = ref.watch(activeModulesProvider);
  for (final mod in activeMods) {
    categories.addAll(mod.globalInjections.customCategories);
  }

  return categories.toList();
});

/// Lista combinada de Tipos de Bloques disponibles (Base Mindustry + CustomTypes activos de categoría block)
final allAvailableBlockTypesProvider = Provider<List<String>>((ref) {
  final List<String> baseBlockTypes = [
    // Defensa
    "Wall", "ShieldWall", "Door", "AutoDoor", "MendProjector", "OverdriveProjector", "OverdriveDome",
    "ForceProjector", "DirectionalForceProjector", "RegenProjector", "ShockMine", "Radar",
    
    // Torretas
    "ItemTurret", "LiquidTurret", "PowerTurret", "LaserTurret", "ContinuousTurret", 
    "ContinuousLiquidTurret", "PointDefenseTurret", "TractorBeamTurret", "PayloadAmmoTurret",
    
    // Extracción y Minería
    "Drill", "BurstDrill", "ImpactDrill", "BeamDrill", "Pump", "SolidPump", "Fracker",
    
    // Fábricas y Producción
    "GenericCrafter", "HeatCrafter", "Incinerator", "Separator", "Cultivator", "HeatProducer",
    
    // Distribución y Logística de Ítems
    "Conveyor", "ArmoredConveyor", "PlastaniumConveyor", "StackConveyor", "Duct", "ArmoredDuct",
    "DuctRouter", "DuctBridge", "OverflowDuct", "Router", "Distributor", "Junction", "ItemBridge",
    "Sorter", "InvertedSorter", "OverflowGate", "UnderflowGate", "MassDriver", "Unloader", "DirectionalUnloader",
    
    // Logística de Payload (Carga)
    "PayloadConveyor", "PayloadRouter", "PayloadMassDriver", "UnitCargoLoader", "UnitCargoUnloadPoint",
    
    // Distribución de Líquidos
    "Conduit", "ArmoredConduit", "LiquidRouter", "LiquidJunction", "LiquidBridge", "LiquidTank", "LiquidContainer",
    
    // Energía
    "PowerNode", "SurgeTower", "BeamNode", "PowerDiode", "Battery", "BatteryLarge",
    "SolarGenerator", "ThermalGenerator", "ConsumeGenerator", "NuclearReactor", "ImpactReactor", "VariableReactor",
    
    // Fábricas y Ensamblaje de Unidades
    "UnitFactory", "Reconstructor", "UnitAssembler", "UnitAssemblerModule", "RepairTower", "RepairPoint",
    
    // Almacenamiento y Núcleo
    "StorageBlock", "CoreBlock",
    
    // Lógica y Pantallas
    "MessageBlock", "LogicBlock", "MemoryBlock", "CanvasBlock", "LightBlock",
    
    // Sandbox / Pruebas
    "ItemSource", "LiquidSource", "PowerSource", "ItemVoid", "LiquidVoid", "PowerVoid",
  ];

  final customTypes = ref.watch(activeCustomTypesProvider);
  final List<String> result = List<String>.from(baseBlockTypes);
  for (final ct in customTypes) {
    if (ct.category == CustomTypeCategory.block && !result.contains(ct.typeId)) {
      result.add(ct.typeId);
    }
  }

  return result;
});

/// Lista combinada de Tipos de Unidades disponibles (Base Mindustry + CustomTypes activos de categoría unit)
final allAvailableUnitTypesProvider = Provider<List<String>>((ref) {
  final List<String> baseUnitTypes = [
    "flying", "mech", "legs", "naval", "payload", "tether", "crawl", "missile", "hover", "tank", "unit"
  ];

  final customTypes = ref.watch(activeCustomTypesProvider);
  final List<String> result = List<String>.from(baseUnitTypes);
  for (final ct in customTypes) {
    if (ct.category == CustomTypeCategory.unit && !result.contains(ct.typeId)) {
      result.add(ct.typeId);
    }
  }

  return result;
});
