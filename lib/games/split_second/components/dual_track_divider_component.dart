import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Dibuja la división central y los carriles de las dos pistas independientes de Split Second.
class DualTrackDividerComponent extends Component {
  static const double screenWidth = 450.0;
  static const double screenHeight = 800.0;
  static const double centerDividerX = 225.0;

  final Paint _dividerPaint = Paint()
    ..color = ArcadeColors.flashWhite.withValues(alpha: 0.6)
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  final Paint _outerBorderPaint = Paint()
    ..color = ArcadeColors.surfaceBorder
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  final Paint _sublanePaint = Paint()
    ..color = ArcadeColors.surfaceBorder.withValues(alpha: 0.4)
    ..strokeWidth = 1.0;

  double _dashOffset = 0.0;

  void updateScroll(double speed, double dt) {
    _dashOffset = (_dashOffset + speed * dt) % 30.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Bordes exteriores de la pantalla
    canvas.drawLine(
      const Offset(20, 0),
      const Offset(20, screenHeight),
      _outerBorderPaint,
    );
    canvas.drawLine(
      const Offset(screenWidth - 20, 0),
      const Offset(screenWidth - 20, screenHeight),
      _outerBorderPaint,
    );

    // Divisoria central discontinua brillante
    for (double y = -30.0 + _dashOffset; y < screenHeight + 30.0; y += 30.0) {
      canvas.drawLine(
        Offset(centerDividerX, y),
        Offset(centerDividerX, y + 16.0),
        _dividerPaint,
      );
    }

    // Sub-carriles tenues para ayudar a la lectura visual
    // Pista Izquierda (sub-guías en X=57.5 y X=167.5)
    for (double y = -20.0 + _dashOffset; y < screenHeight + 20.0; y += 20.0) {
      canvas.drawLine(Offset(112.5, y), Offset(112.5, y + 8.0), _sublanePaint);
      canvas.drawLine(Offset(337.5, y), Offset(337.5, y + 8.0), _sublanePaint);
    }
  }
}
