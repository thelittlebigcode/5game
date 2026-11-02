import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import 'energy_orb_component.dart';
import 'hazard_arc_component.dart';

/// Esfera orbital del jugador con control de inversión de dirección
class OrbitalPlayerComponent extends PositionComponent with CollisionCallbacks {
  final double orbitRadius;
  final double playerRadius;

  double currentAngle = -math.pi / 2; // Arriba por defecto
  int direction = 1; // 1 = horario, -1 = antihorario
  double angularSpeed = 2.4;

  final Paint _fillPaint = Paint()
    ..color = ArcadeColors.player
    ..style = PaintingStyle.fill;

  final Paint _glowPaint = Paint()
    ..color = ArcadeColors.player.withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  final Paint _ringPaint = Paint()
    ..color = ArcadeColors.flashWhite
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  late final CircleHitbox hitbox;
  void Function()? onHitHazard;
  void Function(EnergyOrbComponent orb)? onCollectOrb;

  OrbitalPlayerComponent({
    required this.orbitRadius,
    this.playerRadius = 10.0,
    this.onHitHazard,
    this.onCollectOrb,
  }) : super(size: Vector2.all(playerRadius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateCartesianPosition();

    hitbox = CircleHitbox(
      radius: playerRadius,
      position: Vector2.all(playerRadius),
      anchor: Anchor.center,
    );
    add(hitbox);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is HazardArcComponent) {
      onHitHazard?.call();
    } else if (other is EnergyOrbComponent) {
      onCollectOrb?.call(other);
    }
  }

  /// Invierte el sentido orbital
  void flipDirection() {
    direction = -direction;
  }

  void _updateCartesianPosition() {
    position.x = orbitRadius * math.cos(currentAngle);
    position.y = orbitRadius * math.sin(currentAngle);
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentAngle += direction * angularSpeed * dt;
    // Mantener ángulo normalizado [0, 2*pi)
    const twoPi = 2 * math.pi;
    currentAngle = ((currentAngle % twoPi) + twoPi) % twoPi;
    _updateCartesianPosition();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(playerRadius, playerRadius);

    // Resplandor exterior
    canvas.drawCircle(center, playerRadius + 4, _glowPaint);
    // Cuerpo
    canvas.drawCircle(center, playerRadius, _fillPaint);
    // Borde blanco destello
    canvas.drawCircle(center, playerRadius * 0.65, _ringPaint);
  }

  void reset() {
    currentAngle = -math.pi / 2;
    direction = 1;
    angularSpeed = 2.4;
    _updateCartesianPosition();
  }
}
