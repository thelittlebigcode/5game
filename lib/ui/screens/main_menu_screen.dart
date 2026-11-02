import 'package:flutter/material.dart';

import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';
import '../../games/orbit_break/orbit_break_screen.dart';
import '../../games/perfect_drop/perfect_drop_screen.dart';
import '../../games/pulse_shift/pulse_shift_screen.dart';
import '../../games/gravity_courier/gravity_courier_screen.dart';
import '../../games/split_second/split_second_screen.dart';
import '../models/game_item_info.dart';
import 'settings_screen.dart';

/// Menú Principal con selector vertical de los 5 microjuegos arcade
class MainMenuScreen extends StatefulWidget {
  final LocalPersistenceService storage;
  final void Function(String gameId)? onSelectGame;

  const MainMenuScreen({super.key, required this.storage, this.onSelectGame});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  static const List<GameItemInfo> games = [
    GameItemInfo(
      id: 'orbit_break',
      title: 'ORBIT BREAK',
      subtitle: 'Órbita y evasión reactiva',
      accentColor: ArcadeColors.neonCyan,
      status: GameStatus.playable,
    ),
    GameItemInfo(
      id: 'perfect_drop',
      title: 'PERFECT DROP',
      subtitle: 'Apilamiento milimétrico',
      accentColor: ArcadeColors.neonGreen,
      status: GameStatus.playable,
    ),
    GameItemInfo(
      id: 'pulse_shift',
      title: 'PULSE SHIFT',
      subtitle: 'Cambio de carril dinámico',
      accentColor: ArcadeColors.arcadeMagenta,
      status: GameStatus.playable,
    ),
    GameItemInfo(
      id: 'gravity_courier',
      title: 'GRAVITY COURIER',
      subtitle: 'Gravedad lateral y transporte',
      accentColor: ArcadeColors.electricAmber,
      status: GameStatus.playable,
    ),
    GameItemInfo(
      id: 'split_second',
      title: 'SPLIT SECOND',
      subtitle: 'Control sincronizado dual',
      accentColor: ArcadeColors.flashWhite,
      status: GameStatus.playable,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARCADE 5',
                        style: TextStyle(
                          color: ArcadeColors.neonCyan,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                        ),
                      ),
                      Text(
                        'COLECCIÓN RETRO VECTORIAL',
                        style: TextStyle(
                          color: ArcadeColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: ArcadeColors.textMuted,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SettingsScreen(storage: widget.storage),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    tooltip: 'Configuración',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: ArcadeColors.surfaceBorder, thickness: 1),
            // Lista de juegos
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: games.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final game = games[index];
                  final highScore = widget.storage.getHighScore(game.id);
                  final isPlayable = game.status == GameStatus.playable;

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isPlayable
                        ? () {
                            if (widget.onSelectGame != null) {
                              widget.onSelectGame!(game.id);
                            } else if (game.id == 'orbit_break') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrbitBreakScreen(storage: widget.storage),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (game.id == 'perfect_drop') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PerfectDropScreen(
                                    storage: widget.storage,
                                  ),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (game.id == 'pulse_shift') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PulseShiftScreen(storage: widget.storage),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (game.id == 'gravity_courier') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GravityCourierScreen(
                                    storage: widget.storage,
                                  ),
                                ),
                              ).then((_) => setState(() {}));
                            } else if (game.id == 'split_second') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SplitSecondScreen(
                                    storage: widget.storage,
                                  ),
                                ),
                              ).then((_) => setState(() {}));
                            }
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ArcadeColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPlayable
                              ? game.accentColor.withValues(alpha: 0.8)
                              : ArcadeColors.surfaceBorder,
                          width: isPlayable ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isPlayable
                                  ? game.accentColor
                                  : ArcadeColors.surfaceBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      game.title,
                                      style: TextStyle(
                                        color: isPlayable
                                            ? ArcadeColors.textPrimary
                                            : ArcadeColors.textMuted,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    if (!isPlayable) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ArcadeColors.surfaceBorder,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'PRÓXIMO',
                                          style: TextStyle(
                                            color: ArcadeColors.textMuted,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  game.subtitle,
                                  style: const TextStyle(
                                    color: ArcadeColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                if (isPlayable) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'RÉCORD: $highScore PTS',
                                    style: TextStyle(
                                      color: game.accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            isPlayable ? Icons.play_arrow : Icons.lock_outline,
                            color: isPlayable
                                ? game.accentColor
                                : ArcadeColors.surfaceBorder,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
