import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Núcleo geométrico pulsante en el centro del mundo (0, 0)
class CentralCoreComponent extends PositionComponent {
  final Paint _corePaint = Paint()
    ..color = ArcadeColors.neonCyan
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  final Paint _glowPaint = Paint()
    ..color = ArcadeColors.neonCyan.withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  final Paint _orbitGuidePaint = Paint()
    ..color = ArcadeColors.surfaceBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final double orbitRadius;
  double _pulseTimer = 0.0;

  CentralCoreComponent({required this.orbitRadius})
    : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTimer += dt * 3.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Guía orbital circular punteada / atenuada
    canvas.drawCircle(Offset.zero, orbitRadius, _orbitGuidePaint);

    // Núcleo pulsante
    final pulseScale = 1.0 + 0.12 * math.sin(_pulseTimer);
    const baseCoreRadius = 24.0;
    final r = baseCoreRadius * pulseScale;

    canvas.drawCircle(Offset.zero, r + 6, _glowPaint);
    canvas.drawCircle(Offset.zero, r, _corePaint);

    // Cruz interior vectorial
    canvas.drawLine(Offset(-r / 2, 0), Offset(r / 2, 0), _corePaint);
    canvas.drawLine(Offset(0, -r / 2), Offset(0, r / 2), _corePaint);
  }
}
