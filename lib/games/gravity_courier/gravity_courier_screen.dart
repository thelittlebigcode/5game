import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/session/game_session_state.dart';
import '../../core/storage/local_persistence_service.dart';
import '../../ui/overlays/game_overlays.dart';
import 'gravity_courier_game.dart';

/// Pantalla contenedora de Gravity Courier con integración de GameWidget y Overlays
class GravityCourierScreen extends StatefulWidget {
  final LocalPersistenceService storage;

  const GravityCourierScreen({super.key, required this.storage});

  @override
  State<GravityCourierScreen> createState() => _GravityCourierScreenState();
}

class _GravityCourierScreenState extends State<GravityCourierScreen> {
  late final GravityCourierGame _game;

  GameSessionState _sessionState = GameSessionState.ready;
  int _score = 0;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _highScore = widget.storage.getHighScore(GravityCourierGame.gameId);

    _game = GravityCourierGame(
      storage: widget.storage,
      onSessionStateChanged: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _sessionState = state;
              _highScore = _game.highScore;
            });
          }
        });
      },
      onScoreChanged: (score, multiplier) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _score = score;
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lienzo del juego Flame
          GameWidget(game: _game),

          // HUD en juego activo o pausa
          if (_sessionState == GameSessionState.playing ||
              _sessionState == GameSessionState.paused)
            InGameHUD(
              score: _score,
              highScore: _highScore,
              onPause: _game.pauseGame,
            ),

          // Overlay de Inicio
          if (_sessionState == GameSessionState.ready)
            ReadyOverlay(
              title: 'GRAVITY COURIER',
              instruction: 'TOCA O PULSA ESPACIO PARA INVERTIR GRAVEDAD',
              onStart: _game.onPrimaryAction,
            ),

          // Overlay de Pausa
          if (_sessionState == GameSessionState.paused)
            PauseOverlay(
              onResume: _game.resumeGame,
              onQuit: () => Navigator.of(context).pop(),
            ),

          // Overlay de Fin de Partida
          if (_sessionState == GameSessionState.finished)
            GameOverOverlay(
              score: _score,
              highScore: _highScore,
              isNewRecord: _game.isNewRecord,
              onRestart: _game.restartGame,
              onQuit: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}
