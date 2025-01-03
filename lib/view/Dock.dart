
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
  late List<T> _items = widget.items;

  /// Currently hovered item.
  T? _hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.map((item) {
          final isHovered = item == _hoveredItem;

          return DragTarget<T>(
            onWillAccept: (data) => data != item,
            onAccept: (data) {
              setState(() {
                // Create a new list with the reordered items
                final updatedItems = List<T>.from(_items);
                final oldIndex = updatedItems.indexOf(data);
                final newIndex = updatedItems.indexOf(item);

                updatedItems.removeAt(oldIndex);
                updatedItems.insert(newIndex, data);
                _items = updatedItems;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<T>(
                data: item,
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
          );
        }).toList(),
      ),
    );
  }
}