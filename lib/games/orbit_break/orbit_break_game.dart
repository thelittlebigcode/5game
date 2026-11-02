import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart';

import '../../core/audio/arcade_audio_manager.dart';
import '../../core/session/game_session_state.dart';
import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';
import 'components/central_core_component.dart';
import 'components/energy_orb_component.dart';
import 'components/hazard_arc_component.dart';
import 'components/orbital_player_component.dart';
import 'components/particle_system_component.dart';
import 'controllers/orbit_difficulty_controller.dart';

/// Juego 1: Orbit Break
/// Mecánica orbital con inversión de giro por toque o espacio
class OrbitBreakGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  static const String gameId = 'orbit_break';
  static const double orbitRadius = 115.0;

  final LocalPersistenceService storage;

  late final World gameWorld;
  late final CameraComponent gameCamera;

  late final CentralCoreComponent centralCore;
  late final OrbitalPlayerComponent player;
  late final ParticleSystemComponent particles;
  late final OrbitDifficultyController difficultyController;

  GameSessionState sessionState = GameSessionState.ready;

  int score = 0;
  int multiplier = 1;
  int highScore = 0;
  bool isNewRecord = false;

  // Notificadores reactivos para Flutter Overlays
  final void Function(GameSessionState state)? onSessionStateChanged;
  final void Function(int score, int multiplier)? onScoreChanged;

  OrbitBreakGame({
    required this.storage,
    this.onSessionStateChanged,
    this.onScoreChanged,
    int? seed,
  }) {
    difficultyController = OrbitDifficultyController(seed: seed);
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

    centralCore = CentralCoreComponent(orbitRadius: orbitRadius);
    player = OrbitalPlayerComponent(
      orbitRadius: orbitRadius,
      onHitHazard: handleCollisionWithHazard,
      onCollectOrb: handleCollectOrb,
    );
    particles = ParticleSystemComponent();

    await gameWorld.addAll([centralCore, player, particles]);

    await addAll([gameWorld, gameCamera]);
  }

  void onPrimaryAction() {
    if (sessionState == GameSessionState.ready) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      _startGame();
    } else if (sessionState == GameSessionState.playing) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      player.flipDirection();
      // Pequeña estela al cambiar de giro
      particles.spawnBurst(
        x: player.position.x,
        y: player.position.y,
        color: ArcadeColors.player,
        count: 6,
        minSpeed: 30,
        maxSpeed: 80,
        lifeTime: 0.25,
      );
    } else if (sessionState == GameSessionState.finished) {
      restartGame();
    }
  }

  void onPauseAction() {
    if (sessionState == GameSessionState.playing) {
      pauseGame();
    } else if (sessionState == GameSessionState.paused) {
      resumeGame();
    }
  }

  void _startGame() {
    sessionState = GameSessionState.playing;
    onSessionStateChanged?.call(sessionState);
  }

  void pauseGame() {
    if (sessionState != GameSessionState.playing) return;
    sessionState = GameSessionState.paused;
    pauseEngine();
    onSessionStateChanged?.call(sessionState);
  }

  void resumeGame() {
    if (sessionState != GameSessionState.paused) return;
    sessionState = GameSessionState.playing;
    resumeEngine();
    onSessionStateChanged?.call(sessionState);
  }

  void handleCollisionWithHazard() {
    if (sessionState != GameSessionState.playing) return;

    ArcadeAudioManager().play(ArcadeSfx.gameOver);

    // Efecto de explosión de fin de partida
    particles.spawnBurst(
      x: player.position.x,
      y: player.position.y,
      color: ArcadeColors.hazard,
      count: 28,
      minSpeed: 70,
      maxSpeed: 250,
      particleSize: 4.5,
      lifeTime: 0.8,
    );

    sessionState = GameSessionState.finished;

    // Comprobar y guardar récord
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

  void handleCollectOrb(EnergyOrbComponent orb) {
    if (sessionState != GameSessionState.playing || orb.isCollected) return;
    orb.isCollected = true;

    ArcadeAudioManager().play(ArcadeSfx.collectItem);

    // Destello de partículas del orbe
    particles.spawnBurst(
      x: orb.position.x,
      y: orb.position.y,
      color: ArcadeColors.collectible,
      count: 14,
      minSpeed: 40,
      maxSpeed: 140,
      lifeTime: 0.45,
    );

    score += 10 * multiplier;
    multiplier = (multiplier + 1).clamp(1, 5);
    onScoreChanged?.call(score, multiplier);

    orb.removeFromParent();
  }

  void restartGame() {
    score = 0;
    multiplier = 1;
    isNewRecord = false;
    highScore = storage.getHighScore(gameId);

    // Limpiar entidades generadas
    final hazards = gameWorld.children.whereType<HazardArcComponent>().toList();
    for (final h in hazards) {
      h.removeFromParent();
    }
    final orbs = gameWorld.children.whereType<EnergyOrbComponent>().toList();
    for (final o in orbs) {
      o.removeFromParent();
    }
    particles.clear();

    player.reset();
    difficultyController.reset();

    sessionState = GameSessionState.ready;
    resumeEngine();
    onScoreChanged?.call(score, multiplier);
    onSessionStateChanged?.call(sessionState);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (sessionState != GameSessionState.playing) return;

    // Actualizar velocidad según la curva
    player.angularSpeed = difficultyController.currentAngularSpeed;

    difficultyController.update(
      dt,
      onSpawnHazard: (angle, sweepAngle) {
        gameWorld.add(
          HazardArcComponent(
            orbitRadius: orbitRadius,
            spawnAngle: angle,
            sweepAngle: sweepAngle,
          ),
        );
      },
      onSpawnOrb: (angle) {
        gameWorld.add(
          EnergyOrbComponent(orbitRadius: orbitRadius, orbAngle: angle),
        );
      },
    );
  }

  // --- Entrada de Usuario ---
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onPrimaryAction();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        onPrimaryAction();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        onPauseAction();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
