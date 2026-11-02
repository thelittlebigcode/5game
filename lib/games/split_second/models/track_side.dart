import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Define una de las dos vías divididas verticalmente en Split Second.
enum TrackSide {
  leftTrack,
  rightTrack;

  /// Centro en el eje X de cada pista.
  /// Pantalla de 450px de ancho dividida al centro (225px):
  /// - Pista izquierda: 0 a 225px (centro en 112.5px)
  /// - Pista derecha: 225 a 450px (centro en 337.5px)
  double get centerX => this == TrackSide.leftTrack ? 112.5 : 337.5;

  /// Posición relativa del carril izquierdo o derecho dentro de la propia pista.
  /// Offset de +/- 55px desde el centro de la pista.
  double laneX(bool isInner) {
    if (this == TrackSide.leftTrack) {
      // isInner (true) = cerca de la divisoria central (hacia la derecha)
      // isInner (false) = exterior (hacia la izquierda)
      return isInner ? (centerX + 55.0) : (centerX - 55.0);
    } else {
      // isInner (true) = cerca de la divisoria central (hacia la izquierda)
      // isInner (false) = exterior (hacia la derecha)
      return isInner ? (centerX - 55.0) : (centerX + 55.0);
    }
  }

  Color get primaryColor => this == TrackSide.leftTrack
      ? ArcadeColors.neonCyan
      : ArcadeColors.arcadeMagenta;
}
