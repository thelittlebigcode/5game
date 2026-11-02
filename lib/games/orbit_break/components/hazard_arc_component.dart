import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Obstáculo angular que se genera en la órbita con hitbox de precisión
class HazardArcComponent extends PositionComponent with CollisionCallbacks {
  final double orbitRadius;
  final double spawnAngle;
  final double sweepAngle;
  final double thickness;

  double lifeTime;
  final double maxLifeTime;

  final Paint _arcPaint = Paint()
    ..color = ArcadeColors.hazard
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _glowPaint = Paint()
    ..color = ArcadeColors.hazard.withValues(alpha: 0.3)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  HazardArcComponent({
    required this.orbitRadius,
    required this.spawnAngle,
    required this.sweepAngle,
    this.thickness = 16.0,
    this.maxLifeTime = 5.0,
  }) : lifeTime = maxLifeTime,
       super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Aproximación de hitbox poligonal/circular a lo largo del arco
    const hitboxesCount = 5;
    for (int i = 0; i < hitboxesCount; i++) {
      final t = i / (hitboxesCount - 1);
      final segmentAngle = spawnAngle + (t - 0.5) * sweepAngle;
      final hx = orbitRadius * math.cos(segmentAngle);
      final hy = orbitRadius * math.sin(segmentAngle);

      final hb = CircleHitbox(
        radius: thickness / 2,
        position: Vector2(hx, hy),
        anchor: Anchor.center,
      );
      add(hb);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromCircle(center: Offset.zero, radius: orbitRadius);

    _arcPaint.strokeWidth = thickness;
    _glowPaint.strokeWidth = thickness + 8;

    final start = spawnAngle - (sweepAngle / 2);
    canvas.drawArc(rect, start, sweepAngle, false, _glowPaint);
    canvas.drawArc(rect, start, sweepAngle, false, _arcPaint);
  }
}
