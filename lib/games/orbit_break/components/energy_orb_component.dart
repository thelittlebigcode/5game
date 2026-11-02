import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Orbe de energía coleccionable ubicado en la trayectoria de órbita
class EnergyOrbComponent extends PositionComponent with CollisionCallbacks {
  final double orbitRadius;
  final double orbAngle;
  final double orbRadius;

  double _pulse = 0.0;
  bool isCollected = false;

  final Paint _fillPaint = Paint()
    ..color = ArcadeColors.collectible
    ..style = PaintingStyle.fill;

  final Paint _glowPaint = Paint()
    ..color = ArcadeColors.collectible.withValues(alpha: 0.35)
    ..style = PaintingStyle.fill;

  final Paint _ringPaint = Paint()
    ..color = ArcadeColors.flashWhite
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  EnergyOrbComponent({
    required this.orbitRadius,
    required this.orbAngle,
    this.orbRadius = 7.0,
  }) : super(size: Vector2.all(orbRadius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position.x = orbitRadius * math.cos(orbAngle);
    position.y = orbitRadius * math.sin(orbAngle);

    add(
      CircleHitbox(
        radius: orbRadius + 2,
        position: Vector2.all(orbRadius),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 5.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(orbRadius, orbRadius);
    final pulseScale = 1.0 + 0.2 * math.sin(_pulse);

    canvas.drawCircle(center, (orbRadius + 3) * pulseScale, _glowPaint);
    canvas.drawCircle(center, orbRadius, _fillPaint);
    canvas.drawCircle(center, orbRadius * 0.5, _ringPaint);
  }
}
