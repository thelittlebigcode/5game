import 'package:flutter/services.dart';

import '../storage/local_persistence_service.dart';

/// Sonidos retro arcade disponibles en la colección
enum ArcadeSfx {
  /// Sonido de acción principal (salto, flip de órbita, corte de bloque, shift)
  actionPrimary,

  /// Recolección de bonificación, orbe de energía o módulo de carga
  collectItem,

  /// Alineación milimétrica perfecta o combo en Perfect Drop
  perfectCombo,

  /// Impacto contra obstáculo o colisión
  collisionImpact,

  /// Fin de partida / explosión
  gameOver,

  /// Notificación de nuevo récord local
  newHighScore,
}

/// Gestor de audio y retroalimentación arcade 100% offline.
/// Emite retroalimentación táctil y tonos sonoros del sistema (SystemSound / HapticFeedback)
/// sin requerir descargas, conexiones ni dependencias externas pesadas.
class ArcadeAudioManager {
  static final ArcadeAudioManager _instance = ArcadeAudioManager._internal();
  factory ArcadeAudioManager() => _instance;
  ArcadeAudioManager._internal();

  LocalPersistenceService? _storage;

  void initialize(LocalPersistenceService storage) {
    _storage = storage;
  }

  bool get isSfxEnabled => _storage?.isSfxEnabled ?? true;

  /// Reproduce un efecto de sonido / feedback háptico retro.
  void play(ArcadeSfx sfx) {
    if (!isSfxEnabled) return;

    switch (sfx) {
      case ArcadeSfx.actionPrimary:
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
        break;

      case ArcadeSfx.collectItem:
        HapticFeedback.selectionClick();
        SystemSound.play(SystemSoundType.click);
        break;

      case ArcadeSfx.perfectCombo:
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        break;

      case ArcadeSfx.collisionImpact:
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
        break;

      case ArcadeSfx.gameOver:
        HapticFeedback.vibrate();
        SystemSound.play(SystemSoundType.alert);
        break;

      case ArcadeSfx.newHighScore:
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        break;
    }
  }
}
