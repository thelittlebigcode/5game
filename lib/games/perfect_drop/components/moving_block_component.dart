import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/block_type.dart';

/// Plataforma móvil oscilante horizontal que el jugador debe detener en el momento justo.
class MovingBlockComponent extends PositionComponent {
  final BlockType blockType;
  final double blockWidth;
  final double blockHeight;
  final double speed;
  final double minX;
  final double maxX;

  int direction; // 1 = derecha, -1 = izquierda
  double _elapsed = 0.0;

  late final Paint _borderPaint;
  late final Paint _fillPaint;
  late final Paint _glowPaint;
  late final Paint _centerGuidePaint;

  MovingBlockComponent({
    required double initialX,
    required double centerY,
    required this.blockWidth,
    required this.blockHeight,
    required this.speed,
    required this.blockType,
    this.direction = 1,
    this.minX = -185.0,
    this.maxX = 185.0,
  }) : super(
         position: Vector2(initialX, centerY),
         size: Vector2(blockWidth, blockHeight),
         anchor: Anchor.center,
       ) {
    final baseColor = blockType.color;

    _borderPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    _fillPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    _glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    _centerGuidePaint = Paint()
      ..color = ArcadeColors.flashWhite
      ..strokeWidth = 2.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    double effectiveSpeed = speed;
    if (blockType == BlockType.elastic) {
      // Modulación armónica elástica
      effectiveSpeed *= (0.85 + 0.35 * (1.0 + math.sin(_elapsed * 6.0)) / 2);
    }

    position.x += direction * effectiveSpeed * dt;

    // Rebote en los bordes de oscilación
    if (position.x > maxX && direction > 0) {
      position.x = maxX;
      direction = -1;
    } else if (position.x < minX && direction < 0) {
      position.x = minX;
      direction = 1;
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

    // Relleno y resplandor
    canvas.drawRect(rect, _fillPaint);
    canvas.drawRect(rect, _glowPaint);
    canvas.drawRect(rect, _borderPaint);

    // Marca central de puntería milimétrica
    canvas.drawLine(
      Offset(size.x / 2, 2),
      Offset(size.x / 2, size.y - 2),
      _centerGuidePaint,
    );
  }
}
