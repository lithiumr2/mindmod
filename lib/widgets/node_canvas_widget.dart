import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class NodeItem {
  String id;
  String title;
  Offset position;
  Color color;

  NodeItem({
    required this.id,
    required this.title,
    required this.position,
    this.color = const Color(0xFF202026),
  });
}

class NodeConnection {
  String fromId;
  String toId;

  NodeConnection({required this.fromId, required this.toId});
}

class NodeCanvasWidget extends ConsumerStatefulWidget {
  const NodeCanvasWidget({super.key});

  @override
  ConsumerState<NodeCanvasWidget> createState() => _NodeCanvasWidgetState();
}

class _NodeCanvasWidgetState extends ConsumerState<NodeCanvasWidget> {
  final List<NodeItem> nodes = [
    NodeItem(id: '1', title: 'Cobre (Input)', position: const Offset(50, 100), color: const Color(0xFFD8734A)),
    NodeItem(id: '2', title: 'Fábrica Silicon', position: const Offset(300, 150), color: const Color(0xFF202026)),
    NodeItem(id: '3', title: 'Silicon (Output)', position: const Offset(580, 100), color: const Color(0xFF8C80BA)),
  ];

  final List<NodeConnection> connections = [
    NodeConnection(fromId: '1', toId: '2'),
    NodeConnection(fromId: '2', toId: '3'),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final tr = ref.read(localeProvider.notifier).tr;
    return Container(
      color: const Color(0xFF141418),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: NodePainter(nodes: nodes, connections: connections),
          ),
          ...nodes.map((node) {
            return Positioned(
              left: node.position.dx,
              top: node.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    node.position += details.delta;
                  });
                },
                child: Container(
                  width: 160,
                  height: 80,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: node.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFBC02D), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(2, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        node.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(tr('drag_to_move'), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class NodePainter extends CustomPainter {
  final List<NodeItem> nodes;
  final List<NodeConnection> connections;

  NodePainter({required this.nodes, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFBC02D)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == conn.fromId);
      final toNode = nodes.firstWhere((n) => n.id == conn.toId);

      final start = fromNode.position + const Offset(160, 40);
      final end = toNode.position + const Offset(0, 40);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + 60, start.dy,
          end.dx - 60, end.dy,
          end.dx, end.dy,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
