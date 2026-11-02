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
import 'components/barrier_component.dart';
import 'components/energy_orb_component.dart';
import 'components/lane_track_component.dart';
import 'components/particle_system_component.dart';
import 'components/pulse_player_component.dart';
import 'controllers/pulse_shift_controller.dart';
import 'models/lane.dart';

/// Juego 3: Pulse Shift
/// Runner vertical vertiginoso de dos carriles con reactividad al cambio de fase.
/// Conforme a ETAPAS.md (Etapas 3.1 a 3.6).
class PulseShiftGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  static const String gameId = 'pulse_shift';

  final LocalPersistenceService storage;

  late final World gameWorld;
  late final CameraComponent gameCamera;

  late final LaneTrackComponent track;
  late final PulsePlayerComponent player;
  late final ParticleSystemComponent particles;
  late final PulseShiftController controller;

  GameSessionState sessionState = GameSessionState.ready;

  int score = 0;
  double _rawScore = 0.0;
  int multiplier = 1;
  int highScore = 0;
  bool isNewRecord = false;

  // Sacudida de pantalla sutil al colisionar
  double _screenShakeTimer = 0.0;
  static const double maxShakeDuration = 0.28;

  final void Function(GameSessionState state)? onSessionStateChanged;
  final void Function(int score, int multiplier)? onScoreChanged;

  PulseShiftGame({
    required this.storage,
    this.onSessionStateChanged,
    this.onScoreChanged,
    int? seed,
  }) {
    controller = PulseShiftController(seed: seed);
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

    track = LaneTrackComponent();
    player = PulsePlayerComponent(
      onHitHazard: handleCollisionWithHazard,
      onCollectOrb: handleCollectOrb,
    );
    particles = ParticleSystemComponent();

    await gameWorld.addAll([track, player, particles]);
    await addAll([gameWorld, gameCamera]);
  }

  void onPrimaryAction() {
    if (sessionState == GameSessionState.ready) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      _startGame();
    } else if (sessionState == GameSessionState.playing) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      final oldX = player.position.x;
      player.shiftLane();
      final newX = player.targetX;

      // Estela reactiva de partículas en el cambio de carril
      particles.spawnBurst(
        x: (oldX + newX) / 2,
        y: player.position.y,
        color: player.currentLane.primaryColor,
        count: 10,
        minSpeed: 40,
        maxSpeed: 110,
        particleSize: 3.0,
        lifeTime: 0.3,
      );

      // Notificar a las compuertas de fase activas
      final barriers = gameWorld.children.whereType<BarrierComponent>();
      for (final b in barriers) {
        b.onPlayerShiftedLane();
      }
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

    // Detonar sacudida de pantalla
    _screenShakeTimer = maxShakeDuration;

    // Gran explosión vectorial de partículas
    particles.spawnBurst(
      x: player.position.x,
      y: player.position.y,
      color: ArcadeColors.hazard,
      count: 32,
      minSpeed: 80,
      maxSpeed: 260,
      particleSize: 4.5,
      lifeTime: 0.75,
    );

    // Chispas de la nave
    particles.spawnBurst(
      x: player.position.x,
      y: player.position.y,
      color: player.currentLane.primaryColor,
      count: 16,
      minSpeed: 50,
      maxSpeed: 160,
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

  void handleCollectOrb(PositionComponent orb) {
    if (sessionState != GameSessionState.playing) return;
    if (orb is EnergyOrbComponent) {
      if (orb.isCollected) return;
      orb.isCollected = true;

      ArcadeAudioManager().play(ArcadeSfx.collectItem);

      particles.spawnBurst(
        x: orb.position.x,
        y: orb.position.y,
        color: ArcadeColors.collectible,
        count: 14,
        minSpeed: 40,
        maxSpeed: 130,
        particleSize: 3.0,
        lifeTime: 0.45,
      );

      _rawScore += 25 * multiplier;
      score = _rawScore.round();
      multiplier = math.min(5, multiplier + 1);
      onScoreChanged?.call(score, multiplier);

      orb.removeFromParent();
    }
  }

  void restartGame() {
    score = 0;
    _rawScore = 0.0;
    multiplier = 1;
    isNewRecord = false;
    highScore = storage.getHighScore(gameId);

    // Limpiar entidades activas
    final barriers = gameWorld.children.whereType<BarrierComponent>().toList();
    for (final b in barriers) {
      b.removeFromParent();
    }

    final orbs = gameWorld.children.whereType<EnergyOrbComponent>().toList();
    for (final o in orbs) {
      o.removeFromParent();
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

    // Actualizar velocidad en el riel
    final currentSpeed = controller.currentSpeed;
    track.scrollSpeed = currentSpeed;

    // Actualizar puntaje pasivo por distancia
    _rawScore += (dt * currentSpeed * 0.04);
    score = _rawScore.round();
    onScoreChanged?.call(score, multiplier);

    // Actualizar generador procedimental
    controller.update(
      dt,
      onSpawnBarrier: (lane, type) {
        final barrier = BarrierComponent(
          currentLane: lane,
          initialY: -420.0,
          speed: currentSpeed,
          type: type,
        );
        gameWorld.add(barrier);
      },
      onSpawnOrb: (lane) {
        final orb = EnergyOrbComponent(
          lane: lane,
          initialY: -420.0,
          speed: currentSpeed,
        );
        gameWorld.add(orb);
      },
    );

    // Actualizar sacudida sutil de pantalla
    if (_screenShakeTimer > 0.0) {
      _screenShakeTimer -= dt;
      final intensity = (_screenShakeTimer / maxShakeDuration) * 7.0;
      final shakeX = (math.Random().nextDouble() - 0.5) * intensity;
      final shakeY = (math.Random().nextDouble() - 0.5) * intensity;
      gameCamera.viewfinder.position = Vector2(shakeX, shakeY);
    } else {
      gameCamera.viewfinder.position = Vector2.zero();
    }
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
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
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
