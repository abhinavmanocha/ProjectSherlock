import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/chart.dart';
import 'chart_info.dart';

class Canvas3D extends CustomPainter {
  final Chart chart;
   int graphNo = 1;
  Canvas3D(this.chart, {required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black;

    draw(canvas, paint, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void changeGraph(int graphNo) {
    this.graphNo = graphNo;
  }

  void viewXYplane(direction) {
    chart.viewXYplane(direction);
  }

  void viewYZplane(direction) {
    chart.viewYZplane(direction);
  }

  viewXZplane(direction) {
    chart.viewXZplane('+');
  }

  void moveCamera(direction) {
    chart.moveCamera(direction, 0.2);
  }

  void rotateButton(axis, direction) {
    chart.rotateButton(axis, direction);
  }

  void draw(Canvas canvas, Paint paint, Size size) {
    // Background
    //// context..clearRect(0, 0, WIDTH, size.height);
    for (int s = 0; s < chart.graphs[graphNo].length; s++) {
      var shape = chart.graphs[graphNo][s];
      if (shape['edgeColour'] != null) {
        drawShapeEdges(canvas, paint, size, shape, s);
      }
      if (shape['nodeColour'] != null) {
        drawShapeNodes(canvas, paint, size, shape, s);
      }
      if (shape['text'] != null) {
        drawShapeText(canvas, paint, size, shape, s);
      }
    }
  }

  // Given a node, return its (x, y) coordinate from the point of view of the camera
  List viewFromCamera(Size size, List node) {
    var x = node[0] * chart.camera[0][0] +
        node[1] * chart.camera[0][1] +
        node[2] * chart.camera[0][2] +
        chart.rotateCentre[0];
    var y = node[0] * chart.camera[1][0] +
        node[1] * chart.camera[1][1] +
        node[2] * chart.camera[1][2] +
        chart.rotateCentre[1];
    return [x, size.height - y];
  }

  void drawShapeEdges(Canvas canvas, Paint paint, Size size, var shape, var s) {
    var nodes = shape['nodes'];
    paint.style = PaintingStyle.stroke;
    // print("\n");
    //for (var e in shape['edges'])
    for (int e = 0; e < shape['edges'].length; e++) {
      var coord = viewFromCamera(size, nodes[shape['edges'][e][0]]);
      if (chart.highlightEdges["$s,$e"] != null) {
        paint.color = Color(chart.highlightEdges["$s,$e"]);
        paint.strokeWidth = 2;
      } else {
        paint.color = Color(shape['edgeColour']);
        paint.strokeWidth = 1;
      }
      var path = Path();
      path.moveTo(coord[0].toDouble(), coord[1].toDouble());
      coord = viewFromCamera(size, nodes[shape['edges'][e][1]]);
      path.lineTo(coord[0].toDouble(), coord[1].toDouble());
      canvas.drawPath(path, paint);
    }
    // print("\n");
  }

  void drawShapeNodes(Canvas canvas, Paint paint, Size size, shape, s) {
    // var radius = 2; // 4;
    paint.style = PaintingStyle.fill;
    // for (var n in shape.nodes) {
    for (int n = 0; n < shape['nodes'].length; n++) {
      if (shape['nodeColour'] == 0xFF00AA00) {
        paint.color = const Color.fromRGBO(0, 250, 0, 0.45);
      } else {
        if (chart.highlightNodes["$s,$n"] != null) {
          paint.color = Color(chart.highlightNodes["$s,$n"]);
        } else {
          paint.color = Color(shape['nodeColour']);
        }
      } // endif
      var coord = viewFromCamera(size, shape['nodes'][n]);
      var path = Path();
      // path.moveTo(coord[0].toDouble(), coord[1].toDouble());
      path.addOval(Rect.fromCenter(
          center: Offset(coord[0].toDouble(), coord[1].toDouble()),
          width: shape['size'] * 2.0,
          height: shape['size'] * 2.0));

      // path.addArc(
      //     Rect.fromCenter(
      //         center: Offset(coord[0].toDouble(), coord[1].toDouble()),
      //         width: shape['size'] * 2.0,
      //         height: shape['size'] * 2.0),
      //     0,
      //     2.0 * pi);
      canvas.drawPath(path, paint);
    }
  }

  void drawShapeText(Canvas canvas, Paint paint, Size size, shape, s) {
    // paint.color = const Color(0x22222200);
    // for (var n in shape['nodes']) {
    for (int n = 0; n < shape['nodes'].length; n++) {
      var coord = viewFromCamera(size, shape['nodes'][n]);
      // context.textBaseline = 'middle';
      // context.fillText(shape['text'][n], coord[0], coord[1]);
      TextSpan span = TextSpan(
          style: const TextStyle(color: Color(0x22222200)),
          text: shape['text'][n]);
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(coord[0].toDouble(), coord[1].toDouble()));
    }
  }

  
}
