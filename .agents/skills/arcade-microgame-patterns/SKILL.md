---
name: arcade-microgame-patterns
description: Architectural patterns for arcade microgames in Flutter + Flame, including session state machines, unified input handling for PC/Mobile, and responsive viewport resolution scaling. Use when structuring game lifecycles, overlays, and cross-platform controls.
---

# Arcade Microgame Patterns

This skill defines the architectural blueprint for managing individual microgames within the 5-game collection.

## 1. Game Session Lifecycle

Every microgame conforms to a standardized finite state machine:

```text
[Ready] ---> (Input / Tap) ---> [Playing]
   ^                                |
   |                                |---> (Pause) <---> [Paused]
   |                                |
   |                                v
[Restart] <------------------- [Finished / GameOver]
```

### State Definition:
```dart
enum GameSessionState {
  ready,
  playing,
  paused,
  finished,
}
```

- **`ready`**: Scene rendered, instructions visible ("Tap or Space to Start"), waiting for first input.
- **`playing`**: Active game loop, inputs move the player, score increments.
- **`paused`**: Simulation halted (`dt = 0`), pause overlay displayed.
- **`finished`**: Defeat condition reached. Final score calculated, record updated if beaten, Game Over overlay shown with instant restart option.

## 2. Unified Input Mapping (PC & Mobile)

Games must react smoothly whether played with a physical keyboard on PC/Steam or touch taps on Mobile/Android.

```dart
abstract class MicrogameInputHandler {
  void onPrimaryAction(); // Primary action (Flip direction, drop block, switch lane)
  void onPauseAction();   // Escape on PC, back button on mobile
}
```

- **PC**: Map `LogicalKeyboardKey.space`, `LogicalKeyboardKey.arrowUp`, `LogicalKeyboardKey.enter`, or left mouse click to `onPrimaryAction()`. Map `LogicalKeyboardKey.escape` to `onPauseAction()`.
- **Mobile**: Full-screen gesture detector or Flame `TapDetector` triggering `onPrimaryAction()`.

## 3. Responsive Viewport & Resolution Scaling

Arcade microgames must display properly across desktop window resizing and various mobile screen aspect ratios (16:9, 19.5:9, etc.).

### Standard Logical Resolution:
Use a fixed logical resolution (e.g. `480 x 800` for vertical arcade games) inside `CameraComponent.withFixedResolution`:

```dart
camera = CameraComponent.withFixedResolution(
  width: 480,
  height: 800,
  world: world,
);
```

- Flame automatically scales the viewport preserving aspect ratio and adding safe letterboxing or extending background borders.
- Keep all interactive hazards and critical UI inside the central safe area.

## 4. Flutter Overlay Integration

Flame games communicate with Flutter using `overlays`:

```dart
GameWidget<OrbitBreakGame>(
  game: game,
  overlayBuilderMap: {
    'ReadyOverlay': (context, game) => ReadyOverlay(game: game),
    'PauseOverlay': (context, game) => PauseOverlay(game: game),
    'GameOverOverlay': (context, game) => GameOverOverlay(game: game),
  },
  initialActiveOverlays: const ['ReadyOverlay'],
)
```

In the game:
```dart
void onGameOver() {
  state = GameSessionState.finished;
  overlays.add('GameOverOverlay');
}
```
