import 'dart:math' as math;

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart';

import '../../core/audio/arcade_audio_manager.dart';
import '../../core/session/game_session_state.dart';
import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';
import 'components/falling_debris_component.dart';
import 'components/moving_block_component.dart';
import 'components/particle_system_component.dart';
import 'components/stacked_block_component.dart';
import 'controllers/perfect_drop_controller.dart';
import 'models/block_type.dart';
import 'models/slice_calculator.dart';

/// Juego 2: Perfect Drop
/// Apilamiento vertical de plataformas móviles con algoritmo de recorte milimétrico.
/// Conforme a ETAPAS.md (Etapas 2.1 a 2.6).
class PerfectDropGame extends FlameGame with KeyboardEvents, TapCallbacks {
  static const String gameId = 'perfect_drop';
  static const double baseBlockWidth = 200.0;
  static const double blockHeight = 28.0;
  static const double baseFloorY = 240.0;

  final LocalPersistenceService storage;

  late final World gameWorld;
  late final CameraComponent gameCamera;

  late final ParticleSystemComponent particles;
  late final PerfectDropController controller;

  GameSessionState sessionState = GameSessionState.ready;

  int score = 0;
  int multiplier = 1;
  int highScore = 0;
  bool isNewRecord = false;

  // Seguimiento de la torre
  final List<StackedBlockComponent> tower = [];
  MovingBlockComponent? currentMovingBlock;

  double currentTopY = baseFloorY;
  double currentWidth = baseBlockWidth;
  double currentCenterX = 0.0;
  int nextDirection = 1;

  // Notificadores reactivos hacia los Overlays de Flutter
  final void Function(GameSessionState state)? onSessionStateChanged;
  final void Function(int score, int multiplier)? onScoreChanged;

  PerfectDropGame({
    required this.storage,
    this.onSessionStateChanged,
    this.onScoreChanged,
    int? seed,
  }) {
    controller = PerfectDropController(seed: seed);
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

    particles = ParticleSystemComponent();
    await gameWorld.add(particles);

    _buildBasePlatform();

    await addAll([gameWorld, gameCamera]);
  }

  /// Construye la plataforma base sólida al pie de la torre
  void _buildBasePlatform() {
    final baseBlock = StackedBlockComponent(
      centerX: 0.0,
      centerY: baseFloorY,
      blockWidth: baseBlockWidth,
      blockHeight: blockHeight,
      blockType: BlockType.standard,
    );
    tower.add(baseBlock);
    gameWorld.add(baseBlock);
  }

  /// Inicia la partida y genera la primera plataforma móvil
  void _startGame() {
    sessionState = GameSessionState.playing;
    onSessionStateChanged?.call(sessionState);
    _spawnNextMovingBlock();
  }

  /// Spawnea la siguiente plataforma móvil oscilante
  void _spawnNextMovingBlock() {
    final nextType = controller.nextBlockType();
    final speed = controller.speedForBlock(nextType);
    final spawnY = currentTopY - blockHeight;

    // Alternar lado de inicio (-160 o +160)
    final spawnX = nextDirection > 0 ? -175.0 : 175.0;

    final moving = MovingBlockComponent(
      initialX: spawnX,
      centerY: spawnY,
      blockWidth: currentWidth,
      blockHeight: blockHeight,
      speed: speed,
      blockType: nextType,
      direction: nextDirection,
    );

    currentMovingBlock = moving;
    gameWorld.add(moving);

    // Alternar dirección base para el siguiente
    nextDirection = -nextDirection;
  }

  /// Detiene la plataforma móvil y ejecuta el recorte o la recompensa de precisión
  void _dropCurrentBlock() {
    final moving = currentMovingBlock;
    if (moving == null) return;

    final dropY = moving.position.y;
    final movingX = moving.position.x;

    // Calcular resultado con el algoritmo exacto
    final result = SliceCalculator.calculate(
      movingCenterX: movingX,
      movingWidth: moving.blockWidth,
      targetCenterX: currentCenterX,
      targetWidth: currentWidth,
      blockType: moving.blockType,
      currentCombo: controller.combo,
      maxWidth: baseBlockWidth,
    );

    // Quitar bloque móvil activo
    moving.removeFromParent();
    currentMovingBlock = null;

    if (result.isMiss) {
      // Condición de derrota: fallo total
      _handleMissDefeat(moving, movingX, dropY);
      return;
    }

    // Actualizar combo y puntuación
    controller.updateCombo(result.combo);
    controller.incrementHeight();

    score += result.pointsAwarded;
    multiplier = (1 + (result.combo ~/ 2)).clamp(1, 5);
    onScoreChanged?.call(score, multiplier);

    if (result.isPerfect) {
      // Recompensa Perfect Drop
      ArcadeAudioManager().play(ArcadeSfx.perfectCombo);
      _handlePerfectDrop(result, dropY, moving.blockType);
    } else {
      // Recorte con sobrante residual
      ArcadeAudioManager().play(ArcadeSfx.actionPrimary);
      _handleSlicedDrop(result, dropY, moving.blockType);
    }

    // Actualizar estado de la cima
    currentTopY = dropY;
    currentWidth = result.placedWidth;
    currentCenterX = result.placedCenterX;

    // Generar el siguiente bloque
    _spawnNextMovingBlock();
  }

