import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Fragmento residual sobrante o bloque fallido que cae con física de gravedad y rotación.
/// Conforme a ETAPAS.md (Etapa 2.2).
class FallingDebrisComponent extends PositionComponent {
  final double blockWidth;
  final double blockHeight;
  final Color color;

  double vy = 40.0;
  final double vx;
  final double rotationSpeed;
  static const double gravity = 900.0;
  double lifeTimer = 2.0;

  late final Paint _paint;
  late final Paint _fillPaint;

  FallingDebrisComponent({
    required double centerX,
    required double centerY,
    required this.blockWidth,
    required this.blockHeight,
    required this.color,
    this.vx = 25.0,
    this.rotationSpeed = 3.5,
  }) : super(
         position: Vector2(centerX, centerY),
         size: Vector2(blockWidth, blockHeight),
         anchor: Anchor.center,
       ) {
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _fillPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);

    vy += gravity * dt;
    position.y += vy * dt;
    position.x += vx * dt;
    angle += rotationSpeed * dt;

    lifeTimer -= dt;
    if (lifeTimer <= 0.0 || position.y > 600.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );

    canvas.drawRect(rect, _fillPaint);
    canvas.drawRect(rect, _paint);
  }
}
