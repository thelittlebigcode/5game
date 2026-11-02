import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/lane.dart';

/// Nave/Entidad del jugador en Pulse Shift.
/// Conforme a ETAPAS.md (Etapas 3.1 y 3.2).
class PulsePlayerComponent extends PositionComponent with CollisionCallbacks {
  static const double fixedY = 220.0;
  static const double playerWidth = 26.0;
  static const double playerHeight = 32.0;

  Lane currentLane = Lane.left;
  double targetX = Lane.left.xPosition;

  final VoidCallback? onHitHazard;
  final void Function(PositionComponent orb)? onCollectOrb;

  late final Paint _shipFillPaint;
  late final Paint _shipBorderPaint;
  late final Paint _glowPaint;
  late final Paint _corePaint;

  double _pulseTimer = 0.0;

  PulsePlayerComponent({this.onHitHazard, this.onCollectOrb})
    : super(
        position: Vector2(Lane.left.xPosition, fixedY),
        size: Vector2(playerWidth, playerHeight),
        anchor: Anchor.center,
      ) {
    _shipFillPaint = Paint()
      ..color = Lane.left.primaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    _shipBorderPaint = Paint()
      ..color = Lane.left.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _glowPaint = Paint()
      ..color = Lane.left.glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    _corePaint = Paint()
      ..color = ArcadeColors.flashWhite
      ..style = PaintingStyle.fill;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Hitbox circular central ligeramente perdonable para un arcade justo
    add(CircleHitbox(radius: 10.0, anchor: Anchor.center, position: size / 2));
  }

  /// Cambia instantáneamente de carril con transición snappy y cambio cromático reactivo
  void shiftLane() {
    currentLane = currentLane.opposite;
    targetX = currentLane.xPosition;

    // Actualizar colores reactivos
    final col = currentLane.primaryColor;
    _shipFillPaint.color = col.withValues(alpha: 0.25);
    _shipBorderPaint.color = col;
    _glowPaint.color = currentLane.glowColor;
  }

  void reset() {
    currentLane = Lane.left;
    targetX = Lane.left.xPosition;
    position.x = targetX;
    position.y = fixedY;

    final col = currentLane.primaryColor;
    _shipFillPaint.color = col.withValues(alpha: 0.25);
    _shipBorderPaint.color = col;
    _glowPaint.color = currentLane.glowColor;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTimer += dt * 8.0;

    // Interpolación ultra-snappy de posición X (0.05s aprox)
    const lerpRate = 28.0;
    position.x += (targetX - position.x) * math.min(1.0, lerpRate * dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // Polígono en flecha aerodinámica retro
    final path = Path()
      ..moveTo(w / 2, 0) // Punta superior
      ..lineTo(w, h * 0.8) // Esquina inferior derecha
      ..lineTo(w / 2, h * 0.6) // Hendidura posterior
      ..lineTo(0, h * 0.8) // Esquina inferior izquierda
      ..close();

    canvas.drawPath(path, _glowPaint);
    canvas.drawPath(path, _shipFillPaint);
    canvas.drawPath(path, _shipBorderPaint);

    // Núcleo brillante en el centro
    final pulseScale = 1.0 + 0.25 * math.sin(_pulseTimer);
    canvas.drawCircle(Offset(w / 2, h * 0.45), 3.0 * pulseScale, _corePaint);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Verificamos si es obstáculo o coleccionable
    if (other is HazardBarrierComponent) {
      onHitHazard?.call();
    } else if (other is PulseOrbComponent) {
      onCollectOrb?.call(other);
    }
  }
}

// Forward declarations para tipos de componentes interactivos
abstract class HazardBarrierComponent extends PositionComponent {
  HazardBarrierComponent({super.position, super.size, super.anchor});
}

abstract class PulseOrbComponent extends PositionComponent {
  PulseOrbComponent({super.position, super.size, super.anchor});
}
