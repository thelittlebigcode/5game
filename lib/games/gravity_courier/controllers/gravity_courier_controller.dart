import 'dart:math' as math;

import '../models/wall_side.dart';
import '../components/courier_hazard_component.dart';

/// Descriptor para generar un obstáculo en el flujo procedimental.
class HazardSpawnConfig {
  final HazardType type;
  final WallSide? wallSide;
  final double x;
  final double y;
  final double width;
  final double height;
  final double maxGateWidth;

  const HazardSpawnConfig({
    required this.type,
    this.wallSide,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.maxGateWidth = 140.0,
  });
}

/// Descriptor para generar un módulo de carga en el flujo procedimental.
class CargoSpawnConfig {
  final double x;
  final double y;

  const CargoSpawnConfig({required this.x, required this.y});
}

/// Controlador de dificultad, progresión vertical y generación procedimental para Gravity Courier.
class GravityCourierController {
  final math.Random _rng;

  static const double baseScrollSpeed = 260.0;
  static const double maxScrollSpeed = 620.0;
  static const double speedAcceleration = 9.0; // px/s acumulados por segundo

  double currentScrollSpeed = baseScrollSpeed;
  double _elapsedTime = 0.0;
  double _nextSpawnDistance = 180.0;
  double _accumulatedDistance = 0.0;

  GravityCourierController({int? seed}) : _rng = math.Random(seed);

  void reset() {
    currentScrollSpeed = baseScrollSpeed;
    _elapsedTime = 0.0;
    _nextSpawnDistance = 180.0;
    _accumulatedDistance = 0.0;
  }

  void update(double dt) {
    _elapsedTime += dt;
    currentScrollSpeed = math.min(
      maxScrollSpeed,
      baseScrollSpeed + (_elapsedTime * speedAcceleration),
    );
  }

  /// Verifica si toca instanciar nuevos elementos en la coordenada Y superior (-60.0).
  List<HazardSpawnConfig> checkHazardSpawns(double dt) {
    _accumulatedDistance += currentScrollSpeed * dt;
    final List<HazardSpawnConfig> spawned = [];

    if (_accumulatedDistance >= _nextSpawnDistance) {
      _accumulatedDistance = 0.0;
      // Intervalo entre obstáculos según velocidad
      _nextSpawnDistance = 240.0 + _rng.nextDouble() * 120.0;

      final roll = _rng.nextDouble();

      if (roll < 0.45) {
        // Picos en pared izquierda o derecha
        final side = _rng.nextBool() ? WallSide.left : WallSide.right;
        final h = 60.0 + _rng.nextDouble() * 40.0;
        final w = 26.0;
        final x = side == WallSide.left ? 30.0 : (420.0 - w);

        spawned.add(
          HazardSpawnConfig(
            type: HazardType.wallSpikes,
            wallSide: side,
            x: x,
            y: -80.0,
            width: w,
            height: h,
          ),
        );
      } else if (roll < 0.75) {
        // Barrera láser transversal flotante en el centro o desfasada
        final barWidth = 140.0 + _rng.nextDouble() * 60.0;
        final minX = 30.0 + 30.0;
        final maxX = 420.0 - barWidth - 30.0;
        final x = minX + _rng.nextDouble() * (maxX - minX);

        spawned.add(
          HazardSpawnConfig(
            type: HazardType.laserBarrier,
            x: x,
            y: -40.0,
            width: barWidth,
            height: 14.0,
          ),
        );
      } else {
        // Compuerta móvil oscilante anclada a una de las paredes
        final side = _rng.nextBool() ? WallSide.left : WallSide.right;
        final maxW = 120.0 + _rng.nextDouble() * 40.0;
        final x = side == WallSide.left ? 30.0 : (420.0 - 30.0);

        spawned.add(
          HazardSpawnConfig(
            type: HazardType.movingGate,
            wallSide: side,
            x: x,
            y: -50.0,
            width: 30.0,
            height: 22.0,
            maxGateWidth: maxW,
          ),
        );
      }
    }

    return spawned;
  }

  /// Ocasionalmente genera un módulo de carga coleccionable
  CargoSpawnConfig? checkCargoSpawn(double dt) {
    if (_rng.nextDouble() < (0.015 * (dt / 0.016))) {
      // Posición central para incentivar cruce arriesgado
      final x = 120.0 + _rng.nextDouble() * 210.0;
      return CargoSpawnConfig(x: x, y: -40.0);
    }
    return null;
  }
}
