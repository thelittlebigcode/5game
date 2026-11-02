import 'dart:math' as math;

/// Controlador determinista de dificultad y generación para Orbit Break
class OrbitDifficultyController {
  final math.Random random;

  double elapsedTime = 0.0;
  static const double baseSpeed = 2.4; // rad/s
  static const double maxSpeed = 5.2; // rad/s
  static const double accelerationRate = 0.045; // rad/s por segundo

  double _timeSinceLastHazard = 0.0;
  double _timeSinceLastOrb = 0.0;

  OrbitDifficultyController({int? seed}) : random = math.Random(seed);

  /// Velocidad angular actual en radianes por segundo
  double get currentAngularSpeed {
    return (baseSpeed + accelerationRate * elapsedTime).clamp(
      baseSpeed,
      maxSpeed,
    );
  }

  /// Intervalo dinámico de aparición de obstáculos
  double get currentHazardInterval {
    // Intervalo decrece de 2.2s a 1.1s con el tiempo
    final factor = (1.0 - (elapsedTime / 90.0)).clamp(0.0, 1.0);
    return 1.1 + factor * 1.1 + random.nextDouble() * 0.4;
  }

  /// Intervalo dinámico de orbes
  double get currentOrbInterval {
    return 1.4 + random.nextDouble() * 1.0;
  }

  void update(
    double dt, {
    required void Function(double angle, double sweepAngle) onSpawnHazard,
    required void Function(double angle) onSpawnOrb,
  }) {
    elapsedTime += dt;
    _timeSinceLastHazard += dt;
    _timeSinceLastOrb += dt;

    if (_timeSinceLastHazard >= currentHazardInterval) {
      _timeSinceLastHazard = 0.0;
      final spawnAngle = random.nextDouble() * 2 * math.pi;
      // Barrido del obstáculo entre 0.45 y 0.8 rad
      final sweepAngle = 0.45 + random.nextDouble() * 0.35;
      onSpawnHazard(spawnAngle, sweepAngle);
    }

    if (_timeSinceLastOrb >= currentOrbInterval) {
      _timeSinceLastOrb = 0.0;
      final spawnAngle = random.nextDouble() * 2 * math.pi;
      onSpawnOrb(spawnAngle);
    }
  }

  void reset() {
    elapsedTime = 0.0;
    _timeSinceLastHazard = 0.0;
    _timeSinceLastOrb = 0.0;
  }
}
