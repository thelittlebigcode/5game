import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/track_side.dart';

/// Bonificador recolectable en una de las pistas de Split Second.
/// Al recogerlo en una pista, activa un "pulso de defensa" o sinergia
/// que elimina el peligro inminente en la OTRA pista.
class SynergyOrbComponent extends PositionComponent with CollisionCallbacks {
  final TrackSide trackSide;
  final bool isInner;
  bool isCollected = false;

  final Paint _orbPaint = Paint()
    ..color = ArcadeColors.electricAmber
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _fillPaint = Paint()
    ..color = ArcadeColors.electricAmber.withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  SynergyOrbComponent({
    required this.trackSide,
    required this.isInner,
    required Vector2 position,
  }) : super(
         position: position,
         size: Vector2(24.0, 24.0),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 12.0));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(Offset.zero, 10.0, _fillPaint);
    canvas.drawCircle(Offset.zero, 10.0, _orbPaint);

    // Núcleo brillante
    final corePaint = Paint()..color = ArcadeColors.flashWhite;
    canvas.drawCircle(Offset.zero, 3.5, corePaint);
  }
}
