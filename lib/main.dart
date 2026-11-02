import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/audio/arcade_audio_manager.dart';
import 'core/storage/local_persistence_service.dart';
import 'core/theme/arcade_colors.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloqueo de orientación vertical obligatoria para móviles
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storage = await LocalPersistenceService.create();
  ArcadeAudioManager().initialize(storage);

  runApp(ArcadeApp(storage: storage));
}

class ArcadeApp extends StatelessWidget {
  final LocalPersistenceService storage;

  const ArcadeApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcade 5 - Retro Collection',
      debugShowCheckedModeBanner: false,
      theme: ArcadeTheme.darkTheme,
      home: SplashScreen(storage: storage),
    );
  }
}
