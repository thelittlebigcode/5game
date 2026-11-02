import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de persistencia 100% local (sin red, sin dependencias en la nube).
/// Conforme a ETAPAS.md Etapa 0.3 y .agents/skills/game-audio-and-persistence/SKILL.md
class LocalPersistenceService {
  final SharedPreferences _prefs;

  LocalPersistenceService(this._prefs);

  static Future<LocalPersistenceService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPersistenceService(prefs);
  }

  // Claves de almacenamiento
  static const String _keySfxEnabled = 'settings_sfx_enabled';
  static const String _keyShakeEnabled = 'settings_shake_enabled';
  static const String _prefixHighScore = 'high_score_';

  // --- High Scores ---
  int getHighScore(String gameId) {
    return _prefs.getInt('$_prefixHighScore$gameId') ?? 0;
  }

  Future<bool> saveHighScore(String gameId, int score) async {
    final current = getHighScore(gameId);
    if (score > current) {
      return await _prefs.setInt('$_prefixHighScore$gameId', score);
    }
    return false;
  }

  // --- Ajustes ---
  bool get isSfxEnabled => _prefs.getBool(_keySfxEnabled) ?? true;

  Future<void> setSfxEnabled(bool enabled) async {
    await _prefs.setBool(_keySfxEnabled, enabled);
  }

  bool get isScreenShakeEnabled => _prefs.getBool(_keyShakeEnabled) ?? true;

  Future<void> setScreenShakeEnabled(bool enabled) async {
    await _prefs.setBool(_keyShakeEnabled, enabled);
  }

  /// Restablece todos los datos locales (para pruebas y depuración)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
