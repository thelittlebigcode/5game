import 'dart:math' as math;

import '../models/block_type.dart';

/// Controlador de progresión de dificultad, velocidad y generación de bloques.
/// Conforme a ETAPAS.md y .agents/skills/gameplay-balancing-and-qa/SKILL.md
class PerfectDropController {
  static const double baseSpeed = 160.0;
  static const double speedIncrementPerBlock = 7.0;
  static const double maxSpeed = 380.0;

  final math.Random random;

  int towerHeight = 0;
  int combo = 0;

  PerfectDropController({int? seed}) : random = math.Random(seed);

  /// Velocidad base calculada según la altura actual de la torre.
  double get currentBaseSpeed {
    final speed = baseSpeed + towerHeight * speedIncrementPerBlock;
    return math.min(speed, maxSpeed);
  }

  /// Calcula la velocidad final para un bloque específico.
  double speedForBlock(BlockType type) {
    return currentBaseSpeed * type.speedMultiplier;
  }

  /// Selecciona el siguiente tipo de bloque de manera progresiva y determinista.
  BlockType nextBlockType() {
    // Primeros 3 bloques siempre son estándar para permitir al jugador aclimatarse
    if (towerHeight < 3) {
      return BlockType.standard;
    }

    final roll = random.nextDouble();
    if (towerHeight < 7) {
      // Progresión inicial: estándar y veloz
      if (roll < 0.65) return BlockType.standard;
      return BlockType.speedy;
    } else if (towerHeight < 12) {
      // Progresión intermedia: introduce pesado
      if (roll < 0.45) return BlockType.standard;
      if (roll < 0.75) return BlockType.speedy;
      return BlockType.heavy;
    } else {
      // Progresión avanzada: mezcla completa con bloques elásticos
      if (roll < 0.35) return BlockType.standard;
      if (roll < 0.60) return BlockType.speedy;
      if (roll < 0.80) return BlockType.elastic;
      return BlockType.heavy;
    }
  }

  void incrementHeight() {
    towerHeight++;
  }

  void updateCombo(int newCombo) {
    combo = newCombo;
  }

  void reset() {
    towerHeight = 0;
    combo = 0;
  }
}
