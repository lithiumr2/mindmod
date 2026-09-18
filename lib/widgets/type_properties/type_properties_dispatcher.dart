import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project_file.dart';
import '../../models/module_schema.dart';
import '../../providers/module_registry_provider.dart';
import '../dynamic_type_form_widget.dart';
import 'production_widgets.dart';
import 'extraction_widgets.dart';
import 'logistics_widgets.dart';
import 'power_widgets.dart';
import 'turret_widgets.dart';
import 'defense_widgets.dart';
import 'payload_widgets.dart';
import 'logic_core_widgets.dart';
import 'unit_widgets.dart';

class TypePropertiesDispatcher extends ConsumerWidget {
  final FileType fileType;
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final List<String> availableUnits;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TypePropertiesDispatcher({
    super.key,
    required this.fileType,
    required this.properties,
    required this.availableItems,
    required this.availableLiquids,
    this.availableUnits = const [],
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawType = properties['type']?.toString().replaceAll('"', '').trim() ?? (fileType == FileType.unit ? "flying" : "GenericCrafter");

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

    if (fileType == FileType.unit) {
      return UnitBasePropertiesWidget(
        properties: properties,
        onChanged: onChanged,
      );
    }

    if (fileType == FileType.block) {
      switch (rawType) {
        // --- 1. PRODUCCIÓN, PROCESAMIENTO Y CALOR ---
        case 'GenericCrafter': return GenericCrafterPropertiesWidget(properties: properties, availableItems: availableItems, availableLiquids: availableLiquids, onChanged: onChanged);
        case 'HeatCrafter':
        case 'HeatProducer': return HeatCrafterPropertiesWidget(properties: properties, availableItems: availableItems, availableLiquids: availableLiquids, onChanged: onChanged);
        case 'Separator': return SeparatorPropertiesWidget(properties: properties, availableItems: availableItems, onChanged: onChanged);
        case 'Incinerator': return IncineratorPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 2. EXTRACCIÓN Y MINERÍA ---
        case 'Drill':
        case 'BurstDrill':
        case 'ImpactDrill': return DrillPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'BeamDrill': return BeamDrillPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'Pump':
        case 'SolidPump': return PumpPropertiesWidget(properties: properties, availableLiquids: availableLiquids, onChanged: onChanged);
        case 'Fracker': return FrackerPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 3. LOGÍSTICA DE ÍTEMS Y CONDUCTOS ---
        case 'Conveyor':
        case 'ArmoredConveyor':
        case 'Duct':
        case 'ArmoredDuct': return ConveyorPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'Router':
        case 'DuctRouter':
        case 'Junction':
        case 'Sorter':
        case 'OverflowGate':
        case 'UnderflowGate': return RouterPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'ItemBridge':
        case 'DuctBridge':
        case 'BufferedItemBridge': return ItemBridgePropertiesWidget(properties: properties, onChanged: onChanged);
        case 'MassDriver': return MassDriverPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'Unloader':
        case 'DirectionalUnloader': return UnloaderPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 4. LOGÍSTICA DE LÍQUIDOS ---
        case 'Conduit':
        case 'ArmoredConduit': return ConduitPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'LiquidRouter':
        case 'LiquidJunction':
        case 'LiquidBridge':
        case 'LiquidContainer':
        case 'LiquidTank': return LiquidRouterPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 5. ENERGÍA Y GENERADORES ---
        case 'PowerNode':
        case 'BeamNode': return PowerNodePropertiesWidget(properties: properties, onChanged: onChanged);
        case 'Battery': return BatteryPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'ConsumeGenerator':
        case 'ThermalGenerator':
        case 'SolarGenerator': return ConsumeGeneratorPropertiesWidget(properties: properties, availableItems: availableItems, availableLiquids: availableLiquids, onChanged: onChanged);
        case 'NuclearReactor':
        case 'ImpactReactor': return NuclearReactorPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 6. ARMAMENTO Y TORRETAS ---
        case 'ItemTurret': return ItemTurretPropertiesWidget(properties: properties, availableItems: availableItems, onChanged: onChanged);
        case 'LiquidTurret': return LiquidTurretPropertiesWidget(properties: properties, availableLiquids: availableLiquids, onChanged: onChanged);
        case 'PowerTurret':
        case 'ContinuousTurret':
        case 'PointDefenseTurret':
        case 'TractorBeamTurret': return EnergyTurretPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 7. DEFENSA, REPARACIÓN Y ESCUDOS ---
        case 'Wall':
        case 'ShieldWall':
        case 'Door': return WallPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'ForceProjector': return ForceProjectorPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'OverdriveProjector':
        case 'OverdriveDome': return OverdrivePropertiesWidget(properties: properties, onChanged: onChanged);
        case 'Mender':
        case 'MendProjector': return MenderPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 8. ENSAMBLAJE DE UNIDADES Y CARGAS ---
        case 'UnitFactory': return UnitFactoryPropertiesWidget(properties: properties, availableItems: availableItems, availableUnits: availableUnits, onChanged: onChanged);
        case 'Reconstructor': return ReconstructorPropertiesWidget(properties: properties, availableUnits: availableUnits, onChanged: onChanged);
        case 'UnitAssembler':
        case 'UnitAssemblerModule': return UnitAssemblerPropertiesWidget(properties: properties, availableItems: availableItems, availableUnits: availableUnits, onChanged: onChanged);
        case 'PayloadConveyor':
        case 'PayloadRouter':
        case 'PayloadMassDriver':
        case 'PayloadLoader':
        case 'PayloadUnloader': return PayloadLogisticsPropertiesWidget(properties: properties, onChanged: onChanged);

        // --- 9. LÓGICA Y NÚCLEO ---
        case 'LogicBlock':
        case 'MemoryBlock':
        case 'MessageBlock':
        case 'LogicDisplay':
        case 'SwitchBlock': return LogicBlockPropertiesWidget(properties: properties, onChanged: onChanged);
        case 'CoreBlock':
        case 'StorageBlock': return CorePropertiesWidget(properties: properties, availableUnits: availableUnits, onChanged: onChanged);

        default:
          return const SizedBox.shrink();
      }
    }
    return const SizedBox.shrink();
  }
}
