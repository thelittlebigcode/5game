import 'package:flutter/material.dart';

import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';
import '../components/retro_highway_background.dart';
import 'main_menu_screen.dart';

/// Pantalla de bienvenida con fondo animado de carretera infinita y cerros vectoriales
class WelcomeScreen extends StatelessWidget {
  final LocalPersistenceService storage;

  const WelcomeScreen({super.key, required this.storage});

  void _navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainMenuScreen(storage: storage),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArcadeColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo animado: carretera infinita, cerros al fondo y partículas en loop
          const RetroHighwayBackground(),

          // Capa de gradiente sutil para garantizar máximo contraste y legibilidad
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ArcadeColors.background.withValues(alpha: 0.15),
                  ArcadeColors.background.withValues(alpha: 0.45),
                  ArcadeColors.background.withValues(alpha: 0.90),
                ],
                stops: const [0.0, 0.55, 0.92],
              ),
            ),
          ),

          // Contenido principal de la pantalla
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logotipo / Título Arcade
                  const Text(
                    'ARCADE 5',
                    style: TextStyle(
                      color: ArcadeColors.neonCyan,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      shadows: [
                        Shadow(color: ArcadeColors.neonCyan, blurRadius: 16.0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MICROJUEGOS RETRO VECTORIALES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ArcadeColors.textMuted.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const Spacer(),

                  // Botón inferior: "COMENZAR A JUGAR"
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ArcadeColors.neonGreen.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ArcadeColors.neonGreen,
                        foregroundColor: ArcadeColors.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _navigateToMainMenu(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'COMENZAR A JUGAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ROBOZETA • 100% OFFLINE',
                    style: TextStyle(
                      color: ArcadeColors.textMuted.withValues(alpha: 0.5),
                      fontSize: 10,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
