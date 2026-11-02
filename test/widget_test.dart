import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:juego_5/ui/screens/main_menu_screen.dart';

void main() {
  testWidgets('MainMenuScreen renders correctly with games and best score', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'high_score_orbit_break': 350});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalPersistenceService(prefs);

    await tester.pumpWidget(
      MaterialApp(home: MainMenuScreen(storage: storage)),
    );

    expect(find.text('ARCADE 5'), findsOneWidget);
    expect(find.text('ORBIT BREAK'), findsOneWidget);
    expect(find.text('PERFECT DROP'), findsOneWidget);
    expect(find.text('RÉCORD: 350 PTS'), findsOneWidget);
  });
}
