import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Contenedor unificado para las tarjetas de propiedades específicas
class TypeCardContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;
  final List<Widget>? actions;

  const TypeCardContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.tune,
    this.accentColor = Colors.amber,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222228),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.2),
      ),
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (actions != null) Row(mainAxisSize: MainAxisSize.min, children: actions!),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Campo numérico flotante estricto con validación segura contra nulos
class MindustryFloatField extends StatefulWidget {
  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;
  final String? hint;
  final IconData? icon;

  const MindustryFloatField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.icon,
  });

  @override
  State<MindustryFloatField> createState() => _MindustryFloatFieldState();
}

class _MindustryFloatFieldState extends State<MindustryFloatField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value != null ? widget.value.toString() : "");
  }

  @override
  void didUpdateWidget(covariant MindustryFloatField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final strVal = widget.value != null ? widget.value.toString() : "";
      if (double.tryParse(_controller.text) != widget.value) {
        _controller.text = strVal;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 12, color: Colors.white70),
                const SizedBox(width: 5),
              ],
              Text(widget.label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: TextFormField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*')),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: widget.hint ?? "0.0",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
              onChanged: (val) {
                final trimmed = val.trim();
                if (trimmed.isEmpty) {
                  widget.onChanged(null);
                } else {
                  final parsed = double.tryParse(trimmed);
                  widget.onChanged(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
},
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo numérico entero estricto con validación segura
class MindustryIntField extends StatefulWidget {
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? hint;
  final IconData? icon;

  const MindustryIntField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.icon,
  });

  @override
  State<MindustryIntField> createState() => _MindustryIntFieldState();
}

class _MindustryIntFieldState extends State<MindustryIntField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value != null ? widget.value.toString() : "");
  }

  @override
  void didUpdateWidget(covariant MindustryIntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final strVal = widget.value != null ? widget.value.toString() : "";
      if (int.tryParse(_controller.text) != widget.value) {
        _controller.text = strVal;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 12, color: Colors.white70),
                const SizedBox(width: 5),
              ],
              Text(widget.label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: TextFormField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: widget.hint ?? "0",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
              onChanged: (val) {
                final trimmed = val.trim();
                if (trimmed.isEmpty) {
                  widget.onChanged(null);
                } else {
                  final parsed = int.tryParse(trimmed);
                  widget.onChanged(parsed);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
},
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de texto plano
class MindustryStringField extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? hint;

  const MindustryStringField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  @override
  State<MindustryStringField> createState() => _MindustryStringFieldState();
}

class _MindustryStringFieldState extends State<MindustryStringField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? "");
  }

  @override
  void didUpdateWidget(covariant MindustryStringField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? "";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: TextFormField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: widget.hint ?? widget.label,
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Control booleano estricto con SwitchListTile
class MindustryBoolField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  const MindustryBoolField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF18181D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: SwitchListTile(
        dense: true,
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 10)) : null,
        value: value,
        activeThumbColor: Colors.amber,
        activeTrackColor: Colors.amber.withValues(alpha: 0.4),
        inactiveThumbColor: Colors.white38,
        inactiveTrackColor: Colors.white12,
        onChanged: onChanged,
      ),
    );
  }
}

/// Selector de color hexadecimal (8 caracteres RRGGBBAA o 6 RRGGBB)
class MindustryHexColorField extends StatefulWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const MindustryHexColorField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<MindustryHexColorField> createState() => _MindustryHexColorFieldState();
}

