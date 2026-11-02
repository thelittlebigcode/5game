import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Renderizado de las paredes verticales electromagnéticas que guían el túnel de Gravity Courier.
class ShaftWallsComponent extends Component {
  static const double leftWallX = 30.0;
  static const double rightWallX = 420.0;

  final Paint _wallPaint = Paint()
    ..color = ArcadeColors.surfaceBorder
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;

  final Paint _neonGuidePaint = Paint()
    ..color = ArcadeColors.electricAmber.withValues(alpha: 0.5)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  final Paint _gridLinePaint = Paint()
    ..color = ArcadeColors.surfaceBorder.withValues(alpha: 0.3)
    ..strokeWidth = 1.0;

  double _scrollOffset = 0.0;

  void updateScroll(double scrollSpeed, double dt) {
    _scrollOffset = (_scrollOffset + scrollSpeed * dt) % 40.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Líneas principales de las paredes
    canvas.drawLine(
      const Offset(leftWallX, 0),
      const Offset(leftWallX, 800),
      _wallPaint,
    );
    canvas.drawLine(
      const Offset(leftWallX, 0),
      const Offset(leftWallX, 800),
      _neonGuidePaint,
    );

    canvas.drawLine(
      const Offset(rightWallX, 0),
      const Offset(rightWallX, 800),
      _wallPaint,
    );
    canvas.drawLine(
      const Offset(rightWallX, 0),
      const Offset(rightWallX, 800),
      _neonGuidePaint,
    );

    // Marcas de cuadrícula vertical para sensación de velocidad ascendente
    for (double y = -40.0 + _scrollOffset; y < 840.0; y += 40.0) {
      // Pequeñas muescas en pared izquierda
      canvas.drawLine(
        Offset(leftWallX, y),
        Offset(leftWallX + 8, y),
        _gridLinePaint,
      );
      // Pequeñas muescas en pared derecha
      canvas.drawLine(
        Offset(rightWallX, y),
        Offset(rightWallX - 8, y),
        _gridLinePaint,
      );
    }
  }
}
