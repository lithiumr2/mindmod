class ItemRequirement {
  String item;
  int amount;

  ItemRequirement({required this.item, required this.amount});

  // Convierte entradas como "copper/10" o objetos {item: "copper", amount: 10}
  factory ItemRequirement.fromHjson(dynamic value) {
    if (value is String) {
      final parts = value.split('/');
      if (parts.length == 2) {
        return ItemRequirement(
          item: parts[0].trim(),
          amount: int.tryParse(parts[1].trim()) ?? 0,
        );
      }
    } else if (value is Map) {
      return ItemRequirement(
        item: value['item']?.toString() ?? 'copper',
        amount: int.tryParse(value['amount']?.toString() ?? '0') ?? 0,
      );
    }
    return ItemRequirement(item: 'copper', amount: 0);
  }

  // Serializa de vuelta a la sintaxis nativa de Mindustry
  String toHjsonFormat() => '$item/$amount';
}
