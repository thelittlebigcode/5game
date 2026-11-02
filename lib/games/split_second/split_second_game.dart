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
import 'components/dual_entity_component.dart';
import 'components/dual_track_divider_component.dart';
import 'components/particle_system_component.dart';
import 'components/split_hazard_component.dart';
import 'components/synergy_orb_component.dart';
import 'controllers/split_second_controller.dart';
import 'models/track_side.dart';

/// Juego 5: Split Second
/// Dos entidades en carriles paralelos controladas simultáneamente con una sola acción.
/// Conforme a ETAPAS.md (Etapas 5.1 a 5.6).
class SplitSecondGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  static const String gameId = 'split_second';

  final LocalPersistenceService storage;

  late final World gameWorld;
  late final CameraComponent gameCamera;

  late final DualTrackDividerComponent trackDivider;
  late final DualEntityComponent leftEntity;
  late final DualEntityComponent rightEntity;
  late final ParticleSystemComponent particles;
  late final SplitSecondController controller;

  GameSessionState sessionState = GameSessionState.ready;

  int score = 0;
  double _rawDistanceScore = 0.0;
  int synergyBonus = 0;
  int multiplier = 1;
  int highScore = 0;
  bool isNewRecord = false;

  // Sacudida de pantalla sutil al colisionar
  double _screenShakeTimer = 0.0;
  static const double maxShakeDuration = 0.28;

  final void Function(GameSessionState state)? onSessionStateChanged;
  final void Function(int score, int multiplier)? onScoreChanged;

  SplitSecondGame({
    required this.storage,
    this.onSessionStateChanged,
    this.onScoreChanged,
    int? seed,
  }) {
    controller = SplitSecondController(seed: seed);
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

    trackDivider = DualTrackDividerComponent();

    leftEntity = DualEntityComponent(
      trackSide: TrackSide.leftTrack,
      isInner: false,
      onHitHazard: handleCollisionWithHazard,
      onCollectOrb: handleCollectSynergyOrb,
    );

    rightEntity = DualEntityComponent(
      trackSide: TrackSide.rightTrack,
      isInner: false,
      onHitHazard: handleCollisionWithHazard,
      onCollectOrb: handleCollectSynergyOrb,
    );

    particles = ParticleSystemComponent();

    await gameWorld.addAll([trackDivider, leftEntity, rightEntity, particles]);
    await addAll([gameWorld, gameCamera]);
  }

  /// Entrada unificada: un solo toque o comando acciona la maniobra evasiva en ambas entidades a la vez.
  void onPrimaryAction() {
    if (sessionState == GameSessionState.ready) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      _startGame();
    } else if (sessionState == GameSessionState.playing) {
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      leftEntity.toggleLane();
      rightEntity.toggleLane();

      // Destellos vectoriales simultáneos en ambos vehículos
      particles.spawnBurst(
        x: leftEntity.position.x,
        y: leftEntity.position.y,
        color: leftEntity.trackSide.primaryColor,
        count: 12,
        minSpeed: 40,
        maxSpeed: 140,
        particleSize: 3.0,
        lifeTime: 0.35,
      );

      particles.spawnBurst(
        x: rightEntity.position.x,
        y: rightEntity.position.y,
        color: rightEntity.trackSide.primaryColor,
        count: 12,
        minSpeed: 40,
        maxSpeed: 140,
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

  /// Derrota: la caída de cualquiera de las dos entidades causa explosión dual y finaliza la partida.
  void handleCollisionWithHazard(
    DualEntityComponent entity,
    SplitHazardComponent hazard,
  ) {
    if (sessionState != GameSessionState.playing) return;

    ArcadeAudioManager().play(ArcadeSfx.gameOver);

    _screenShakeTimer = maxShakeDuration;

    // Explosión masiva en la entidad que colisionó
    particles.spawnBurst(
      x: entity.position.x,
      y: entity.position.y,
      color: ArcadeColors.hazard,
      count: 35,
      minSpeed: 90,
      maxSpeed: 270,
      particleSize: 4.5,
      lifeTime: 0.8,
    );

    // Explosión de sobrecarga en la otra entidad (derrota sincronizada)
    final otherEntity = entity == leftEntity ? rightEntity : leftEntity;
    particles.spawnBurst(
      x: otherEntity.position.x,
      y: otherEntity.position.y,
      color: otherEntity.trackSide.primaryColor,
      count: 25,
      minSpeed: 70,
      maxSpeed: 200,
      particleSize: 3.5,
      lifeTime: 0.65,
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

  /// Sinergia cruzada: el orbe recolectado en una pista activa un pulso de defensa
  /// que despeja obstáculos cercanos en la OTRA pista y suma bonificación.
  void handleCollectSynergyOrb(
    DualEntityComponent entity,
    SynergyOrbComponent orb,
  ) {
    if (sessionState != GameSessionState.playing) return;
    if (orb.isCollected) return;
    orb.isCollected = true;

    ArcadeAudioManager().play(ArcadeSfx.collectItem);

    multiplier = math.min(5, multiplier + 1);
    synergyBonus += 40 * multiplier;
    _updateTotalScore();

    // Partículas de recolección
    particles.spawnBurst(
      x: orb.position.x,
      y: orb.position.y,
      color: ArcadeColors.electricAmber,
      count: 16,
      minSpeed: 50,
      maxSpeed: 160,
      particleSize: 3.5,
      lifeTime: 0.45,
    );

    // Pulso defensivo en la otra pista: elimina peligros a menos de 250px de distancia
    final targetTrack = entity.trackSide == TrackSide.leftTrack
        ? TrackSide.rightTrack
        : TrackSide.leftTrack;

    final hazardsInOtherTrack = gameWorld.children
        .whereType<SplitHazardComponent>()
        .where((h) => h.trackSide == targetTrack)
        .where((h) => (h.position.y - entity.position.y).abs() < 280)
        .toList();

    for (final h in hazardsInOtherTrack) {
      particles.spawnBurst(
        x: h.position.x,
        y: h.position.y,
        color: ArcadeColors.neonCyan,
        count: 14,
        minSpeed: 40,
        maxSpeed: 140,
        particleSize: 3.0,
        lifeTime: 0.4,
      );
      h.removeFromParent();
    }

    orb.removeFromParent();
  }

  void _updateTotalScore() {
    score = (_rawDistanceScore + synergyBonus).round();
    onScoreChanged?.call(score, multiplier);
  }

  void restartGame() {
    score = 0;
    _rawDistanceScore = 0.0;
    synergyBonus = 0;
    multiplier = 1;
    isNewRecord = false;
    highScore = storage.getHighScore(gameId);

    // Limpiar entidades activas
    final hazards = gameWorld.children
        .whereType<SplitHazardComponent>()
        .toList();
    for (final h in hazards) {
      h.removeFromParent();
    }

    final orbs = gameWorld.children.whereType<SynergyOrbComponent>().toList();
    for (final o in orbs) {
      o.removeFromParent();
    }

    particles.clear();
    leftEntity.reset(false);
    rightEntity.reset(false);
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

    // Actualizar controlador y velocidad
    controller.update(dt);
    final speed = controller.currentScrollSpeed;
    trackDivider.updateScroll(speed, dt);

    // Puntuación continua por distancia sincronizada
    _rawDistanceScore += (speed * 0.05) * dt * multiplier;
    _updateTotalScore();

    // Mover obstáculos hacia abajo
    final hazards = gameWorld.children
        .whereType<SplitHazardComponent>()
        .toList();
    for (final hazard in hazards) {
      hazard.position.y += speed * dt;
      if (hazard.position.y > 850) {
        hazard.removeFromParent();
      }
    }

    // Mover orbes hacia abajo
    final orbs = gameWorld.children.whereType<SynergyOrbComponent>().toList();
    for (final orb in orbs) {
      orb.position.y += speed * dt;
      if (orb.position.y > 850) {
        orb.removeFromParent();
      }
    }

    // Generar nuevos obstáculos
    final newHazards = controller.checkHazardSpawns(
      dt,
      leftPlayerInner: leftEntity.isInner,
      rightPlayerInner: rightEntity.isInner,
    );
    for (final config in newHazards) {
      final hazard = SplitHazardComponent(
        trackSide: config.trackSide,
        isInner: config.isInner,
        position: Vector2(config.trackSide.laneX(config.isInner), config.y),
      );
      gameWorld.add(hazard);
    }

    // Generar nuevos orbes de sinergia
    final orbConfig = controller.checkSynergyOrbSpawn(dt);
    if (orbConfig != null) {
      final orb = SynergyOrbComponent(
        trackSide: orbConfig.trackSide,
        isInner: orbConfig.isInner,
        position: Vector2(
          orbConfig.trackSide.laneX(orbConfig.isInner),
          orbConfig.y,
        ),
      );
      gameWorld.add(orb);
    }

    // Sacudida de cámara
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
