import 'package:flutter/material.dart';
import 'common_form_helpers.dart';

/// Widget para torretas de munición física de ítems (ItemTurret)
class ItemTurretPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ItemTurretPropertiesWidget({
    super.key,
    required this.properties,
    required this.availableItems,
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
    final range = double.tryParse(properties['range']?.toString() ?? '') ?? 160.0;
    final reload = double.tryParse(properties['reload']?.toString() ?? '') ?? 20.0;
    final inaccuracy = double.tryParse(properties['inaccuracy']?.toString() ?? '') ?? 0.0;
    final recoil = double.tryParse(properties['recoil']?.toString() ?? '') ?? 1.0;
    final targetAir = properties['targetAir'] == true;
    final targetGround = properties['targetGround'] != false; // default true in Mindustry

    // Parse ammoTypes: Map<String, dynamic> where key is Item, value is BulletType Map
    final Map<String, dynamic> ammoTypes = properties['ammoTypes'] is Map
        ? Map<String, dynamic>.from(properties['ammoTypes'] as Map)
        : <String, dynamic>{};

    void updateAmmoTypes(String itemKey, Map<String, dynamic>? bulletData) {
      final copy = Map<String, dynamic>.from(ammoTypes);
      if (bulletData == null) {
        copy.remove(itemKey);
      } else {
        copy[itemKey] = bulletData;
      }
      _update('ammoTypes', copy.isEmpty ? null : copy);
    }

    return TypeCardContainer(
      title: "Torreta de Ítems (ItemTurret)",
      subtitle: "Calibración balística, objetivos y mapa interactivo de municiones (ammoTypes)",
      icon: Icons.track_changes,
      accentColor: Colors.deepOrangeAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Alcance (range)",
                  value: range,
                  hint: "ej: 180.0 px",
                  onChanged: (v) => _update('range', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Cadencia / Recarga (reload)",
                  value: reload,
                  hint: "ej: 25.0 ticks",
                  onChanged: (v) => _update('reload', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Imprecisión (inaccuracy)",
                  value: inaccuracy,
                  hint: "ej: 3.0 grados",
                  onChanged: (v) => _update('inaccuracy', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Retroceso Visual (recoil)",
                  value: recoil,
                  hint: "ej: 1.5",
                  onChanged: (v) => _update('recoil', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryBoolField(
                  label: "Objetivos Aéreos (targetAir)",
                  value: targetAir,
                  onChanged: (v) => _update('targetAir', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryBoolField(
                  label: "Objetivos Terrestres (targetGround)",
                  value: targetGround,
                  onChanged: (v) => _update('targetGround', v),
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white12, height: 20),

          // AMMO TYPES DINÁMICO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tipos de Munición (ammoTypes):",
                style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.deepOrangeAccent),
                label: const Text("Añadir Munición", style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 11)),
                onPressed: () {
                  // Find next item not yet in ammoTypes
                  final nextItem = availableItems.firstWhere(
                    (it) => !ammoTypes.containsKey(it),
                    orElse: () => availableItems.isNotEmpty ? availableItems.first : "copper",
                  );
                  updateAmmoTypes(nextItem, {
                    'damage': 18.0,
                    'speed': 4.0,
                    'lifetime': 50.0,
                    'splashDamage': 0.0,
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (ammoTypes.isEmpty)
            const Text(
              "Sin municiones configuradas. Haz clic en 'Añadir Munición' para mapear un mineral.",
              style: TextStyle(color: Colors.white30, fontSize: 11),
            )
          else
            ...ammoTypes.entries.map((entry) {
              final itemKey = entry.key;
              final bulletData = entry.value is Map
                  ? Map<String, dynamic>.from(entry.value as Map)
                  : <String, dynamic>{'damage': 15.0, 'speed': 3.5, 'lifetime': 60.0};

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: MindustryDropdownField(
                            label: "Ítem de Carga",
                            value: itemKey,
                            items: availableItems,
                            onChanged: (newKey) {
                              if (newKey != null && newKey != itemKey) {
                                final copy = Map<String, dynamic>.from(ammoTypes);
                                copy.remove(itemKey);
                                copy[newKey] = bulletData;
                                _update('ammoTypes', copy);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 18),
                          onPressed: () => updateAmmoTypes(itemKey, null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    BulletTypeSubform(
                      title: "Balística de $itemKey",
                      bullet: bulletData,
                      onChanged: (newBullet) => updateAmmoTypes(itemKey, newBullet),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// Widget para torretas de chorro de líquido (LiquidTurret)
class LiquidTurretPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const LiquidTurretPropertiesWidget({
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
    final range = double.tryParse(properties['range']?.toString() ?? '') ?? 140.0;
    final reload = double.tryParse(properties['reload']?.toString() ?? '') ?? 8.0;
    final inaccuracy = double.tryParse(properties['inaccuracy']?.toString() ?? '') ?? 4.0;
    final recoil = double.tryParse(properties['recoil']?.toString() ?? '') ?? 0.5;
    final targetAir = properties['targetAir'] == true;
    final targetGround = properties['targetGround'] != false;
    final extinguish = properties['extinguish'] != false; // Apagar incendios

    // Parse ammoTypes: Map<String, dynamic> where key is Liquid, value is BulletType Map
    final Map<String, dynamic> ammoTypes = properties['ammoTypes'] is Map
        ? Map<String, dynamic>.from(properties['ammoTypes'] as Map)
        : <String, dynamic>{};

    void updateLiquidAmmo(String liquidKey, Map<String, dynamic>? bulletData) {
      final copy = Map<String, dynamic>.from(ammoTypes);
      if (bulletData == null) {
        copy.remove(liquidKey);
      } else {
        copy[liquidKey] = bulletData;
      }
      _update('ammoTypes', copy.isEmpty ? null : copy);
    }

    return TypeCardContainer(
      title: "Torreta de Líquidos (LiquidTurret)",
      subtitle: "Lanzador de fluidos para enfriamiento, combate o extinción de incendios",
      icon: Icons.shower,
      accentColor: Colors.lightBlueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Alcance (range)",
                  value: range,
                  hint: "ej: 140.0 px",
                  onChanged: (v) => _update('range', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Cadencia (reload)",
                  value: reload,
                  hint: "ej: 8.0 ticks",
                  onChanged: (v) => _update('reload', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Dispersión (inaccuracy)",
                  value: inaccuracy,
                  hint: "ej: 4.0",
                  onChanged: (v) => _update('inaccuracy', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Retroceso (recoil)",
                  value: recoil,
                  hint: "ej: 0.5",
                  onChanged: (v) => _update('recoil', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryBoolField(
                  label: "Objetivos Aéreos",
                  value: targetAir,
                  onChanged: (v) => _update('targetAir', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryBoolField(
                  label: "Objetivos Terrestres",
                  value: targetGround,
                  onChanged: (v) => _update('targetGround', v),
                ),
              ),
            ],
          ),
          MindustryBoolField(
            label: "Extinguir Incendios (extinguish)",
            subtitle: "La torreta dispara agua automáticamente a incendios cercanos",
            value: extinguish,
            onChanged: (v) => _update('extinguish', v),
          ),

          const Divider(color: Colors.white12, height: 20),

          // LÍQUIDOS EN AMMOTYPES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Fluidos Munición (ammoTypes):",
                style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add, size: 14, color: Colors.lightBlueAccent),
                label: const Text("Añadir Líquido", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11)),
                onPressed: () {
                  final nextLiq = availableLiquids.firstWhere(
                    (l) => !ammoTypes.containsKey(l),
                    orElse: () => availableLiquids.isNotEmpty ? availableLiquids.first : "water",
                  );
                  updateLiquidAmmo(nextLiq, {
                    'damage': 2.0,
                    'speed': 4.5,
                    'lifetime': 45.0,
                  });
                },
              ),
            ],
          ),
          ...ammoTypes.entries.map((entry) {
            final liqKey = entry.key;
            final bulletData = entry.value is Map
                ? Map<String, dynamic>.from(entry.value as Map)
                : <String, dynamic>{'damage': 2.0, 'speed': 4.0, 'lifetime': 40.0};

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF14171E),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MindustryDropdownField(
                          label: "Líquido Disparado",
                          value: liqKey,
                          items: availableLiquids,
                          onChanged: (newKey) {
                            if (newKey != null && newKey != liqKey) {
                              final copy = Map<String, dynamic>.from(ammoTypes);
                              copy.remove(liqKey);
                              copy[newKey] = bulletData;
                              _update('ammoTypes', copy);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                        onPressed: () => updateLiquidAmmo(liqKey, null),
                      ),
                    ],
                  ),
                  BulletTypeSubform(
                    title: "Comportamiento Chorro ($liqKey)",
                    bullet: bulletData,
                    onChanged: (newBullet) => updateLiquidAmmo(liqKey, newBullet),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Widget para torretas de energía eléctrica (PowerTurret, LaserTurret, etc.)
class PowerTurretPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PowerTurretPropertiesWidget({
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
    final range = double.tryParse(properties['range']?.toString() ?? '') ?? 190.0;
    final reload = double.tryParse(properties['reload']?.toString() ?? '') ?? 40.0;
    final chargeTime = double.tryParse(properties['chargeTime']?.toString() ?? '') ?? 20.0;
    final targetAir = properties['targetAir'] == true;
    final targetGround = properties['targetGround'] != false;

    // shootType: Direct BulletType subform
    final shootType = properties['shootType'] is Map
        ? Map<String, dynamic>.from(properties['shootType'] as Map)
        : <String, dynamic>{
            'damage': 45.0,
            'speed': 6.0,
            'lifetime': 40.0,
            'splashDamage': 10.0,
          };

    return TypeCardContainer(
      title: "Torreta de Energía (PowerTurret)",
      subtitle: "Proyectiles de energía, rayos y láseres alimentados por red eléctrica",
      icon: Icons.electric_bolt,
      accentColor: Colors.cyanAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Alcance (range)",
                  value: range,
                  hint: "ej: 190.0 px",
                  onChanged: (v) => _update('range', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo de Recarga (reload)",
                  value: reload,
                  hint: "ej: 40.0 ticks",
                  onChanged: (v) => _update('reload', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo de Carga Previo (chargeTime)",
                  value: chargeTime,
                  hint: "ej: 20.0 ticks",
                  onChanged: (v) => _update('chargeTime', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryBoolField(
                  label: "Objetivos Aéreos",
                  value: targetAir,
                  onChanged: (v) => _update('targetAir', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryBoolField(
                  label: "Objetivos Terrestres",
                  value: targetGround,
                  onChanged: (v) => _update('targetGround', v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BulletTypeSubform(
            title: "Proyectil Eléctrico Directo (shootType)",
            bullet: shootType,
            onChanged: (newBullet) => _update('shootType', newBullet),
          ),
        ],
      ),
    );
  }
}
