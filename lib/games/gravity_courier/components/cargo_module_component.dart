import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Módulo de carga que el jugador puede transportar.
/// Añade puntuación extra pero añade peso e inercia a la nave.
class CargoModuleComponent extends PositionComponent with CollisionCallbacks {
  bool isCollected = false;

  final Paint _cargoPaint = Paint()
    ..color = ArcadeColors.electricAmber
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _glowPaint = Paint()
    ..color = ArcadeColors.electricAmber.withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  CargoModuleComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(20.0, 20.0),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 10.0));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );

    // Caja de carga con núcleo brillante
    canvas.drawRect(rect, _glowPaint);
    canvas.drawRect(rect, _cargoPaint);

    // Icono vectorial de paquete o cruz interna
    final crossPaint = Paint()
      ..color = ArcadeColors.flashWhite
      ..strokeWidth = 1.2;

    canvas.drawLine(
      Offset(rect.left + 5, rect.top + 5),
      Offset(rect.right - 5, rect.bottom - 5),
      crossPaint,
    );
    canvas.drawLine(
      Offset(rect.left + 5, rect.bottom - 5),
      Offset(rect.right - 5, rect.top + 5),
      crossPaint,
    );
  }
}
