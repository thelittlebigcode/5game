---
name: flame-game-development
description: Best practices, component patterns, procedural vector rendering, and collision handling for Flame 2D games in Flutter. Use when building or refactoring microgame loops, PositionComponents, canvas rendering, or collision hitboxes.
---

# Flame Game Development for Arcade Microgames

This skill outlines patterns for building lightweight, responsive, and framerate-independent 2D arcade microgames using Flame in Flutter.

## Core Architecture

Each game is encapsulated in `lib/games/<game_name>/` and implements a dedicated `FlameGame`:

```dart
class MyMicroGame extends FlameGame with HasCollisionDetection, KeyboardEvents, TapDetector {
  late final World gameWorld;
  late final CameraComponent gameCamera;

  @override
  Future<void> onLoad() async {
    gameWorld = World();
    gameCamera = CameraComponent.withFixedResolution(
      width: 480,
      height: 800,
      world: gameWorld,
    );
    await addAll([gameWorld, gameCamera]);
  }
}
```

## Procedural Vector Rendering

To keep the game minimalist, sharp at any DPI, and low in asset size, draw entities programmatically rather than using raster sprites.

### Guidelines:
1. **Reuse Paints**: Pre-instantiate `Paint` objects as fields instead of allocating new `Paint()` inside `render(Canvas canvas)`.
2. **Geometric Primitives**: Use `canvas.drawCircle`, `canvas.drawRect`, `canvas.drawRRect`, `canvas.drawArc`, and `Path` for polygons.
3. **Palette Constraints**: Use 3 to 5 dominant colors per game. Ensure high contrast against the background.

```dart
class OrbitingPlayer extends PositionComponent with CollisionCallbacks {
  final Paint _fillPaint = Paint()..color = const Color(0xFF00FFCC);
  final Paint _glowPaint = Paint()
    ..color = const Color(0x3300FFCC)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, size.x / 2 + 3, _glowPaint);
    canvas.drawCircle(Offset.zero, size.x / 2, _fillPaint);
  }
}
```

## Framerate Independence & Delta Time

Never hardcode frame-based increments. All position and angle updates must multiply by `dt` (seconds passed since last frame):

```dart
@override
void update(double dt) {
  super.update(dt);
  if (isPaused) return;
  angle = (angle + angularVelocity * dt) % (2 * pi);
  position = center + Vector2(cos(angle), sin(angle)) * radius;
}
```

## Collision Detection & Hitboxes

1. Always mix in `HasCollisionDetection` into the root `FlameGame`.
2. Add precise hitboxes (`CircleHitbox`, `RectangleHitbox`, or `PolygonHitbox`) to interactive components.
3. Handle collisions in `onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other)`.

```dart
@override
Future<void> onLoad() async {
  add(CircleHitbox(isSolid: true));
}

@override
void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  super.onCollisionStart(intersectionPoints, other);
  if (other is HazardComponent) {
    gameRef.triggerGameOver();
  }
}
```

## Lifecycle & Memory Clean-up

When a player restarts or exits:
- Stop any active sound loops.
- Remove components cleanly via `removeFromParent()`.
- Clear references in `onRemove()` to avoid memory leaks across frequent quick restarts.
