import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/block_type.dart';

/// Bloque fijo que conforma la torre vertical en Perfect Drop.
/// Utiliza dibujo puramente vectorial sin sprites pesados.
class StackedBlockComponent extends PositionComponent {
  final BlockType blockType;
  final double blockWidth;
  final double blockHeight;

  late final Paint _borderPaint;
  late final Paint _fillPaint;
  late final Paint _glowPaint;
  late final Paint _flashPaint;

  double flashTimer = 0.0;
  static const double maxFlashDuration = 0.35;

  StackedBlockComponent({
    required double centerX,
    required double centerY,
    required this.blockWidth,
    required this.blockHeight,
    required this.blockType,
    bool startWithFlash = false,
  }) : super(
         position: Vector2(centerX, centerY),
         size: Vector2(blockWidth, blockHeight),
         anchor: Anchor.center,
       ) {
    final baseColor = blockType.color;

    _borderPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _fillPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    _glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    _flashPaint = Paint()
      ..color = ArcadeColors.flashWhite
      ..style = PaintingStyle.fill;

    if (startWithFlash) {
      flashTimer = maxFlashDuration;
    }
  }

  void triggerFlash() {
    flashTimer = maxFlashDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (flashTimer > 0.0) {
      flashTimer = (flashTimer - dt).clamp(0.0, maxFlashDuration);
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

    // Relleno translúcido
    canvas.drawRect(rect, _fillPaint);

    // Resplandor neón exterior
    canvas.drawRect(rect, _glowPaint);

    // Borde vectorial nítido
    canvas.drawRect(rect, _borderPaint);

    // Destello de Perfect Drop
    if (flashTimer > 0.0) {
      final alpha = (flashTimer / maxFlashDuration).clamp(0.0, 1.0);
      _flashPaint.color = ArcadeColors.flashWhite.withValues(
        alpha: alpha * 0.85,
      );
      canvas.drawRect(rect, _flashPaint);
    }

    // Detalles vectoriales de precisión en las esquinas
    final cornerPaint = Paint()
      ..color = ArcadeColors.flashWhite.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    const markLength = 3.5;
    // Izquierda
    canvas.drawLine(
      Offset(rect.left + 2, rect.top + 2),
      Offset(rect.left + 2 + markLength, rect.top + 2),
      cornerPaint,
    );
    // Derecha
    canvas.drawLine(
      Offset(rect.right - 2, rect.top + 2),
      Offset(rect.right - 2 - markLength, rect.top + 2),
      cornerPaint,
    );
  }
}
