import 'dart:math' as math;

import 'package:flame/components.dart' hide ParticleSystemComponent;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart';

import '../../core/audio/arcade_audio_manager.dart';
import '../../core/session/game_session_state.dart';
import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';
import 'components/cargo_module_component.dart';
import 'components/courier_hazard_component.dart';
import 'components/courier_player_component.dart';
import 'components/particle_system_component.dart';
import 'components/shaft_walls_component.dart';
import 'controllers/gravity_courier_controller.dart';

/// Juego 4: Gravity Courier
/// Desplazamiento vertical continuo alternando gravedad entre dos paredes con opción de carga.
/// Conforme a ETAPAS.md (Etapas 4.1 a 4.6).
class GravityCourierGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  static const String gameId = 'gravity_courier';

  final LocalPersistenceService storage;

  late final World gameWorld;
  late final CameraComponent gameCamera;

  late final ShaftWallsComponent walls;
  late final CourierPlayerComponent player;
  late final ParticleSystemComponent particles;
  late final GravityCourierController controller;

  GameSessionState sessionState = GameSessionState.ready;

  int score = 0;
  double _rawDistanceScore = 0.0;
  int cargoBonus = 0;
  int multiplier = 1;
  int highScore = 0;
  bool isNewRecord = false;

  // Sacudida de pantalla sutil al colisionar
  double _screenShakeTimer = 0.0;
  static const double maxShakeDuration = 0.28;

  final void Function(GameSessionState state)? onSessionStateChanged;
  final void Function(int score, int multiplier)? onScoreChanged;

  GravityCourierGame({
    required this.storage,
    this.onSessionStateChanged,
    this.onScoreChanged,
    int? seed,
  }) {
    controller = GravityCourierController(seed: seed);
  }

  @override
  Color backgroundColor() => ArcadeColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    highScore = storage.getHighScore(gameId);

    gameWorld = World();
    gameCamera = CameraComponent.withFixedResolution(
      width: 450,
      height: 800,
      world: gameWorld,
    );

    walls = ShaftWallsComponent();
    player = CourierPlayerComponent(
      onHitHazard: handleCollisionWithHazard,
      onCollectCargo: handleCollectCargo,
    );
    particles = ParticleSystemComponent();

    await gameWorld.addAll([walls, player, particles]);
    await addAll([gameWorld, gameCamera]);
  }

  void onPrimaryAction() {
    if (sessionState == GameSessionState.ready) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      _startGame();
    } else if (sessionState == GameSessionState.playing) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      final oldX = player.position.x;
      player.toggleGravity();

      // Destello y estela de partículas al activar impulso gravitatorio
      particles.spawnBurst(
        x: oldX,
        y: player.position.y,
        color: ArcadeColors.electricAmber,
        count: 12,
        minSpeed: 40,
        maxSpeed: 150,
        particleSize: 3.0,
        lifeTime: 0.35,
      );
    }
  }

  void _startGame() {
    sessionState = GameSessionState.playing;
    onSessionStateChanged?.call(sessionState);
  }

  void pauseGame() {
    if (sessionState == GameSessionState.playing) {
      sessionState = GameSessionState.paused;
      pauseEngine();
      onSessionStateChanged?.call(sessionState);
    }
  }

  void resumeGame() {
    if (sessionState == GameSessionState.paused) {
      sessionState = GameSessionState.playing;
      resumeEngine();
      onSessionStateChanged?.call(sessionState);
    }
  }

  void handleCollisionWithHazard(CourierHazardComponent hazard) {
    if (sessionState != GameSessionState.playing) return;

    ArcadeAudioManager().play(ArcadeSfx.gameOver);

    // Detener simulación de juego activo
    _screenShakeTimer = maxShakeDuration;

    // Gran explosión vectorial de partículas
    particles.spawnBurst(
      x: player.position.x,
      y: player.position.y,
      color: ArcadeColors.hazard,
      count: 34,
      minSpeed: 90,
      maxSpeed: 280,
      particleSize: 4.5,
      lifeTime: 0.8,
    );

    // Chispas del chasis
    particles.spawnBurst(
      x: player.position.x,
      y: player.position.y,
      color: ArcadeColors.neonCyan,
      count: 18,
      minSpeed: 60,
      maxSpeed: 180,
      particleSize: 3.0,
      lifeTime: 0.5,
    );

    sessionState = GameSessionState.finished;

    if (score > highScore) {
      highScore = score;
      isNewRecord = true;
      storage.saveHighScore(gameId, score);
      ArcadeAudioManager().play(ArcadeSfx.newHighScore);
    } else {
      isNewRecord = false;
    }

    onSessionStateChanged?.call(sessionState);
  }

  void handleCollectCargo(CargoModuleComponent cargo) {
    if (sessionState != GameSessionState.playing) return;
    if (cargo.isCollected) return;
    cargo.isCollected = true;

    ArcadeAudioManager().play(ArcadeSfx.collectItem);

    player.addCargo();
    multiplier = math.min(4, multiplier + 1);

    // Destello de recolección de carga
    particles.spawnBurst(
      x: cargo.position.x,
      y: cargo.position.y,
      color: ArcadeColors.electricAmber,
      count: 18,
      minSpeed: 50,
      maxSpeed: 160,
      particleSize: 3.5,
      lifeTime: 0.5,
    );

    cargoBonus += 50 * multiplier;
    _updateTotalScore();
    cargo.removeFromParent();
  }

  void _updateTotalScore() {
    score = (_rawDistanceScore + cargoBonus).round();
    onScoreChanged?.call(score, multiplier);
  }

  void restartGame() {
    score = 0;
    _rawDistanceScore = 0.0;
    cargoBonus = 0;
    multiplier = 1;
    isNewRecord = false;
    highScore = storage.getHighScore(gameId);

    // Limpiar entidades activas en el mundo
    final hazards = gameWorld.children
        .whereType<CourierHazardComponent>()
        .toList();
    for (final h in hazards) {
      h.removeFromParent();
    }

    final cargos = gameWorld.children
        .whereType<CargoModuleComponent>()
        .toList();
    for (final c in cargos) {
      c.removeFromParent();
    }

    particles.clear();
    player.reset();
    controller.reset();
    _screenShakeTimer = 0.0;
    gameCamera.viewfinder.position = Vector2.zero();

    sessionState = GameSessionState.ready;
    resumeEngine();
    onScoreChanged?.call(score, multiplier);
    onSessionStateChanged?.call(sessionState);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (sessionState != GameSessionState.playing) return;

    // Actualizar controlador y desplazamiento vertical
    controller.update(dt);
    final speed = controller.currentScrollSpeed;
    walls.updateScroll(speed, dt);

    // Puntuación continua por distancia recorrida
    _rawDistanceScore += (speed * 0.05) * dt * multiplier;
    _updateTotalScore();

    // Mover obstáculos hacia abajo
    final hazards = gameWorld.children
        .whereType<CourierHazardComponent>()
        .toList();
    for (final hazard in hazards) {
      hazard.position.y += speed * dt;
      if (hazard.position.y > 850) {
        hazard.removeFromParent();
      }
    }

    // Mover cargas hacia abajo
    final cargos = gameWorld.children
        .whereType<CargoModuleComponent>()
        .toList();
    for (final cargo in cargos) {
      cargo.position.y += speed * dt;
      if (cargo.position.y > 850) {
        cargo.removeFromParent();
      }
    }

    // Spawning procedimental de obstáculos
    final newHazards = controller.checkHazardSpawns(dt);
    for (final config in newHazards) {
      final hazard = CourierHazardComponent(
        hazardType: config.type,
        wallSide: config.wallSide,
        position: Vector2(config.x, config.y),
        size: Vector2(config.width, config.height),
        maxGateWidth: config.maxGateWidth,
      );
      gameWorld.add(hazard);
    }

    // Spawning de cargas
    final cargoConfig = controller.checkCargoSpawn(dt);
    if (cargoConfig != null) {
      final cargo = CargoModuleComponent(
        position: Vector2(cargoConfig.x, cargoConfig.y),
      );
      gameWorld.add(cargo);
    }

    // Sacudida de cámara sutil si está activa
    if (_screenShakeTimer > 0) {
      _screenShakeTimer -= dt;
      final shakeProgress = _screenShakeTimer / maxShakeDuration;
      final offset = math.sin(_screenShakeTimer * 60) * 5.0 * shakeProgress;
      gameCamera.viewfinder.position = Vector2(offset, 0);
      if (_screenShakeTimer <= 0) {
        gameCamera.viewfinder.position = Vector2.zero();
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        onPrimaryAction();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (sessionState == GameSessionState.playing) {
          pauseGame();
          return KeyEventResult.handled;
        } else if (sessionState == GameSessionState.paused) {
          resumeGame();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPrimaryAction();
  }
}
