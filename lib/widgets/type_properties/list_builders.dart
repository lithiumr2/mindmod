import 'package:flutter/material.dart';

class ItemsListBuilder extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final List<String> availableItems;
  final Function(List<dynamic>) onUpdate;

  const ItemsListBuilder({super.key, required this.title, required this.items, required this.availableItems, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add'),
                  onPressed: () {
                    final newList = List.from(items)..add({'item': availableItems.isNotEmpty ? availableItems.first : 'copper', 'amount': 1});
                    onUpdate(newList);
                  },
                )
              ],
            ),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final req = entry.value is Map ? (entry.value as Map<String, dynamic>) : {'item': availableItems.isNotEmpty ? availableItems.first : 'copper', 'amount': 1};
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButton<String>(
                        value: availableItems.contains(req['item']) ? req['item'] : null,
                        isExpanded: true,
                        items: availableItems.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) {
                          final newList = List.from(items);
                          newList[index] = {...req, 'item': v};
                          onUpdate(newList);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: req['amount']?.toString() ?? '1',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true, labelText: 'Qty'),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null) {
                            final newList = List.from(items);
                            newList[index] = {...req, 'amount': parsed};
                            onUpdate(newList);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: () {
                        final newList = List.from(items)..removeAt(index);
                        onUpdate(newList);
                      },
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class LiquidsListBuilder extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final List<String> availableLiquids;
  final Function(List<dynamic>) onUpdate;

  const LiquidsListBuilder({super.key, required this.title, required this.items, required this.availableLiquids, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add'),
                  onPressed: () {
                    final newList = List.from(items)..add({'liquid': availableLiquids.isNotEmpty ? availableLiquids.first : 'water', 'amount': 1.0});
                    onUpdate(newList);
                  },
                )
              ],
            ),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final req = entry.value is Map ? (entry.value as Map<String, dynamic>) : {'liquid': availableLiquids.isNotEmpty ? availableLiquids.first : 'water', 'amount': 1.0};
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButton<String>(
                        value: availableLiquids.contains(req['liquid']) ? req['liquid'] : null,
                        isExpanded: true,
                        items: availableLiquids.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) {
                          final newList = List.from(items);
                          newList[index] = {...req, 'liquid': v};
                          onUpdate(newList);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: req['amount']?.toString() ?? '1.0',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true, labelText: 'Vol'),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null) {
                            final newList = List.from(items);
                            newList[index] = {...req, 'amount': parsed};
                            onUpdate(newList);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: () {
                        final newList = List.from(items)..removeAt(index);
                        onUpdate(newList);
                      },
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
