import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Tipos de bloques para la progresión de Perfect Drop.
/// Conforme a ETAPAS.md (Etapa 2.4).
enum BlockType {
  standard, // Bloque estándar equilibrado (Neon Green)
  speedy, // Bloque veloz y dinámico (Flash White) - mayor desafío y puntaje
  heavy, // Bloque pesado y ancho (Electric Amber) - más lento, mayor tolerancia
  elastic, // Bloque elástico oscilante (Arcade Magenta) - movimiento reactivo armónico
}

extension BlockTypeExtension on BlockType {
  String get displayName {
    switch (this) {
      case BlockType.standard:
        return 'ESTÁNDAR';
      case BlockType.speedy:
        return 'VELOZ';
      case BlockType.heavy:
        return 'PESADO';
      case BlockType.elastic:
        return 'ELÁSTICO';
    }
  }

  Color get color {
    switch (this) {
      case BlockType.standard:
        return ArcadeColors.neonGreen;
      case BlockType.speedy:
        return ArcadeColors.flashWhite;
      case BlockType.heavy:
        return ArcadeColors.electricAmber;
      case BlockType.elastic:
        return ArcadeColors.arcadeMagenta;
    }
  }

  double get speedMultiplier {
    switch (this) {
      case BlockType.standard:
        return 1.0;
      case BlockType.speedy:
        return 1.35;
      case BlockType.heavy:
        return 0.8;
      case BlockType.elastic:
        return 1.1;
    }
  }

  double get perfectTolerance {
    switch (this) {
      case BlockType.standard:
        return 3.0;
      case BlockType.speedy:
        return 2.0;
      case BlockType.heavy:
        return 4.5;
      case BlockType.elastic:
        return 2.5;
    }
  }

  int get scoreBonus {
    switch (this) {
      case BlockType.standard:
        return 10;
      case BlockType.speedy:
        return 25;
      case BlockType.heavy:
        return 15;
      case BlockType.elastic:
        return 20;
    }
  }
}
