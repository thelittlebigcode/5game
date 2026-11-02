import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/lane.dart';
import 'pulse_player_component.dart';

/// Tipo de barrera en Pulse Shift.
enum BarrierType {
  fixed, // Barrera fija en su carril
  phaseGate, // Barrera dinámica reactiva que cambia de carril cuando el jugador pulsa el cambio
}

/// Obstáculo de energía vertical que se desplaza hacia abajo.
/// Conforme a ETAPAS.md (Etapa 3.3).
class BarrierComponent extends HazardBarrierComponent with CollisionCallbacks {
  static const double barrierWidth = 36.0;
  static const double barrierHeight = 22.0;

  final BarrierType type;
  Lane currentLane;
  double speed;
  double targetX;

  late final Paint _fillPaint;
  late final Paint _borderPaint;
  late final Paint _glowPaint;
  late final Paint _stripePaint;

  BarrierComponent({
    required this.currentLane,
    required double initialY,
    required this.speed,
    this.type = BarrierType.fixed,
  }) : targetX = currentLane.xPosition,
       super(
         position: Vector2(currentLane.xPosition, initialY),
         size: Vector2(barrierWidth, barrierHeight),
         anchor: Anchor.center,
       ) {
    final baseColor = type == BarrierType.fixed
        ? ArcadeColors.hazard
        : ArcadeColors.electricAmber;

    _fillPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    _stripePaint = Paint()
      ..color = ArcadeColors.flashWhite.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Hitbox rectangular ajustada al tamaño
    add(
      RectangleHitbox(
        size: Vector2(barrierWidth - 4, barrierHeight - 4),
        position: Vector2(2, 2),
      ),
    );
  }

  /// Reacciona dinámicamente cuando el jugador cambia de carril (solo phaseGate)
  void onPlayerShiftedLane() {
    if (type == BarrierType.phaseGate) {
      currentLane = currentLane.opposite;
      targetX = currentLane.xPosition;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Desplazamiento hacia abajo
    position.y += speed * dt;

    // Interpolación si es una compuerta de fase en movimiento
    if (type == BarrierType.phaseGate) {
      const lerpSpeed = 20.0;
      position.x += (targetX - position.x) * math.min(1.0, lerpSpeed * dt);
    }

    // Limpieza automática al salir de la pantalla por abajo
    if (position.y > 450.0) {
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

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      _fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      _glowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      _borderPaint,
    );

    // Patrón de rayas de advertencia internas
    const numStripes = 3;
    final step = size.x / (numStripes + 1);
    for (int i = 1; i <= numStripes; i++) {
      final x = i * step;
      canvas.drawLine(
        Offset(x - 3, size.y - 4),
        Offset(x + 3, 4),
        _stripePaint,
      );
    }
  }
}