class _MindustryHexColorFieldState extends State<MindustryHexColorField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? "");
  }

  @override
  void didUpdateWidget(covariant MindustryHexColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? "";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.transparent;
    var clean = hex.replaceAll("#", "").trim();
    if (clean.length == 6) {
      clean = "FF" + clean;
    } else if (clean.length == 8) {
      final rr = clean.substring(0, 2);
      final gg = clean.substring(2, 4);
      final bb = clean.substring(4, 6);
      final aa = clean.substring(6, 8);
      clean = aa + rr + gg + bb;
    } else {
      return Colors.amber;
    }
    final intVal = int.tryParse(clean, radix: 16);
    return intVal != null ? Color(intVal) : Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _parseColor(widget.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: TextFormField(
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F#]')),
                LengthLimitingTextInputFormatter(9),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: "RRGGBBAA (ej: ffd37fff)",
                hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
              ),
              onChanged: (val) {
                widget.onChanged(val.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector Dropdown estándar para ítems, líquidos, efectos o tipos
class MindustryDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hint;

  const MindustryDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cleanValue = value?.replaceAll('@', '').trim();
    final isValid = cleanValue != null && items.contains(cleanValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141418),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: isValid ? cleanValue : null,
                hint: Text(
                  cleanValue?.isNotEmpty == true ? cleanValue! : (hint ?? "Seleccionar..."),
                  style: TextStyle(color: isValid ? Colors.white : Colors.white54, fontSize: 12),
                ),
                dropdownColor: const Color(0xFF222228),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sub-formulario interactivo para BulletType (Proyectiles de Torretas y Armas)
class BulletTypeSubform extends StatelessWidget {
  final String title;
  final Map<String, dynamic> bullet;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BulletTypeSubform({
    super.key,
    this.title = "Configuración de Proyectil (BulletType)",
    required this.bullet,
    required this.onChanged,
  });

  void _updateProp(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(bullet);
    if (value == null) {
      copy.remove(key);
    } else {
      copy[key] = value;
    }
    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    final damage = double.tryParse(bullet['damage']?.toString() ?? '') ?? 12.0;
    final speed = double.tryParse(bullet['speed']?.toString() ?? '') ?? 3.5;
    final lifetime = double.tryParse(bullet['lifetime']?.toString() ?? '') ?? 60.0;
    final splashDamage = double.tryParse(bullet['splashDamage']?.toString() ?? '') ?? 0.0;
    final splashDamageRadius = double.tryParse(bullet['splashDamageRadius']?.toString() ?? '') ?? 0.0;
    final pierce = bullet['pierce'] == true;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF18181D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, size: 14, color: Colors.deepOrangeAccent),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Daño (damage)",
                  value: damage,
                  onChanged: (v) => _updateProp('damage', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Velocidad (speed)",
                  value: speed,
                  onChanged: (v) => _updateProp('speed', v),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MindustryFloatField(
                  label: "Tiempo Vida (lifetime)",
                  value: lifetime,
                  onChanged: (v) => _updateProp('lifetime', v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MindustryFloatField(
                  label: "Daño de Área (splash)",
                  value: splashDamage,
                  onChanged: (v) => _updateProp('splashDamage', v),
                ),
              ),
            ],
          ),
          if (splashDamage > 0)
            MindustryFloatField(
              label: "Radio de Explosión (splashDamageRadius)",
              value: splashDamageRadius,
              onChanged: (v) => _updateProp('splashDamageRadius', v),
            ),
          MindustryBoolField(
            label: "Perforante (pierce)",
            value: pierce,
            onChanged: (v) => _updateProp('pierce', v),
          ),
        ],
      ),
    );
  }
}