  void _handlePerfectDrop(
    DropSliceResult result,
    double dropY,
    BlockType type,
  ) {
    // Destello de partículas del Perfect Drop
    particles.spawnBurst(
      x: result.placedCenterX,
      y: dropY,
      color: ArcadeColors.flashWhite,
      count: 24,
      minSpeed: 70,
      maxSpeed: 230,
      particleSize: 4.0,
      lifeTime: 0.6,
    );

    // Partículas neón de soporte
    particles.spawnBurst(
      x: result.placedCenterX,
      y: dropY,
      color: type.color,
      count: 14,
      minSpeed: 40,
      maxSpeed: 140,
      particleSize: 3.0,
      lifeTime: 0.5,
    );

    final stacked = StackedBlockComponent(
      centerX: result.placedCenterX,
      centerY: dropY,
      blockWidth: result.placedWidth,
      blockHeight: blockHeight,
      blockType: type,
      startWithFlash: true,
    );

    tower.add(stacked);
    gameWorld.add(stacked);
  }

  void _handleSlicedDrop(DropSliceResult result, double dropY, BlockType type) {
    // Spawner de fragmento residual cayendo
    if (result.overhangWidth != null && result.overhangCenterX != null) {
      final debris = FallingDebrisComponent(
        centerX: result.overhangCenterX!,
        centerY: dropY,
        blockWidth: result.overhangWidth!,
        blockHeight: blockHeight,
        color: type.color,
        vx: result.isOverhangOnRight ? 45.0 : -45.0,
        rotationSpeed: result.isOverhangOnRight ? 4.0 : -4.0,
      );
      gameWorld.add(debris);

      // Chispas en el borde del corte
      final cutEdgeX = result.isOverhangOnRight
          ? result.placedCenterX + result.placedWidth / 2
          : result.placedCenterX - result.placedWidth / 2;

      particles.spawnBurst(
        x: cutEdgeX,
        y: dropY,
        color: type.color,
        count: 10,
        minSpeed: 30,
        maxSpeed: 120,
        particleSize: 2.5,
        lifeTime: 0.4,
      );
    }

    final stacked = StackedBlockComponent(
      centerX: result.placedCenterX,
      centerY: dropY,
      blockWidth: result.placedWidth,
      blockHeight: blockHeight,
      blockType: type,
    );

    tower.add(stacked);
    gameWorld.add(stacked);
  }

  void _handleMissDefeat(
    MovingBlockComponent moving,
    double movingX,
    double dropY,
  ) {
    // El bloque que cayó al vacío
    final fallingMissed = FallingDebrisComponent(
      centerX: movingX,
      centerY: dropY,
      blockWidth: moving.blockWidth,
      blockHeight: blockHeight,
      color: moving.blockType.color,
      vx: movingX > currentCenterX ? 80.0 : -80.0,
      rotationSpeed: 6.0,
    );
    gameWorld.add(fallingMissed);

    // Explosión y colapso de la torre
    ArcadeAudioManager().play(ArcadeSfx.gameOver);
    _triggerTowerCollapse();

    sessionState = GameSessionState.finished;

    // Verificar y guardar récord local
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

  void _triggerTowerCollapse() {
    // Explosión de partículas vectoriales sobre la cima y bloques
    for (int i = 0; i < tower.length; i++) {
      final block = tower[i];
      particles.spawnBurst(
        x: block.position.x,
        y: block.position.y,
        color: block.blockType.color,
        count: math.min(12, 6 + i),
        minSpeed: 50,
        maxSpeed: 180,
        particleSize: 3.0,
        lifeTime: 0.7,
      );
    }
  }

  // --- Ciclo de vida y Pausa ---
  void onPrimaryAction() {
    if (sessionState == GameSessionState.ready) {
      _startGame();
    } else if (sessionState == GameSessionState.playing) {
      _dropCurrentBlock();
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

  void restartGame() {
    score = 0;
    multiplier = 1;
    isNewRecord = false;
    highScore = storage.getHighScore(gameId);

    // Limpiar todos los bloques de la torre excepto el estado inicial
    for (final b in tower) {
      b.removeFromParent();
    }
    tower.clear();

    // Limpiar bloques móviles y fragmentos
    currentMovingBlock?.removeFromParent();
    currentMovingBlock = null;

    final debris = gameWorld.children
        .whereType<FallingDebrisComponent>()
        .toList();
    for (final d in debris) {
      d.removeFromParent();
    }

    particles.clear();
    controller.reset();

    currentTopY = baseFloorY;
    currentWidth = baseBlockWidth;
    currentCenterX = 0.0;
    nextDirection = 1;

    // Resetear posición de la cámara
    gameCamera.viewfinder.position = Vector2.zero();

    _buildBasePlatform();

    sessionState = GameSessionState.ready;
    resumeEngine();
    onScoreChanged?.call(score, multiplier);
    onSessionStateChanged?.call(sessionState);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (sessionState != GameSessionState.playing) return;

    // Seguimiento suave de la cámara vertical conforme la torre crece
    // Si la cima sube por encima de y = 40, la cámara acompaña hacia arriba
    final targetCameraY = math.min(0.0, currentTopY - 40.0);
    final currentCamY = gameCamera.viewfinder.position.y;
    final lerpSpeed = 4.0;
    gameCamera.viewfinder.position.y +=
        (targetCameraY - currentCamY) * lerpSpeed * dt;
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
