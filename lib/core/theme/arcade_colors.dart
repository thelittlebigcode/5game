import 'package:flutter/material.dart';

/// Tokens de diseño y paleta retro arcade vectorial.
/// Conforme a ETAPAS.md y .agents/skills/arcade-ui-ux-design/SKILL.md
class ArcadeColors {
  const ArcadeColors._();

  // Fondo y superficies
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF14141E);
  static const Color surfaceBorder = Color(0xFF232338);

  // Paleta Neón Vectorial
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonCyan = Color(0xFF00F5D4);
  static const Color arcadeMagenta = Color(0xFFFF007F);
  static const Color electricAmber = Color(0xFFFFB703);
  static const Color flashWhite = Color(0xFFFFFFFF);

  // Semántica
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color hazard = Color(0xFFFF007F);
  static const Color collectible = Color(0xFFFFB703);
  static const Color player = Color(0xFF00F5D4);
}

/// Definición del tema minimalista de alto contraste
class ArcadeTheme {
  const ArcadeTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ArcadeColors.background,
      fontFamily: 'monospace',
      colorScheme: const ColorScheme.dark(
        primary: ArcadeColors.neonCyan,
        secondary: ArcadeColors.arcadeMagenta,
        surface: ArcadeColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ArcadeColors.background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
