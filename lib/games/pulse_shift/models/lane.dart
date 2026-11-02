import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Carriles de desplazamiento vertical en Pulse Shift.
/// Conforme a ETAPAS.md (Etapas 3.1 y 3.2).
enum Lane { left, right }

extension LaneExtension on Lane {
  double get xPosition => this == Lane.left ? -75.0 : 75.0;

  Lane get opposite => this == Lane.left ? Lane.right : Lane.left;

  Color get primaryColor =>
      this == Lane.left ? ArcadeColors.arcadeMagenta : ArcadeColors.neonCyan;

  Color get glowColor => primaryColor.withValues(alpha: 0.35);
}
