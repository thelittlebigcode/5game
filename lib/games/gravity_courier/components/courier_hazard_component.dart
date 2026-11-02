import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/wall_side.dart';

/// Tipos de peligros anclados a las paredes o cruzados en Gravity Courier.
enum HazardType {
  /// Picos anclados a una de las paredes
  wallSpikes,

  /// Barrera electromagnética horizontal flotante
  laserBarrier,

  /// Compuerta oscilante que se abre y cierra periódicamente
  movingGate,
}

/// Componente que representa un obstáculo o trampa en el pozo gravitatorio.
class CourierHazardComponent extends PositionComponent with CollisionCallbacks {
  final HazardType hazardType;
  final WallSide? wallSide;

  final Paint _hazardPaint = Paint()
    ..color = ArcadeColors.hazard
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _fillPaint = Paint()
    ..color = ArcadeColors.hazard.withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  // Variables para compuerta oscilante
  double _oscillationTimer = 0.0;
  double _gateExtension = 0.0;
  final double maxGateWidth;

  CourierHazardComponent({
    required this.hazardType,
    required Vector2 position,
    required Vector2 size,
    this.wallSide,
    this.maxGateWidth = 140.0,
  }) : super(position: position, size: size, anchor: Anchor.topLeft) {
    _gateExtension = size.x;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: size));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (hazardType == HazardType.movingGate) {
      _oscillationTimer += dt * 3.0;
      // Oscila entre un ancho mínimo (30px) y el ancho máximo asignado
      final factor = (1.0 + math.sin(_oscillationTimer)) / 2.0; // 0.0 a 1.0
      _gateExtension = 30.0 + factor * (maxGateWidth - 30.0);
      size.x = _gateExtension;
      if (children.whereType<RectangleHitbox>().isNotEmpty) {
        children.whereType<RectangleHitbox>().first.size = Vector2(
          _gateExtension,
          size.y,
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (hazardType) {
      case HazardType.wallSpikes:
        _renderSpikes(canvas);
        break;
      case HazardType.laserBarrier:
        _renderLaser(canvas);
        break;
      case HazardType.movingGate:
        _renderGate(canvas);
        break;
    }
  }

  void _renderSpikes(Canvas canvas) {
    final path = Path();
    final count = (size.y / 20.0).floor().clamp(1, 10);
    final stepY = size.y / count;

    if (wallSide == WallSide.left) {
      // Picos apuntando a la derecha
      for (int i = 0; i < count; i++) {
        final top = i * stepY;
        path.moveTo(0, top);
        path.lineTo(size.x, top + stepY / 2);
        path.lineTo(0, top + stepY);
      }
    } else {
      // Picos apuntando a la izquierda desde la pared derecha
      for (int i = 0; i < count; i++) {
        final top = i * stepY;
        path.moveTo(size.x, top);
        path.lineTo(0, top + stepY / 2);
        path.lineTo(size.x, top + stepY);
      }
    }
    path.close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _hazardPaint);
  }

  void _renderLaser(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, _fillPaint);
    canvas.drawRect(rect, _hazardPaint);

    // Línea central brillante de energía
    final centerPaint = Paint()
      ..color = ArcadeColors.flashWhite
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.y / 2),
      Offset(size.x, size.y / 2),
      centerPaint,
    );
  }

  void _renderGate(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, _fillPaint);
    canvas.drawRect(rect, _hazardPaint);

    // Rayas diagonales de peligro de compuerta
    final stripePaint = Paint()
      ..color = ArcadeColors.hazard.withValues(alpha: 0.6)
      ..strokeWidth = 2.0;

    for (double x = -size.y; x < size.x; x += 15.0) {
      canvas.drawLine(
        Offset(x.clamp(0.0, size.x), size.y),
        Offset((x + size.y).clamp(0.0, size.x), 0),
        stripePaint,
      );
    }
  }
}
