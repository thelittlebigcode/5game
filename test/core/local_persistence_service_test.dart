import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';

void main() {
  group('LocalPersistenceService Tests', () {
    late LocalPersistenceService storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'High score defaults to 0 and updates correctly when higher',
      () async {
        final prefs = await SharedPreferences.getInstance();
        storage = LocalPersistenceService(prefs);

        expect(storage.getHighScore('orbit_break'), 0);

        final updated = await storage.saveHighScore('orbit_break', 150);
        expect(updated, isTrue);
        expect(storage.getHighScore('orbit_break'), 150);

        // No actualiza si es menor o igual
        final notUpdated = await storage.saveHighScore('orbit_break', 100);
        expect(notUpdated, isFalse);
        expect(storage.getHighScore('orbit_break'), 150);
      },
    );

    test('Settings toggles persist correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      storage = LocalPersistenceService(prefs);

      expect(storage.isSfxEnabled, isTrue);
      expect(storage.isScreenShakeEnabled, isTrue);

      await storage.setSfxEnabled(false);
      expect(storage.isSfxEnabled, isFalse);

      await storage.setScreenShakeEnabled(false);
      expect(storage.isScreenShakeEnabled, isFalse);
    });
  });
}
