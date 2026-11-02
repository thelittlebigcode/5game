import 'dart:math' as math;

import 'block_type.dart';

/// Resultado del cálculo matemático de solapamiento y recorte en Perfect Drop.
/// Conforme a ETAPAS.md (Etapas 2.2, 2.3 y 2.5).
class DropSliceResult {
  final bool isPerfect;
  final bool isMiss;
  final double placedCenterX;
  final double placedWidth;
  final double? overhangCenterX;
  final double? overhangWidth;
  final bool isOverhangOnRight;
  final int combo;
  final int pointsAwarded;

  const DropSliceResult({
    required this.isPerfect,
    required this.isMiss,
    required this.placedCenterX,
    required this.placedWidth,
    this.overhangCenterX,
    this.overhangWidth,
    this.isOverhangOnRight = true,
    required this.combo,
    required this.pointsAwarded,
  });
}

/// Calculador determinista y desacoplado del algoritmo de recorte y precisión.
class SliceCalculator {
  static const double baseBlockWidth = 200.0;
  static const double minSurvivingWidth = 8.0;

  /// Calcula el recorte o la precisión milimétrica al soltar una plataforma móvil sobre la cima.
  static DropSliceResult calculate({
    required double movingCenterX,
    required double movingWidth,
    required double targetCenterX,
    required double targetWidth,
    required BlockType blockType,
    required int currentCombo,
    double maxWidth = 200.0,
  }) {
    final offset = movingCenterX - targetCenterX;
    final absOffset = offset.abs();
    final tolerance = blockType.perfectTolerance;

    // 1. Detección de alineación milimétrica ("Perfect Drop")
    if (absOffset <= tolerance) {
      final newCombo = currentCombo + 1;

      // Recompensa acumulativa de precisión: si encadena combos (múltiplo de 3),
      // se devuelve un poco de ancho perdido hasta un máximo.
      double newWidth = targetWidth;
      if (newCombo % 3 == 0 && newWidth < maxWidth) {
        newWidth = math.min(maxWidth, newWidth + 10.0);
      }

      // Multiplicador acumulativo por combo
      final points = (blockType.scoreBonus * (1 + newCombo * 0.5)).round();

      return DropSliceResult(
        isPerfect: true,
        isMiss: false,
        placedCenterX: targetCenterX, // Auto-alineación al centro
        placedWidth: newWidth,
        overhangCenterX: null,
        overhangWidth: null,
        combo: newCombo,
        pointsAwarded: points,
      );
    }

    // 2. Límites espaciales de cada plataforma
    final movingLeft = movingCenterX - movingWidth / 2;
    final movingRight = movingCenterX + movingWidth / 2;
    final targetLeft = targetCenterX - targetWidth / 2;
    final targetRight = targetCenterX + targetWidth / 2;

    final overlapLeft = math.max(movingLeft, targetLeft);
    final overlapRight = math.min(movingRight, targetRight);
    final overlapWidth = overlapRight - overlapLeft;

    // 3. Condición de derrota / fallo completo
    if (overlapWidth < minSurvivingWidth) {
      return DropSliceResult(
        isPerfect: false,
        isMiss: true,
        placedCenterX: movingCenterX,
        placedWidth: 0,
        overhangCenterX: movingCenterX,
        overhangWidth: movingWidth,
        isOverhangOnRight: offset > 0,
        combo: 0,
        pointsAwarded: 0,
      );
    }

    // 4. Fragmento sobrante desalineado (overhang)
    final bool isRight = movingCenterX > targetCenterX;
    double overhangW;
    double overhangX;

    if (isRight) {
      overhangW = movingRight - overlapRight;
      overhangX = overlapRight + overhangW / 2;
    } else {
      overhangW = overlapLeft - movingLeft;
      overhangX = movingLeft + overhangW / 2;
    }

    final newCenterX = (overlapLeft + overlapRight) / 2;

    return DropSliceResult(
      isPerfect: false,
      isMiss: false,
      placedCenterX: newCenterX,
      placedWidth: overlapWidth,
      overhangCenterX: overhangW > 0.5 ? overhangX : null,
      overhangWidth: overhangW > 0.5 ? overhangW : null,
      isOverhangOnRight: isRight,
      combo: 0, // El combo se rompe al recortar
      pointsAwarded: blockType.scoreBonus,
    );
  }
}
