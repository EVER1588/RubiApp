import 'dart:math';
import 'package:flutter/material.dart';

/// Dibuja el camino serpenteante estilo "road trip" sobre el que
/// se posicionan los nodos de las letras. También dibuja huellitas
/// en el camino que se van marcando conforme avanza el progreso.
class CaminoPainter extends CustomPainter {
  final int totalNodos;
  final double scrollFraction; // 0.0–1.0
  final int nodosCompletados; // Cuántos ejercicios completaron (para las huellitas)
  final double animationValue; // 0.0–1.0 para animar nuevas huellitas

  CaminoPainter({
    required this.totalNodos,
    this.scrollFraction = 0.0,
    this.nodosCompletados = 0,
    this.animationValue = 0.0,
  });

  /// Calcula las posiciones (x, y) de cada nodo sobre el camino.
  /// Se llama externamente para posicionar los widgets de nodo.
  static List<Offset> calcularPosicionesNodos({
    required int total,
    required double anchoCanvas,
    required double altoCanvas,
  }) {
    final positions = <Offset>[];
    final margenX = anchoCanvas * 0.18;
    final xIzq = margenX;
    final xDer = anchoCanvas - margenX;
    final xCentro = anchoCanvas / 2;

    // Espacio vertical entre nodos
    final espacioY = altoCanvas / (total + 1);

    for (int i = 0; i < total; i++) {
      final y = altoCanvas - espacioY * (i + 1); // de abajo hacia arriba
      double x;
      // Patrón serpenteante: izq, centro, der, centro, izq...
      final pos = i % 4;
      if (pos == 0) {
        x = xCentro;
      } else if (pos == 1) {
        x = xDer;
      } else if (pos == 2) {
        x = xCentro;
      } else {
        x = xIzq;
      }
      positions.add(Offset(x, y));
    }
    return positions;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final positions = calcularPosicionesNodos(
      total: totalNodos,
      anchoCanvas: size.width,
      altoCanvas: size.height,
    );

    if (positions.length < 2) return;

    // ── Pintura del camino (carretera) ──
    final roadPaint = Paint()
      ..color = const Color(0xFF5C5C5C)
      ..strokeWidth = 28
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final borderPaint = Paint()
      ..color = const Color(0xFF3A3A3A)
      ..strokeWidth = 34
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Construir path suave con curvas entre nodos
    final path = Path();
    path.moveTo(positions.first.dx, positions.first.dy);

    for (int i = 0; i < positions.length - 1; i++) {
      final p0 = positions[i];
      final p1 = positions[i + 1];
      final midY = (p0.dy + p1.dy) / 2;
      // Curva Bézier cúbica con puntos de control horizontales
      path.cubicTo(p0.dx, midY, p1.dx, midY, p1.dx, p1.dy);
    }

    // Dibujar: borde → carretera → línea central punteada
    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, roadPaint);
    _drawDashedPath(canvas, path, dashPaint);

    // ── Dibujar huellitas en el camino ──
    _drawFootprints(canvas, path, positions);
  }

  /// Dibuja huellitas animadas en el camino basadas en progreso.
  void _drawFootprints(Canvas canvas, Path path, List<Offset> positions) {
    if (nodosCompletados <= 0) return;

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold<double>(0.0, (sum, m) => sum + m.length);

    // Calcular cuántas huellitas mostrar
    final proportionCompleted =
        (nodosCompletados + animationValue) / totalNodos;
    final distanceCompleted = totalLength * proportionCompleted;

    // Pintura de huellitas
    final footprintPaint = Paint()
      ..color = Colors.amber.shade700.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Dibujar varias huellas pequeñas a lo largo del tramo completado
    double distance = 0.0;
    const footprintSpacing = 40.0;

    while (distance < distanceCompleted) {
      // Encontrar el punto en el path en esta distancia
      var targetMetric;
      double offsetOnMetric = distance;

      for (final metric in metrics) {
        if (offsetOnMetric <= metric.length) {
          targetMetric = metric;
          break;
        }
        offsetOnMetric -= metric.length;
      }

      if (targetMetric != null && offsetOnMetric <= targetMetric.length) {
        final tangent = targetMetric.getTangentForOffset(offsetOnMetric);
        if (tangent != null) {
          _drawSingleFootprint(
            canvas,
            tangent.position,
            tangent.angle,
            footprintPaint,
          );
        }
      }

      distance += footprintSpacing;
    }
  }

  /// Dibuja una huella (footprint) individual en una posición y ángulo.
  void _drawSingleFootprint(
    Canvas canvas,
    Offset position,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // Dibujar forma de huella: círculo central + 4 dedos
    const mainRadius = 5.0;
    const toeRadius = 3.0;

    // Círculo central (talón)
    canvas.drawCircle(const Offset(0, 0), mainRadius, paint);

    // 4 dedos arriba
    for (int i = 0; i < 4; i++) {
      final angle = (i - 1.5) * 0.3;
      final offset = Offset(
        sin(angle) * 8,
        -12 - (i.abs() == 1 ? 2 : 0), // dedos del centro más centrales
      );
      canvas.drawCircle(offset, toeRadius, paint);
    }

    canvas.restore();
  }

  /// Dibuja una línea punteada sobre un path.
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashLength = 10.0;
      const gapLength = 12.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        final end = min(distance + len, metric.length);
        if (draw) {
          final extractPath = metric.extractPath(distance, end);
          canvas.drawPath(extractPath, paint);
        }
        distance = end;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CaminoPainter oldDelegate) =>
      oldDelegate.totalNodos != totalNodos ||
      oldDelegate.nodosCompletados != nodosCompletados ||
      (oldDelegate.animationValue - animationValue).abs() > 0.01;
}
