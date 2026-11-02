---
name: game-audio-and-persistence
description: Lightweight local persistence for high scores, game settings, and audio management (SFX, mute/volume control) in Flutter arcade games. Use when implementing local record storage, sound triggers, or settings panels.
---

# Game Audio and Persistence

This skill covers lightweight local storage and audio playback without remote dependencies or external server overhead.

## 1. Local Storage Architecture

According to `CONTEXTO.md`, all data must be strictly local (no cloud, no remote user accounts).

### Storage Contract:
```dart
abstract class LocalPersistenceService {
  Future<void> init();
  
  // High Scores
  int getHighScore(String gameId);
  Future<bool> saveHighScore(String gameId, int score);

  // Settings
  bool get isSoundEnabled;
  Future<void> setSoundEnabled(bool enabled);

  double get sfxVolume;
  Future<void> setSfxVolume(double volume);
}
```

### Key Practices:
- Use `shared_preferences` or a simple JSON file in `path_provider` application documents directory.
- High score check: `if (newScore > existingHighScore) saveHighScore(...)`.
- Never execute file or storage I/O inside the per-frame game loop (`update(double dt)`). Write asynchronously upon game over.

## 2. Audio Management

Sound design reinforces arcade tactile feedback (hit, score, drop, fail, new record).

### Audio Manager Contract:
```dart
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isMuted = false;
  double _volume = 1.0;

  void playSfx(String sfxName) {
    if (_isMuted) return;
    // Play short effect (e.g., using FlameAudio.play or audioplayers)
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }
}
```

### Essential Audio Triggers:
1. `action_primary`: Triggered on input (orbit flip, block drop, lane shift).
2. `collect_particle`: Triggered on picking up a bonus or energy orb.
3. `collision_fail`: Impact with an obstacle.
4. `game_over`: End of session.
5. `new_high_score`: Beating the local record.

### Asset Rules:
- Audio assets must be copyright-free or original.
- Preload short SFX during game initialization (`onLoad`) to eliminate latency on first playback.
- Ensure audio players are properly disposed when leaving the game screen.
