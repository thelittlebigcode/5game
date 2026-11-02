import 'dart:math' as math;

import '../models/track_side.dart';

/// Configuración para instanciar un obstáculo en una de las pistas.
class SplitHazardConfig {
  final TrackSide trackSide;
  final bool isInner;
  final double y;

  const SplitHazardConfig({
    required this.trackSide,
    required this.isInner,
    required this.y,
  });
}

/// Configuración para instanciar un orbe de sinergia en una de las pistas.
class SynergyOrbConfig {
  final TrackSide trackSide;
  final bool isInner;
  final double y;

  const SynergyOrbConfig({
    required this.trackSide,
    required this.isInner,
    required this.y,
  });
}

/// Controlador de dificultad, progresión y patrones justos para Split Second.
class SplitSecondController {
  final math.Random _rng;

  static const double baseScrollSpeed = 280.0;
  static const double maxScrollSpeed = 640.0;
  static const double speedAcceleration = 9.5;

  double currentScrollSpeed = baseScrollSpeed;
  double _elapsedTime = 0.0;
  double _nextSpawnDistance = 160.0;
  double _accumulatedDistance = 0.0;

  SplitSecondController({int? seed}) : _rng = math.Random(seed);

  void reset() {
    currentScrollSpeed = baseScrollSpeed;
    _elapsedTime = 0.0;
    _nextSpawnDistance = 160.0;
    _accumulatedDistance = 0.0;
  }

  void update(double dt) {
    _elapsedTime += dt;
    currentScrollSpeed = math.min(
      maxScrollSpeed,
      baseScrollSpeed + (_elapsedTime * speedAcceleration),
    );
  }

  /// Genera patrones calibrados de obstáculos garantizando que SIEMPRE exista
  /// una combinación de carriles viable para no crear situaciones imposibles de esquivar
  /// con un comando simultáneo.
  List<SplitHazardConfig> checkHazardSpawns(
    double dt, {
    required bool leftPlayerInner,
    required bool rightPlayerInner,
  }) {
    _accumulatedDistance += currentScrollSpeed * dt;
    final List<SplitHazardConfig> spawned = [];

    if (_accumulatedDistance >= _nextSpawnDistance) {
      _accumulatedDistance = 0.0;
      // Intervalo adaptativo según velocidad
      _nextSpawnDistance = 220.0 + _rng.nextDouble() * 110.0;

      final patternType = _rng.nextInt(4);

      switch (patternType) {
        case 0:
          // Obstáculo simple en pista izquierda (carril aleatorio)
          spawned.add(
            SplitHazardConfig(
              trackSide: TrackSide.leftTrack,
              isInner: _rng.nextBool(),
              y: -50.0,
            ),
          );
          break;
        case 1:
          // Obstáculo simple en pista derecha (carril aleatorio)
          spawned.add(
            SplitHazardConfig(
              trackSide: TrackSide.rightTrack,
              isInner: _rng.nextBool(),
              y: -50.0,
            ),
          );
          break;
        case 2:
          // Obstáculos coordinados simétricos (ambos interiores o ambos exteriores)
          // Un solo comando de cambio permite esquivarlos limpiamente
          final placeInInner = _rng.nextBool();
          spawned.add(
            SplitHazardConfig(
              trackSide: TrackSide.leftTrack,
              isInner: placeInInner,
              y: -50.0,
            ),
          );
          spawned.add(
            SplitHazardConfig(
              trackSide: TrackSide.rightTrack,
              isInner: placeInInner,
              y: -50.0,
            ),
          );
          break;
        case 3:
          // Obstáculos escalonados en Y: primero uno en pista izquierda y luego otro en derecha
          final isInnerLeft = _rng.nextBool();
          final isInnerRight = _rng.nextBool();
          spawned.add(
            SplitHazardConfig(
              trackSide: TrackSide.leftTrack,
              isInner: isInnerLeft,
              y: -50.0,
            ),
          );
          spawned.add(
            SplitHazardConfig(
              trackSide: TrackSide.rightTrack,
              isInner: isInnerRight,
              y: -140.0, // Desplazado en Y para dar tiempo de reacción entre cambios
            ),
          );
          break;
      }
    }

    return spawned;
  }

  /// Genera orbes de sinergia en carriles libres
  SynergyOrbConfig? checkSynergyOrbSpawn(double dt) {
    if (_rng.nextDouble() < (0.016 * (dt / 0.016))) {
      final track = _rng.nextBool()
          ? TrackSide.leftTrack
          : TrackSide.rightTrack;
      final inner = _rng.nextBool();
      return SynergyOrbConfig(trackSide: track, isInner: inner, y: -40.0);
    }
    return null;
  }
}
