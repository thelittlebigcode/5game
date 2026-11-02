import 'package:flutter/material.dart';

import '../../core/theme/arcade_colors.dart';

/// Overlay de inicio 'Ready'
class ReadyOverlay extends StatelessWidget {
  final VoidCallback onStart;
  final String title;
  final String instruction;

  const ReadyOverlay({
    super.key,
    required this.onStart,
    required this.title,
    this.instruction = 'TOCA O PULSA ESPACIO PARA INICIAR',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStart,
      child: Container(
        color: ArcadeColors.background.withValues(alpha: 0.65),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: ArcadeColors.neonCyan,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: ArcadeColors.neonGreen, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                instruction,
                style: const TextStyle(
                  color: ArcadeColors.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HUD Perimetral durante el juego
class InGameHUD extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onPause;

  const InGameHUD({
    super.key,
    required this.score,
    required this.highScore,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.pause, color: ArcadeColors.neonCyan),
              onPressed: onPause,
              tooltip: 'Pausar [ESC]',
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    color: ArcadeColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'BEST: $highScore',
                  style: const TextStyle(
                    color: ArcadeColors.textMuted,
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay de Pausa
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const PauseOverlay({super.key, required this.onResume, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ArcadeColors.background.withValues(alpha: 0.85),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PAUSA',
            style: TextStyle(
              color: ArcadeColors.electricAmber,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
            ),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArcadeColors.neonCyan,
              foregroundColor: ArcadeColors.background,
              minimumSize: const Size(180, 48),
            ),
            onPressed: onResume,
            child: const Text(
              'CONTINUAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: ArcadeColors.textMuted,
              side: const BorderSide(color: ArcadeColors.surfaceBorder),
              minimumSize: const Size(180, 48),
            ),
            onPressed: onQuit,
            child: const Text('VOLVER AL MENÚ'),
          ),
        ],
      ),
    );
  }
}

/// Overlay de Game Over con reinicio inmediato
class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isNewRecord;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ArcadeColors.background.withValues(alpha: 0.9),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'FIN DE PARTIDA',
            style: TextStyle(
              color: ArcadeColors.hazard,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 20),
          if (isNewRecord) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: ArcadeColors.neonGreen.withValues(alpha: 0.15),
                border: Border.all(color: ArcadeColors.neonGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '★ ¡NUEVO RÉCORD! ★',
                style: TextStyle(
                  color: ArcadeColors.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            '$score',
            style: const TextStyle(
              color: ArcadeColors.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            'MEJOR MARCA: $highScore',
            style: const TextStyle(color: ArcadeColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArcadeColors.neonGreen,
              foregroundColor: ArcadeColors.background,
              minimumSize: const Size(200, 52),
            ),
            onPressed: onRestart,
            child: const Text(
              'REINTENTAR [ESPACIO]',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: ArcadeColors.textMuted,
              minimumSize: const Size(200, 44),
            ),
            onPressed: onQuit,
            child: const Text('MENÚ PRINCIPAL'),
          ),
        ],
      ),
    );
  }
}
