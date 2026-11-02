import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/track_side.dart';

/// Obstáculo en una de las pistas de Split Second.
class SplitHazardComponent extends PositionComponent with CollisionCallbacks {
  final TrackSide trackSide;
  final bool isInner;

  final Paint _hazardPaint = Paint()
    ..color = ArcadeColors.hazard
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _hazardFillPaint = Paint()
    ..color = ArcadeColors.hazard.withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  SplitHazardComponent({
    required this.trackSide,
    required this.isInner,
    required Vector2 position,
    Vector2? size,
  }) : super(
         position: position,
         size: size ?? Vector2(40.0, 32.0),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: size));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final halfW = size.x / 2;
    final halfH = size.y / 2;

    // Rombo o bloque de advertencia
    final path = Path()
      ..moveTo(0, -halfH)
      ..lineTo(halfW, 0)
      ..lineTo(0, halfH)
      ..lineTo(-halfW, 0)
      ..close();

    canvas.drawPath(path, _hazardFillPaint);
    canvas.drawPath(path, _hazardPaint);

    // Cruz de peligro interior
    canvas.drawLine(
      Offset(-halfW * 0.4, -halfH * 0.4),
      Offset(halfW * 0.4, halfH * 0.4),
      _hazardPaint,
    );
    canvas.drawLine(
      Offset(-halfW * 0.4, halfH * 0.4),
      Offset(halfW * 0.4, -halfH * 0.4),
      _hazardPaint,
    );
  }
}
