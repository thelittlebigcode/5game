import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/lane.dart';

/// Rieles vectoriales de los carriles con marcadores de velocidad descendentes.
/// Conforme a ETAPAS.md (Etapa 3.1).
class LaneTrackComponent extends Component {
  static const double trackTop = -400.0;
  static const double trackBottom = 400.0;
  static const double markerSpacing = 48.0;

  double scrollOffset = 0.0;
  double scrollSpeed = 260.0;

  final Paint _railPaint = Paint()
    ..color = ArcadeColors.surfaceBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final Paint _activeRailPaint = Paint()
    ..color = ArcadeColors.neonCyan.withValues(alpha: 0.15)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  final Paint _markerPaint = Paint()
    ..color = ArcadeColors.textMuted.withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  void update(double dt) {
    super.update(dt);
    scrollOffset = (scrollOffset + scrollSpeed * dt) % markerSpacing;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final leftX = Lane.left.xPosition;
    final rightX = Lane.right.xPosition;

    // Rieles continuos
    canvas.drawLine(
      Offset(leftX, trackTop),
      Offset(leftX, trackBottom),
      _activeRailPaint,
    );
    canvas.drawLine(
      Offset(leftX, trackTop),
      Offset(leftX, trackBottom),
      _railPaint,
    );

    canvas.drawLine(
      Offset(rightX, trackTop),
      Offset(rightX, trackBottom),
      _activeRailPaint,
    );
    canvas.drawLine(
      Offset(rightX, trackTop),
      Offset(rightX, trackBottom),
      _railPaint,
    );

    // Marcadores rítmicos que se desplazan hacia abajo
    double y = trackTop + scrollOffset;
    while (y < trackBottom) {
      // Ticks en carril izquierdo
      canvas.drawLine(Offset(leftX - 8, y), Offset(leftX + 8, y), _markerPaint);
      // Ticks en carril derecho
      canvas.drawLine(
        Offset(rightX - 8, y),
        Offset(rightX + 8, y),
        _markerPaint,
      );
      y += markerSpacing;
    }
  }
}
