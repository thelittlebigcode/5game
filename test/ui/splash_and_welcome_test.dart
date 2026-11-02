import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:juego_5/ui/screens/splash_screen.dart';
import 'package:juego_5/ui/screens/welcome_screen.dart';

void main() {
  testWidgets('SplashScreen renders dark logo in dark mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalPersistenceService(prefs);

    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: SplashScreen(
            key: const Key('splash_dark'),
            storage: storage,
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ),
    );

    final imageDarkFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/splash/logo-splash-dark.png',
    );
    expect(imageDarkFinder, findsOneWidget);

    // Avanzar la duración de la splash screen y la transición de página
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('COMENZAR A JUGAR'), findsOneWidget);
  });

  testWidgets('SplashScreen renders white logo in light mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalPersistenceService(prefs);

    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.light,
        theme: ThemeData.light(),
        home: MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.light),
          child: SplashScreen(
            key: const Key('splash_light'),
            storage: storage,
            duration: const Duration(milliseconds: 500),
          ),
        ),
      ),
    );

    final imageWhiteFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/splash/logo-splash-white.png',
    );
    expect(imageWhiteFinder, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('COMENZAR A JUGAR'), findsOneWidget);
  });

  testWidgets('WelcomeScreen button tap navigates to MainMenuScreen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'high_score_orbit_break': 500});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalPersistenceService(prefs);

    await tester.pumpWidget(MaterialApp(home: WelcomeScreen(storage: storage)));

    expect(find.text('COMENZAR A JUGAR'), findsOneWidget);
    await tester.tap(find.text('COMENZAR A JUGAR'));
    await tester.pumpAndSettle();

    // Ahora estamos en MainMenuScreen
    expect(find.text('ARCADE 5'), findsOneWidget);
    expect(find.text('ORBIT BREAK'), findsOneWidget);
    expect(find.text('RÉCORD: 500 PTS'), findsOneWidget);
  });
}