/// Submódulo dinámico de Consumes (Power, Ítems de entrada, Líquidos de entrada)
class ConsumesSubmodule extends StatelessWidget {
  final Map<String, dynamic>? consumes;
  final List<String> availableItems;
  final List<String> availableLiquids;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  const ConsumesSubmodule({
    super.key,
    required this.consumes,
    required this.availableItems,
    required this.availableLiquids,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final consumesMap = consumes != null ? Map<String, dynamic>.from(consumes!) : <String, dynamic>{};
    final power = double.tryParse(consumesMap['power']?.toString() ?? '');

    // Parse items
    final List<Map<String, dynamic>> itemsList = [];
    final rawItems = consumesMap['items'];
    if (rawItems is List) {
      for (final it in rawItems) {
        final str = it.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          itemsList.add({'item': parts[0].trim(), 'amount': int.tryParse(parts[1].trim()) ?? 1});
        }
      }
    }

    // Parse liquids
    final List<Map<String, dynamic>> liquidsList = [];
    final rawLiquids = consumesMap['liquid'] ?? consumesMap['liquids'];
    if (rawLiquids is String && rawLiquids.isNotEmpty) {
      final parts = rawLiquids.split('/');
      if (parts.length >= 2) {
        liquidsList.add({'liquid': parts[0].trim(), 'amount': double.tryParse(parts[1].trim()) ?? 0.2});
      }
    } else if (rawLiquids is List) {
      for (final liq in rawLiquids) {
        final str = liq.toString().trim();
        final parts = str.split('/');
        if (parts.length >= 2) {
          liquidsList.add({'liquid': parts[0].trim(), 'amount': double.tryParse(parts[1].trim()) ?? 0.2});
        }
      }
    }

    void saveConsumes(double? newPower, List<Map<String, dynamic>> newItems, List<Map<String, dynamic>> newLiquids) {
      final out = <String, dynamic>{};
      if (newPower != null && newPower > 0) {
        out['power'] = newPower;
      }
      if (newItems.isNotEmpty) {
        out['items'] = newItems.map((e) => "${e['item']}/${e['amount']}").toList();
      }
      if (newLiquids.isNotEmpty) {
        if (newLiquids.length == 1) {
          out['liquid'] = "${newLiquids[0]['liquid']}/${newLiquids[0]['amount']}";
        } else {
          out['liquids'] = newLiquids.map((e) => "${e['liquid']}/${e['amount']}").toList();
        }
      }
      onChanged(out.isEmpty ? null : out);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18181D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.input, size: 14, color: Colors.amber),
              SizedBox(width: 6),
              Text(
                "Submódulo de Consumos (consumes)",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MindustryFloatField(
            label: "Consumo de Energía / tick (power)",
            value: power,
            hint: "0.0 (Sin energía)",
            icon: Icons.bolt,
            onChanged: (p) => saveConsumes(p, itemsList, liquidsList),
          ),
          const SizedBox(height: 6),

          // Lista de Ítems de entrada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ítems Requeridos:", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add, size: 13, color: Colors.amber),
                label: const Text("Añadir Ítem", style: TextStyle(color: Colors.amber, fontSize: 11)),
                onPressed: () {
                  final defaultItem = availableItems.isNotEmpty ? availableItems.first : "copper";
                  itemsList.add({'item': defaultItem, 'amount': 1});
                  saveConsumes(power, itemsList, liquidsList);
                },
              ),
            ],
          ),
          if (itemsList.isEmpty)
            const Text("Sin ítems de entrada", style: TextStyle(color: Colors.white30, fontSize: 10))
          else
            ...itemsList.asMap().entries.map((entry) {
              final idx = entry.key;
              final it = entry.value['item']?.toString() ?? 'copper';
              final amt = entry.value['amount']?.toString() ?? '1';

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141418),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: availableItems.contains(it) ? it : null,
                            hint: Text(it, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            dropdownColor: const Color(0xFF222228),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: availableItems.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                itemsList[idx]['item'] = newVal;
                                saveConsumes(power, itemsList, liquidsList);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141418),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextFormField(
                          initialValue: amt,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "Cant."),
                          onChanged: (val) {
                            itemsList[idx]['amount'] = int.tryParse(val) ?? 1;
                            saveConsumes(power, itemsList, liquidsList);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      onPressed: () {
                        itemsList.removeAt(idx);
                        saveConsumes(power, itemsList, liquidsList);
                      },
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 6),
          // Lista de Líquidos de entrada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Líquidos Requeridos:", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.water_drop, size: 13, color: Colors.blueAccent),
                label: const Text("Añadir Líquido", style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
                onPressed: () {
                  final defaultLiq = availableLiquids.isNotEmpty ? availableLiquids.first : "water";
                  liquidsList.add({'liquid': defaultLiq, 'amount': 0.2});
                  saveConsumes(power, itemsList, liquidsList);
                },
              ),
            ],
          ),
          if (liquidsList.isEmpty)
            const Text("Sin líquidos de entrada", style: TextStyle(color: Colors.white30, fontSize: 10))
          else
            ...liquidsList.asMap().entries.map((entry) {
              final idx = entry.key;
              final liq = entry.value['liquid']?.toString() ?? 'water';
              final amt = entry.value['amount']?.toString() ?? '0.2';

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141418),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: availableLiquids.contains(liq) ? liq : null,
                            hint: Text(liq, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            dropdownColor: const Color(0xFF222228),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: availableLiquids.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                liquidsList[idx]['liquid'] = newVal;
                                saveConsumes(power, itemsList, liquidsList);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141418),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextFormField(
                          initialValue: amt,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "Líq/seg"),
                          onChanged: (val) {
                            liquidsList[idx]['amount'] = double.tryParse(val) ?? 0.2;
                            saveConsumes(power, itemsList, liquidsList);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                      onPressed: () {
                        liquidsList.removeAt(idx);
                        saveConsumes(power, itemsList, liquidsList);
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
