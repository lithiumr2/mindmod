import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

const List<String> _generatorEffects = [
  "none", "generate", "smoke", "smokeCloud", "fire", "spark", "steam"
];

/// Widget para generadores que consumen combustible (ConsumeGenerator, ThermalGenerator)
class ConsumeGeneratorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ConsumeGeneratorPropertiesWidget({
    super.key,
    required this.properties,
    required this.availableItems,
    required this.availableLiquids,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final powerProduction = double.tryParse(properties['powerProduction']?.toString() ?? '') ?? 1.2;
    final itemDuration = double.tryParse(properties['itemDuration']?.toString() ?? '') ?? 90.0;
    final generateEffect = properties['generateEffect']?.toString();
    final consumesMap = properties['consumes'] is Map ? Map<String, dynamic>.from(properties['consumes'] as Map) : null;

    return TypeCardContainer(
      title: "Energía: Generador de Combustión (ConsumeGenerator)",
      subtitle: "Configuración de generación de energía y consumo de combustible",
      icon: Icons.bolt,
      accentColor: Colors.yellowAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Producción de Energía / tick (powerProduction)",
                  value: powerProduction,
                  hint: "ej: 1.5",
                  icon: Icons.flash_on,
                  onChanged: (v) => _update('powerProduction', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Duración de Combustible (itemDuration)",
                  value: itemDuration,
                  hint: "ej: 90.0 ticks",
                  onChanged: (v) => _update('itemDuration', v),
                ),
              ),
            ],
          ),
          MindustryDropdownField(
            label: "Efecto de Generación (generateEffect)",
            value: generateEffect,
            items: _generatorEffects,
            onChanged: (v) => _update('generateEffect', v),
          ),
          const SizedBox(height: 8),
          ConsumesSubmodule(
            consumes: consumesMap,
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: (newConsumes) => _update('consumes', newConsumes),
          ),
        ],
      ),
    );
  }
}

/// Widget para reactores nucleares (NuclearReactor, ImpactReactor)
class NuclearReactorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const NuclearReactorPropertiesWidget({
    super.key,
    required this.properties,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final powerProduction = double.tryParse(properties['powerProduction']?.toString() ?? '') ?? 50.0;
    final heating = double.tryParse(properties['heating']?.toString() ?? '') ?? 0.02;
    final smokeThreshold = double.tryParse(properties['smokeThreshold']?.toString() ?? '') ?? 0.3;
    final flashThreshold = double.tryParse(properties['flashThreshold']?.toString() ?? '') ?? 0.46;
    final explosionRadius = int.tryParse(properties['explosionRadius']?.toString() ?? '') ?? 40;
    final explosionDamage = double.tryParse(properties['explosionDamage']?.toString() ?? '') ?? 5000.0;

    return TypeCardContainer(
      title: "Energía: Reactor Nuclear (NuclearReactor)",
      subtitle: "Parámetros críticos de calentamiento, energía y catástrofe explosiva",
      icon: Icons.warning_amber,
      accentColor: Colors.redAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Producción Energía (powerProduction)",
                  value: powerProduction,
                  hint: "ej: 50.0",
                  onChanged: (v) => _update('powerProduction', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Tasa de Calentamiento (heating)",
                  value: heating,
                  hint: "ej: 0.02",
                  onChanged: (v) => _update('heating', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Umbral Humo (smokeThreshold)",
                  value: smokeThreshold,
                  hint: "ej: 0.3 (30%)",
                  onChanged: (v) => _update('smokeThreshold', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Umbral Alerta Roja (flashThreshold)",
                  value: flashThreshold,
                  hint: "ej: 0.46 (46%)",
                  onChanged: (v) => _update('flashThreshold', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Radio Explosión (explosionRadius)",
                  value: explosionRadius,
                  hint: "ej: 40 bloques",
                  onChanged: (v) => _update('explosionRadius', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Daño Explosión (explosionDamage)",
                  value: explosionDamage,
                  hint: "ej: 5000.0",
                  onChanged: (v) => _update('explosionDamage', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para nodos y distribuidores de energía (PowerNode, SurgeTower, BeamNode)
class PowerNodePropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PowerNodePropertiesWidget({
    super.key,
    required this.properties,
    required this.onChanged,
  });

  void _update(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(properties);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final maxNodes = int.tryParse(properties['maxNodes']?.toString() ?? '') ?? 10;
    final laserRange = double.tryParse(properties['laserRange']?.toString() ?? '') ?? 6.0;
    final laserColor1 = properties['laserColor1']?.toString() ?? "ffffffaa";
    final laserColor2 = properties['laserColor2']?.toString() ?? "ffd37fcc";

    return TypeCardContainer(
      title: "Energía: Nodo Eléctrico (PowerNode)",
      subtitle: "Distribución inalámbrica por rayos láser hacia otros edificios",
      icon: Icons.device_hub,
      accentColor: Colors.amberAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Conexiones Máximas (maxNodes)",
                  value: maxNodes,
                  hint: "ej: 10",
                  onChanged: (v) => _update('maxNodes', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Alcance del Láser (laserRange)",
                  value: laserRange,
                  hint: "ej: 6.0 bloques",
                  onChanged: (v) => _update('laserRange', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryHexColorField(
                  label: "Color Núcleo Láser (laserColor1)",
                  value: laserColor1,
                  onChanged: (v) => _update('laserColor1', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryHexColorField(
                  label: "Color Halo Láser (laserColor2)",
                  value: laserColor2,
                  onChanged: (v) => _update('laserColor2', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
