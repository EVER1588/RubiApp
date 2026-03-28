import 'package:flutter/material.dart';

enum SplitOrientation { vertical, horizontal }

/// Widget que permite dividir dos elementos con un divisor arrastrable.
/// El usuario puede ajustar la proporción entre ambos elementos.
class ResizableSplit extends StatefulWidget {
  final Widget topChild;
  final Widget bottomChild;
  final double initialRatio; // 0.0 a 1.0
  final double dividerHeight;
  final Color dividerColor;
  final SplitOrientation orientation;

  const ResizableSplit({
    required this.topChild,
    required this.bottomChild,
    this.initialRatio = 0.5,
    this.dividerHeight = 16.0,
    this.dividerColor = Colors.grey,
    this.orientation = SplitOrientation.vertical,
  });

  @override
  State<ResizableSplit> createState() => _ResizableSplitState();
}

class _ResizableSplitState extends State<ResizableSplit> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(0.1, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = widget.orientation == SplitOrientation.vertical;
        final totalSize = isVertical ? constraints.maxHeight : constraints.maxWidth;
        
        final topSize = totalSize * _ratio - widget.dividerHeight / 2;
        final bottomSize = totalSize * (1 - _ratio) - widget.dividerHeight / 2;

        if (isVertical) {
          return Column(
            children: [
              // Elemento superior
              SizedBox(
                height: topSize,
                child: widget.topChild,
              ),
              // Divisor arrastrable
              MouseRegion(
                cursor: SystemMouseCursors.resizeRow,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _ratio += details.delta.dy / totalSize;
                      _ratio = _ratio.clamp(0.1, 0.9);
                    });
                  },
                  child: Container(
                    height: widget.dividerHeight,
                    color: widget.dividerColor.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 3,
                        decoration: BoxDecoration(
                          color: widget.dividerColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Elemento inferior
              SizedBox(
                height: bottomSize,
                child: widget.bottomChild,
              ),
            ],
          );
        } else {
          // Horizontal (si en futuro se necesita)
          return Row(
            children: [
              SizedBox(
                width: topSize,
                child: widget.topChild,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _ratio += details.delta.dx / totalSize;
                      _ratio = _ratio.clamp(0.1, 0.9);
                    });
                  },
                  child: Container(
                    width: widget.dividerHeight,
                    color: widget.dividerColor.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        width: 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.dividerColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: bottomSize,
                child: widget.bottomChild,
              ),
            ],
          );
        }
      },
    );
  }
}
