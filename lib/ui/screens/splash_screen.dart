import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/storage/local_persistence_service.dart';
import '../../core/theme/arcade_colors.dart';
import 'welcome_screen.dart';

/// Pantalla de Splash nativa de Flutter con el logo de la compañía RoboZeta
class SplashScreen extends StatefulWidget {
  final LocalPersistenceService storage;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.storage,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _navigationTimer = Timer(widget.duration, _navigateToWelcome);
  }

  void _navigateToWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            WelcomeScreen(storage: widget.storage),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final splashLogo = isDarkMode
        ? 'assets/splash/logo-splash-dark.png'
        : 'assets/splash/logo-splash-white.png';

    return Scaffold(
      backgroundColor: ArcadeColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(splashLogo, width: 220, fit: BoxFit.contain),
              const SizedBox(height: 20),
              Text(
                'ROBOZETA STUDIOS',
                style: TextStyle(
                  color: ArcadeColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
