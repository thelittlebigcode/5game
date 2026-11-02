import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/track_side.dart';
import 'split_hazard_component.dart';
import 'synergy_orb_component.dart';

/// Una de las dos entidades sincronizadas controladas en Split Second.
class DualEntityComponent extends PositionComponent with CollisionCallbacks {
  final TrackSide trackSide;
  bool isInner;

  final void Function(DualEntityComponent entity, SplitHazardComponent hazard)?
  onHitHazard;
  final void Function(DualEntityComponent entity, SynergyOrbComponent orb)?
  onCollectOrb;

  double targetX = 0.0;
  static const double shiftSpeed = 16.0;

  final Paint _entityPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  DualEntityComponent({
    required this.trackSide,
    required this.isInner,
    this.onHitHazard,
    this.onCollectOrb,
  }) : super(size: Vector2(24.0, 24.0), anchor: Anchor.center) {
    targetX = trackSide.laneX(isInner);
    position.setValues(targetX, 650.0);
    _entityPaint.color = trackSide.primaryColor;
    _fillPaint.color = trackSide.primaryColor.withValues(alpha: 0.25);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 11.0));
  }

  /// Maniobra evasiva: invierte el carril asignado (interior <-> exterior).
  void toggleLane() {
    isInner = !isInner;
    targetX = trackSide.laneX(isInner);
  }

  void reset(bool defaultInner) {
    isInner = defaultInner;
    targetX = trackSide.laneX(isInner);
    position.setValues(targetX, 650.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Interpolación suave y reactiva basada en dt
    final t = (shiftSpeed * dt).clamp(0.0, 1.0);
    position.x += (targetX - position.x) * t;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is SplitHazardComponent) {
      onHitHazard?.call(this, other);
    } else if (other is SynergyOrbComponent) {
      onCollectOrb?.call(this, other);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final halfW = size.x / 2;
    final halfH = size.y / 2;

    // Figura geométrica distintiva
    final path = Path();
    if (trackSide == TrackSide.leftTrack) {
      // Triángulo apuntando hacia adelante con alas
      path.moveTo(0, -halfH);
      path.lineTo(halfW, halfH);
      path.lineTo(0, halfH * 0.4);
      path.lineTo(-halfW, halfH);
      path.close();
    } else {
      // Diamante / rombo alargado estilizado
      path.moveTo(0, -halfH);
      path.lineTo(halfW, 0);
      path.lineTo(0, halfH);
      path.lineTo(-halfW, 0);
      path.close();
    }

    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _entityPaint);

    // Ojo central luminoso
    final centerPaint = Paint()..color = trackSide.primaryColor;
    canvas.drawCircle(Offset.zero, 3.0, centerPaint);
  }
}
