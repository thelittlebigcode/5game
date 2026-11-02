import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/core/audio/arcade_audio_manager.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArcadeAudioManager & Offline Sound Tests', () {
    test(
      'ArcadeAudioManager initializes and reflects persistence settings',
      () async {
        SharedPreferences.setMockInitialValues({'settings_sfx_enabled': true});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalPersistenceService(prefs);

        final audio = ArcadeAudioManager();
        audio.initialize(storage);

        expect(audio.isSfxEnabled, isTrue);

        await storage.setSfxEnabled(false);
        expect(audio.isSfxEnabled, isFalse);

        await storage.setSfxEnabled(true);
        expect(audio.isSfxEnabled, isTrue);
      },
    );

    test(
      'ArcadeAudioManager plays SFX safely without throwing errors',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalPersistenceService(prefs);

        final audio = ArcadeAudioManager();
        audio.initialize(storage);

        // Cada trigger debe ejecutarse limpiamente de manera determinista
        expect(() => audio.play(ArcadeSfx.actionPrimary), returnsNormally);
        expect(() => audio.play(ArcadeSfx.collectItem), returnsNormally);
        expect(() => audio.play(ArcadeSfx.perfectCombo), returnsNormally);
        expect(() => audio.play(ArcadeSfx.collisionImpact), returnsNormally);
        expect(() => audio.play(ArcadeSfx.gameOver), returnsNormally);
        expect(() => audio.play(ArcadeSfx.newHighScore), returnsNormally);
      },
    );

    test('ArcadeAudioManager respects muted state', () async {
      SharedPreferences.setMockInitialValues({'settings_sfx_enabled': false});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalPersistenceService(prefs);

      final audio = ArcadeAudioManager();
      audio.initialize(storage);

      expect(audio.isSfxEnabled, isFalse);
      expect(() => audio.play(ArcadeSfx.actionPrimary), returnsNormally);
    });
  });
}
