library paint_ui;

import 'package:flutter/material.dart';

class PaintUI extends StatefulWidget {
  final CustomPainter? painter;
  final Widget? sliderWidget;
  final Widget? colorBoxes;
  PaintUI({this.painter, this.sliderWidget, this.colorBoxes});
  PaintUIState createState() => PaintUIState();
}

Widget sliderWidget(value, Function(double width) onChanged) => Slider(
      min: 0,
      max: 100,
      value: value,
      onChanged: (value) {
        onChanged(value);
      },
    );

Widget colorBoxesWidget = Wrap(children: [
  ...List.generate(
      10,
      (index) =>
          Container(color: Colors.primaries[index], width: 50, height: 50))
]);

class PaintUIState extends State<PaintUI> {
  List<Offset?> _points = <Offset>[];
  double strokeWidth = 5.0;
  Widget build(BuildContext context) {
    return Column(
      children: [
        colorBoxesWidget,
        sliderWidget(5.0, (width) {
          strokeWidth = width;
        }),
        GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              final referenceBox = context.findRenderObject() as RenderBox;
              Offset localPosition =
                  referenceBox.globalToLocal(details.globalPosition);
              _points = List.from(_points)..add(localPosition);
            });
          },
          onPanEnd: (DragEndDetails details) => _points.add(null),
          child: CustomPaint(
            painter: widget.painter ??
                PaintUIPainter(_points, strokeWidth: strokeWidth),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class PaintUIPainter extends CustomPainter {
  PaintUIPainter(this.points, {required this.strokeWidth});
  final List<Offset?> points;
  double strokeWidth;
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PaintUIPainter other) => other.points != points;
}
