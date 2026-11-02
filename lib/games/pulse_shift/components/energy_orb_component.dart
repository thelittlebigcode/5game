import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/lane.dart';
import 'pulse_player_component.dart';

/// Orbe de energía coleccionable ubicado en trayectorias de riesgo.
/// Conforme a ETAPAS.md (Etapa 3.4).
class EnergyOrbComponent extends PulseOrbComponent with CollisionCallbacks {
  static const double orbRadius = 9.0;

  final Lane lane;
  double speed;
  bool isCollected = false;

  late final Paint _fillPaint;
  late final Paint _borderPaint;
  late final Paint _glowPaint;
  late final Paint _sparkPaint;

  double _pulseTimer = 0.0;

  EnergyOrbComponent({
    required this.lane,
    required double initialY,
    required this.speed,
  }) : super(
         position: Vector2(lane.xPosition, initialY),
         size: Vector2(orbRadius * 2, orbRadius * 2),
         anchor: Anchor.center,
       ) {
    _fillPaint = Paint()
      ..color = ArcadeColors.collectible.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = ArcadeColors.collectible
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    _glowPaint = Paint()
      ..color = ArcadeColors.collectible.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    _sparkPaint = Paint()
      ..color = ArcadeColors.flashWhite
      ..style = PaintingStyle.fill;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      CircleHitbox(
        radius: orbRadius,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTimer += dt * 9.0;

    // Desplazamiento hacia abajo
    position.y += speed * dt;

    if (position.y > 450.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final pulseScale = 1.0 + 0.18 * math.sin(_pulseTimer);

    canvas.drawCircle(center, orbRadius * pulseScale + 3, _glowPaint);
    canvas.drawCircle(center, orbRadius * pulseScale, _fillPaint);
    canvas.drawCircle(center, orbRadius, _borderPaint);

    // Chispazo blanco en el centro
    canvas.drawCircle(center, 2.5, _sparkPaint);
  }
}
