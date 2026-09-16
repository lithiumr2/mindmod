import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_form_helpers.dart';

const List<String> _crafterEffects = [
  "none", "smeltsmoke", "smoke", "smokeCloud", "steam", "purify",
  "fire", "spark", "bubbles", "magmasmoke"
];

/// Widget para fábricas y procesadores generales (GenericCrafter)
class GenericCrafterPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final Widget? extraTopWidgets;
  final String title;

  const GenericCrafterPropertiesWidget({
    super.key,
    required this.properties,
    required this.availableItems,
    required this.availableLiquids,
    required this.onChanged,
    this.extraTopWidgets,
    this.title = "Producción: Fábrica (GenericCrafter)",
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
    final craftTime = double.tryParse(properties['craftTime']?.toString() ?? '') ?? 60.0;
    final craftEffect = properties['craftEffect']?.toString();
    final updateEffect = properties['updateEffect']?.toString();

    // 1. Single outputItem: "copper/2"
    String singleOutputItem = "";
    int singleOutputItemAmount = 1;
    final rawSingleItem = properties['outputItem']?.toString().trim() ?? "";
    if (rawSingleItem.isNotEmpty) {
      final parts = rawSingleItem.split('/');
      singleOutputItem = parts[0].trim();
      if (parts.length >= 2) {
        singleOutputItemAmount = int.tryParse(parts[1].trim()) ?? 1;
      }
    }

    // 2. Multiple outputItems: ["item1/1", "item2/2"]
    final List<Map<String, dynamic>> outputItemsList = [];
    final rawItemsList = properties['outputItems'];
    if (rawItemsList is List) {
      for (final it in rawItemsList) {
        final str = it.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          outputItemsList.add({'item': parts[0].trim(), 'amount': int.tryParse(parts[1].trim()) ?? 1});
        }
      }
    }

    // 3. Single outputLiquid: "water/0.5"
    String singleOutputLiquid = "";
    double singleOutputLiquidAmount = 0.5;
    final rawSingleLiq = properties['outputLiquid']?.toString().trim() ?? "";
    if (rawSingleLiq.isNotEmpty) {
      final parts = rawSingleLiq.split('/');
      singleOutputLiquid = parts[0].trim();
      if (parts.length >= 2) {
        singleOutputLiquidAmount = double.tryParse(parts[1].trim()) ?? 0.5;
      }
    }

    // 4. Multiple outputLiquids: ["water/0.5", "slag/0.2"]
    final List<Map<String, dynamic>> outputLiquidsList = [];
    final rawLiqList = properties['outputLiquids'];
    if (rawLiqList is List) {
      for (final liq in rawLiqList) {
        final str = liq.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          outputLiquidsList.add({'liquid': parts[0].trim(), 'amount': double.tryParse(parts[1].trim()) ?? 0.5});
        }
      }
    }

    final consumesMap = properties['consumes'] is Map ? Map<String, dynamic>.from(properties['consumes'] as Map) : null;

    return TypeCardContainer(
      title: title,
      subtitle: "Configuración de recetas, tiempos de manufactura, insumos y salidas",
      icon: Icons.precision_manufacturing,
      accentColor: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (extraTopWidgets != null) extraTopWidgets!,
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo de Fabricación (craftTime)",
                  value: craftTime,
                  hint: "ej: 60.0 ticks (1 seg)",
                  onChanged: (v) => _update('craftTime', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryDropdownField(
                  label: "Efecto al Fabricar (craftEffect)",
                  value: craftEffect,
                  items: _crafterEffects,
                  onChanged: (v) => _update('craftEffect', v),
                ),
              ),
            ],
          ),
          MindustryDropdownField(
            label: "Efecto en Funcionamiento (updateEffect)",
            value: updateEffect,
            items: _crafterEffects,
            onChanged: (v) => _update('updateEffect', v),
          ),

          const Divider(color: Colors.white12, height: 20),

          // SUBMÓDULO DE CONSUMO
          ConsumesSubmodule(
            consumes: consumesMap,
            availableItems: availableItems,
            availableLiquids: availableLiquids,
            onChanged: (newConsumes) => _update('consumes', newConsumes),
          ),

          const Divider(color: Colors.white12, height: 20),

          // SECCIÓN DE SALIDAS
          const Text(
            "Salidas de Producción (Outputs)",
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),

          // Output Item Único
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ítem de Salida Único (outputItem):", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              if (singleOutputItem.isEmpty)
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.add, size: 12, color: Colors.amber),
                  label: const Text("Definir Salida", style: TextStyle(color: Colors.amber, fontSize: 11)),
                  onPressed: () {
                    final def = availableItems.isNotEmpty ? availableItems.first : "copper";
                    _update('outputItem', "$def/1");
                  },
                )
              else
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.delete_outline, size: 12, color: Colors.redAccent),
                  label: const Text("Quitar", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  onPressed: () => _update('outputItem', null),
                ),
            ],
          ),
          if (singleOutputItem.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: MindustryDropdownField(
                      label: "Ítem Producido",
                      value: singleOutputItem,
                      items: availableItems,
                      onChanged: (val) {
                        if (val != null) {
                          _update('outputItem', "$val/$singleOutputItemAmount");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: MindustryIntField(
                      label: "Cantidad",
                      value: singleOutputItemAmount,
                      onChanged: (val) {
                        _update('outputItem', "$singleOutputItem/${val ?? 1}");
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Output Items Múltiples (outputItems)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Salida de Múltiples Ítems (outputItems):", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add, size: 12, color: Colors.amberAccent),
                label: const Text("Añadir a Lista", style: TextStyle(color: Colors.amberAccent, fontSize: 11)),
                onPressed: () {
                  final def = availableItems.isNotEmpty ? availableItems.first : "copper";
                  outputItemsList.add({'item': def, 'amount': 1});
                  _update('outputItems', outputItemsList.map((e) => "${e['item']}/${e['amount']}").toList());
                },
              ),
            ],
          ),
          ...outputItemsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final it = entry.value['item'].toString();
            final amt = entry.value['amount'] as int? ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: MindustryDropdownField(
                      label: "Ítem #${idx + 1}",
                      value: it,
                      items: availableItems,
                      onChanged: (val) {
                        if (val != null) {
                          outputItemsList[idx]['item'] = val;
                          _update('outputItems', outputItemsList.map((e) => "${e['item']}/${e['amount']}").toList());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: MindustryIntField(
                      label: "Cantidad",
                      value: amt,
                      onChanged: (val) {
                        outputItemsList[idx]['amount'] = val ?? 1;
                        _update('outputItems', outputItemsList.map((e) => "${e['item']}/${e['amount']}").toList());
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                    onPressed: () {
                      outputItemsList.removeAt(idx);
                      _update('outputItems', outputItemsList.isEmpty ? null : outputItemsList.map((e) => "${e['item']}/${e['amount']}").toList());
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // Output Liquid Único (outputLiquid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Líquido de Salida Único (outputLiquid):", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              if (singleOutputLiquid.isEmpty)
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.water_drop, size: 12, color: Colors.blueAccent),
                  label: const Text("Definir Líquido", style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                  onPressed: () {
                    final def = availableLiquids.isNotEmpty ? availableLiquids.first : "water";
                    _update('outputLiquid', "$def/0.5");
                  },
                )
              else
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.delete_outline, size: 12, color: Colors.redAccent),
                  label: const Text("Quitar", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  onPressed: () => _update('outputLiquid', null),
                ),
            ],
          ),
          if (singleOutputLiquid.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: MindustryDropdownField(
                      label: "Líquido Producido",
                      value: singleOutputLiquid,
                      items: availableLiquids,
                      onChanged: (val) {
                        if (val != null) {
                          _update('outputLiquid', "$val/$singleOutputLiquidAmount");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: MindustryFloatField(
                      label: "Caudal/tick",
                      value: singleOutputLiquidAmount,
                      onChanged: (val) {
                        _update('outputLiquid', "$singleOutputLiquid/${val ?? 0.5}");
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Output Liquids Múltiples (outputLiquids)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Salida de Múltiples Líquidos (outputLiquids):", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add, size: 12, color: Colors.blueAccent),
                label: const Text("Añadir a Lista", style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                onPressed: () {
                  final def = availableLiquids.isNotEmpty ? availableLiquids.first : "water";
                  outputLiquidsList.add({'liquid': def, 'amount': 0.5});
                  _update('outputLiquids', outputLiquidsList.map((e) => "${e['liquid']}/${e['amount']}").toList());
                },
              ),
            ],
          ),
          ...outputLiquidsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final liq = entry.value['liquid'].toString();
            final amt = entry.value['amount'] as double? ?? 0.5;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: MindustryDropdownField(
                      label: "Líquido #${idx + 1}",
                      value: liq,
                      items: availableLiquids,
                      onChanged: (val) {
                        if (val != null) {
                          outputLiquidsList[idx]['liquid'] = val;
                          _update('outputLiquids', outputLiquidsList.map((e) => "${e['liquid']}/${e['amount']}").toList());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: MindustryFloatField(
                      label: "Caudal/tick",
                      value: amt,
                      onChanged: (val) {
                        outputLiquidsList[idx]['amount'] = val ?? 0.5;
                        _update('outputLiquids', outputLiquidsList.map((e) => "${e['liquid']}/${e['amount']}").toList());
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                    onPressed: () {
                      outputLiquidsList.removeAt(idx);
                      _update('outputLiquids', outputLiquidsList.isEmpty ? null : outputLiquidsList.map((e) => "${e['liquid']}/${e['amount']}").toList());
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
}

/// Widget para fábricas basadas en calor (HeatCrafter)
class HeatCrafterPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const HeatCrafterPropertiesWidget({
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
    final heatRequirement = double.tryParse(properties['heatRequirement']?.toString() ?? '') ?? 10.0;
    final maxEfficiency = double.tryParse(properties['maxEfficiency']?.toString() ?? '') ?? 4.0;

    return GenericCrafterPropertiesWidget(
      title: "Producción: Fábrica Térmica (HeatCrafter)",
      properties: properties,
      availableItems: availableItems,
      availableLiquids: availableLiquids,
      onChanged: onChanged,
      extraTopWidgets: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF281816),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.whatshot, size: 16, color: Colors.deepOrangeAccent),
                SizedBox(width: 6),
                Text(
                  "Requisitos de Calor (Heat)",
                  style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: MindustryFloatField(
                    label: "Calor Requerido (heatRequirement)",
                    value: heatRequirement,
                    hint: "ej: 10.0",
                    onChanged: (v) => _update('heatRequirement', v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MindustryFloatField(
                    label: "Eficiencia Máxima (maxEfficiency)",
                    value: maxEfficiency,
                    hint: "ej: 4.0 (400%)",
                    onChanged: (v) => _update('maxEfficiency', v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para centrifugadoras y separadores de minerales (Separator)
class SeparatorPropertiesWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final List<String> availableItems;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SeparatorPropertiesWidget({
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
    final craftTime = double.tryParse(properties['craftTime']?.toString() ?? '') ?? 35.0;

    // Parse results: list of Item + Amount/Weight
    final List<Map<String, dynamic>> resultsList = [];
    final rawResults = properties['results'];
    if (rawResults is List) {
      for (final r in rawResults) {
        final str = r.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          resultsList.add({
            'item': parts[0].trim(),
            'amount': int.tryParse(parts[1].trim()) ?? 1,
          });
        }
      }
    }

    return TypeCardContainer(
      title: "Producción: Separador (Separator)",
      subtitle: "Configura la distribución probabilística de salida de minerales",
      icon: Icons.alt_route,
      accentColor: Colors.tealAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MindustryFloatField(
            label: "Tiempo por Ciclo de Separación (craftTime)",
            value: craftTime,
            hint: "ej: 35.0 ticks",
            onChanged: (v) => _update('craftTime', v),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Resultados de Minerales (results):", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add, size: 12, color: Colors.tealAccent),
                label: const Text("Añadir Mineral", style: TextStyle(color: Colors.tealAccent, fontSize: 11)),
                onPressed: () {
                  final def = availableItems.isNotEmpty ? availableItems.first : "copper";
                  resultsList.add({'item': def, 'amount': 1});
                  _update('results', resultsList.map((e) => "${e['item']}/${e['amount']}").toList());
                },
              ),
            ],
          ),
          if (resultsList.isEmpty)
            const Text("Sin resultados configurados", style: TextStyle(color: Colors.white30, fontSize: 10))
          else
            ...resultsList.asMap().entries.map((entry) {
              final idx = entry.key;
              final it = entry.value['item'].toString();
              final amt = entry.value['amount'] as int? ?? 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: MindustryDropdownField(
                        label: "Mineral #${idx + 1}",
                        value: it,
                        items: availableItems,
                        onChanged: (val) {
                          if (val != null) {
                            resultsList[idx]['item'] = val;
                            _update('results', resultsList.map((e) => "${e['item']}/${e['amount']}").toList());
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: MindustryIntField(
                        label: "Peso / Cantidad",
                        value: amt,
                        onChanged: (val) {
                          resultsList[idx]['amount'] = val ?? 1;
                          _update('results', resultsList.map((e) => "${e['item']}/${e['amount']}").toList());
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      onPressed: () {
                        resultsList.removeAt(idx);
                        _update('results', resultsList.isEmpty ? null : resultsList.map((e) => "${e['item']}/${e['amount']}").toList());
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
}
