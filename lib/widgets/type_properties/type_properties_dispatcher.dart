import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_file.dart';
import '../../models/module_schema.dart';
import '../../providers/module_registry_provider.dart';
import '../dynamic_type_form_widget.dart';
import 'extraction_widgets.dart';
import 'production_widgets.dart';
import 'power_widgets.dart';
import 'turret_widgets.dart';
import 'defense_logistics_widgets.dart';
import 'unit_widgets.dart';

/// Despachador inteligente que renderiza el widget de propiedades exclusivo
/// según el 'type' de Mindustry (v8), tipos dinámicos de módulos y el FileType activo.
class TypePropertiesDispatcher extends ConsumerWidget {
  final FileType fileType;
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TypePropertiesDispatcher({
    super.key,
    required this.fileType,
    required this.properties,
    required this.availableItems,
    required this.availableLiquids,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawType = properties['type']?.toString().replaceAll('"', '').trim() ?? (fileType == FileType.unit ? "flying" : "GenericCrafter");

    // 1. Verificación e instanciación de Tipos Dinámicos de Módulos Personalizados (Schema-Driven UI)
    final customTypes = ref.watch(activeCustomTypesProvider);
    final matchingCustom = customTypes.cast<CustomTypeSchema?>().firstWhere(
      (ct) => ct?.typeId == rawType,
      orElse: () => null,
    );

    if (matchingCustom != null) {
      return DynamicTypeFormWidget(
        schema: matchingCustom,
        data: properties,
        onChanged: onChanged,
      );
    }

    // 2. Unidades Nativas
    if (fileType == FileType.unit) {
      return UnitBasePropertiesWidget(
        properties: properties,
        onChanged: onChanged,
      );
    }

    // 3. Bloques Nativos de Mindustry
    if (fileType == FileType.block) {
      switch (rawType) {
        // --- 1. EXTRACCIÓN ---
        case 'Drill':
        case 'BurstDrill':
        case 'ImpactDrill':
          return DrillPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );
        case 'BeamDrill':
          return BeamDrillPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );
        case 'Pump':
        case 'SolidPump':
        case 'Fracker':
          return PumpPropertiesWidget(
            properties: properties,
            availableLiquids: availableLiquids,
            onChanged: onChanged,
          );

        // --- 2. PRODUCCIÓN ---
        case 'GenericCrafter':
        case 'Incinerator':
          return GenericCrafterPropertiesWidget(
            properties: properties,
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: onChanged,
          );
        case 'HeatCrafter':
          return HeatCrafterPropertiesWidget(
            properties: properties,
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: onChanged,
          );
        case 'Separator':
          return SeparatorPropertiesWidget(
            properties: properties,
            availableItems: availableItems,
            onChanged: onChanged,
          );

        // --- 3. ENERGÍA ---
        case 'ConsumeGenerator':
        case 'ThermalGenerator':
        case 'SolarGenerator':
          return ConsumeGeneratorPropertiesWidget(
            properties: properties,
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: onChanged,
          );
        case 'NuclearReactor':
        case 'ImpactReactor':
          return NuclearReactorPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );
        case 'PowerNode':
        case 'SurgeTower':
        case 'BeamNode':
          return PowerNodePropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );

        // --- 4. ARMAMENTO (TORRETAS) ---
        case 'ItemTurret':
          return ItemTurretPropertiesWidget(
            properties: properties,
            availableItems: availableItems,
            onChanged: onChanged,
          );
        case 'LiquidTurret':
          return LiquidTurretPropertiesWidget(
            properties: properties,
            availableLiquids: availableLiquids,
            onChanged: onChanged,
          );
        case 'PowerTurret':
        case 'LaserTurret':
        case 'ContinuousTurret':
        case 'PointDefenseTurret':
          return PowerTurretPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );

        // --- 5. DEFENSA Y LOGÍSTICA ---
        case 'Wall':
        case 'ShieldWall':
        case 'Door':
          return WallPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );
        case 'ForceProjector':
        case 'MendProjector':
        case 'OverdriveProjector':
        case 'OverdriveDome':
          return ForceProjectorPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );
        case 'Conveyor':
        case 'ArmoredConveyor':
        case 'PlastaniumConveyor':
        case 'StackConveyor':
        case 'Duct':
          return ConveyorPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );
        case 'MassDriver':
          return MassDriverPropertiesWidget(
            properties: properties,
            onChanged: onChanged,
          );

        default:
          return const SizedBox.shrink();
      }
    }

    return const SizedBox.shrink();
  }
}
