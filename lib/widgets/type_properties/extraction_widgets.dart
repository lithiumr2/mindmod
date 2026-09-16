import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

const List<String> _commonEffects = [
  "none", "mine", "mineBig", "drill", "drillSteam", "smelt",
  "smoke", "smokeCloud", "hitBulletSmall", "hitBulletBig", "fire", "spark"
];

/// Widget para taladros estándar (Drill, BurstDrill, ImpactDrill)
class DrillPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DrillPropertiesWidget({
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
    final tier = int.tryParse(properties['tier']?.toString() ?? '') ?? 2;
    final drillTime = double.tryParse(properties['drillTime']?.toString() ?? '') ?? 400.0;
    final warmupSpeed = double.tryParse(properties['warmupSpeed']?.toString() ?? '');
    final liquidBoostIntensity = double.tryParse(properties['liquidBoostIntensity']?.toString() ?? '');
    final drawMineItem = properties['drawMineItem'] == true;
    final drillEffect = properties['drillEffect']?.toString();
    final updateEffect = properties['updateEffect']?.toString();

    return TypeCardContainer(
      title: "Extracción: Taladro (Drill)",
      subtitle: "Configuración de tier, tiempos de minado y efectos de extracción",
      icon: Icons.hardware,
      accentColor: Colors.orangeAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Tier de Minería (tier)",
                  value: tier,
                  hint: "ej: 2 (Titanio)",
                  onChanged: (v) => _update('tier', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo por Ítem (drillTime)",
                  value: drillTime,
                  hint: "ej: 300.0 ticks",
                  onChanged: (v) => _update('drillTime', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad Calentamiento (warmupSpeed)",
                  value: warmupSpeed,
                  hint: "ej: 0.015",
                  onChanged: (v) => _update('warmupSpeed', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Potenciación Líquido (liquidBoostIntensity)",
                  value: liquidBoostIntensity,
                  hint: "ej: 1.6",
                  onChanged: (v) => _update('liquidBoostIntensity', v),
                ),
              ),
            ],
          ),
          MindustryBoolField(
            label: "Mostrar Ítem Minado (drawMineItem)",
            subtitle: "Dibuja el mineral rotando encima del taladro",
            value: drawMineItem,
            onChanged: (v) => _update('drawMineItem', v),
          ),
          Row(
            children: [
              Expanded(
                child: MindustryDropdownField(
                  label: "Efecto de Minado (drillEffect)",
                  value: drillEffect,
                  items: _commonEffects,
                  onChanged: (v) => _update('drillEffect', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryDropdownField(
                  label: "Efecto Continuo (updateEffect)",
                  value: updateEffect,
                  items: _commonEffects,
                  onChanged: (v) => _update('updateEffect', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para taladros de rayo láser (BeamDrill)
class BeamDrillPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BeamDrillPropertiesWidget({
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
    final range = int.tryParse(properties['range']?.toString() ?? '') ?? 4;
    final tier = int.tryParse(properties['tier']?.toString() ?? '') ?? 3;
    final drillTime = double.tryParse(properties['drillTime']?.toString() ?? '') ?? 180.0;
    final sparkColor = properties['sparkColor']?.toString() ?? "ffd37fff";

    return TypeCardContainer(
      title: "Extracción: Taladro de Rayo (BeamDrill)",
      subtitle: "Configuración de rayo láser direccional para extracción de pared",
      icon: Icons.flare,
      accentColor: Colors.amberAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryIntField(
                  label: "Alcance en Bloques (range)",
                  value: range,
                  hint: "ej: 4",
                  onChanged: (v) => _update('range', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryIntField(
                  label: "Tier de Minería (tier)",
                  value: tier,
                  hint: "ej: 3 (Berilio/Tungsteno)",
                  onChanged: (v) => _update('tier', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo Minado (drillTime)",
                  value: drillTime,
                  hint: "ej: 180.0",
                  onChanged: (v) => _update('drillTime', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryHexColorField(
                  label: "Color de Chispas (sparkColor)",
                  value: sparkColor,
                  onChanged: (v) => _update('sparkColor', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget para bombas de líquidos (Pump, SolidPump, Fracker)
class PumpPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PumpPropertiesWidget({
    super.key,
    required this.properties,
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
    final pumpAmount = double.tryParse(properties['pumpAmount']?.toString() ?? '') ?? 0.2;
    final result = properties['result']?.toString() ?? (availableLiquids.isNotEmpty ? availableLiquids.first : "water");

    return TypeCardContainer(
      title: "Extracción: Bomba de Líquidos (Pump / SolidPump)",
      subtitle: "Extracción de líquidos desde baldosas o yacimientos subterráneos",
      icon: Icons.water,
      accentColor: Colors.lightBlueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Caudal Bombeado (pumpAmount)",
                  value: pumpAmount,
                  hint: "ej: 0.25 líq/tick",
                  onChanged: (v) => _update('pumpAmount', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryDropdownField(
                  label: "Líquido Extraído (result)",
                  value: result,
                  items: availableLiquids,
                  onChanged: (v) => _update('result', v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
