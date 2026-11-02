import 'dart:math' as math;

import '../components/barrier_component.dart';
import '../models/lane.dart';

/// Controlador de dificultad, velocidad y generación procedimental de obstáculos en Pulse Shift.
/// Conforme a ETAPAS.md (Etapas 3.1, 3.3, 3.4 y 3.6).
class PulseShiftController {
  static const double baseSpeed = 260.0;
  static const double maxSpeed = 520.0;
  static const double accelerationRate = 4.0; // Píxeles/s ganados por segundo

  final math.Random random;

  double elapsedTime = 0.0;
  double _spawnTimer = 0.0;
  double _currentInterval = 1.0;

  Lane _lastBarrierLane = Lane.left;

  PulseShiftController({int? seed}) : random = math.Random(seed);

  double get currentSpeed {
    final speed = baseSpeed + accelerationRate * elapsedTime;
    return math.min(speed, maxSpeed);
  }

  void update(
    double dt, {
    required void Function(Lane lane, BarrierType type) onSpawnBarrier,
    required void Function(Lane lane) onSpawnOrb,
  }) {
    elapsedTime += dt;
    _spawnTimer += dt;

    // El intervalo se reduce progresivamente conforme la velocidad aumenta,
    // garantizando una separación espacial segura entre obstáculos (~240 a 270 px)
    _currentInterval = 260.0 / currentSpeed;

    if (_spawnTimer >= _currentInterval) {
      _spawnTimer = 0.0;
      _spawnPattern(onSpawnBarrier, onSpawnOrb);
    }
  }

  void _spawnPattern(
    void Function(Lane lane, BarrierType type) onSpawnBarrier,
    void Function(Lane lane) onSpawnOrb,
  ) {
    // Decidir carril de la barrera (alternar frecuentemente o aleatorizar)
    final roll = random.nextDouble();
    Lane barrierLane;
    if (roll < 0.6) {
      barrierLane = _lastBarrierLane.opposite;
    } else {
      barrierLane = _lastBarrierLane;
    }
    _lastBarrierLane = barrierLane;

    // Determinar si es barrera fija o compuerta de fase dinámica (después de 10s)
    final isPhaseGate = elapsedTime > 10.0 && random.nextDouble() < 0.35;
    final barrierType = isPhaseGate ? BarrierType.phaseGate : BarrierType.fixed;

    onSpawnBarrier(barrierLane, barrierType);

    // Recompensa en carril opuesto para premiar reflejos (65% de probabilidad)
    if (random.nextDouble() < 0.65) {
      final orbLane = barrierLane.opposite;
      onSpawnOrb(orbLane);
    }
  }

  void reset() {
    elapsedTime = 0.0;
    _spawnTimer = 0.0;
    _currentInterval = 1.0;
    _lastBarrierLane = Lane.left;
  }
}
