import 'package:flutter/material.dart';

/// Dock widget with draggable items.

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// List of items to display in the dock.
  final List<T> items;

  /// Builder function to customize each item.
  final Widget Function(T, bool isHovered) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}


/// State of the Dock widget.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// Current list of dock items.
  late List<T> _items = List<T>.from(widget.items, growable: true);

  /// Currently hovered item.
  T? _hoveredItem;

  /// Dragged item.
  T? _draggedItem;


  /// Dragged item's horizontal position.
  double? _draggedItemX;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isHovered = item == _hoveredItem;

          // Determine the item's position offset based on drag position.
          double offset = 0;
          if (_draggedItemX != null) {
            final targetX = index * 60.0; // Base position of the item
            if (_draggedItemX! > targetX) {
              offset = 20.0; // Move item to the right
            } else if (_draggedItemX! < targetX) {
              offset = -20.0; // Move item to the left
            }
          }
          return AnimatedPositioned(

            duration: const Duration(milliseconds: 300),

            top: 400,
            left: (index * 60.0) +450, // Adjust spacing between items
            child: DragTarget<T>(
              onWillAccept: (data) => data != item,
              onAccept: (data) {
                setState(() {
                  if (data != item) {
                    final oldIndex = _items.indexOf(data);
                    final newIndex = _items.indexOf(item);

                    if (newIndex > oldIndex) {
                      // Moving right: shift others left
                      _items.removeAt(oldIndex);
                      _items.insert(newIndex, data);
                    } else {
                      // Moving left: shift others right
                      _items.removeAt(oldIndex);
                      _items.insert(newIndex, data);
                    }
                  }
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Draggable<T>(
                  data: item,
                  onDragStarted: () {
                    setState(() {
                      _draggedItem = item;

                    });
                  },
                  onDragEnd: (_) {
                    setState(() {
                      _draggedItem = null;
                    });
                  },
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.7,
                      child: widget.builder(item, true),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: widget.builder(item, false),
                  ),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _hoveredItem = item;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _hoveredItem = null;
                      });
                    },
                    child: widget.builder(item, isHovered),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

