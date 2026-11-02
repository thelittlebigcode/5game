---
name: arcade-ui-ux-design
description: Design principles, color palettes, responsive UI layouts, HUD telemetry, visual feedback, and accessibility guidelines for minimalist arcade microgames in Flutter. Use when styling menus, overlays, game HUDs, or establishing design tokens.
---

# Arcade UI/UX Design System

This skill defines the visual identity, ergonomics, and interface rules for the 5-microgame arcade collection, balancing arcade dynamism with minimalist clarity.

---

## 1. Visual Direction & Design Tokens

### Aesthetic: Minimalist Geometric Vector
- **Primitives**: Pure geometric forms (circles, squares, equilateral triangles, arcs, regular polygons).
- **Surfaces**: Flat or subtle monochromatic gradients. Dark or high-contrast neutral backgrounds.
- **Color Palettes**: 3 to 5 dominant colors per game.
  - Background (neutral deep tone, e.g. `#0E1117` or `#121826`)
  - Player entity (high-visibility accent, e.g. Neon Cyan `#00F5D4` or Emerald `#10B981`)
  - Hazards/Obstacles (danger hue, e.g. Hot Coral `#FF4D6D` or Warning Amber `#F59E0B`)
  - Collectibles/Bonus (energetic hue, e.g. Electric Yellow `#FEE440` or Violet `#7B2CBF`)
  - Text & UI chrome (Pure white `#FFFFFF` and muted grey `#94A3B8`)

### Typography
- Monospace or geometric sans-serif fonts with clear tabular numerals (`fontFeatures: [FontFeature.tabularFigures()]`) for score counters to prevent jitter.
- High contrast against all backgrounds (minimum WCAG AA 4.5:1 ratio).

---

## 2. Ergonomics & Responsive UX (Mobile & PC)

### Mobile/Touch Ergonomics:
- **Touch Targets**: Minimum interactive dimension of **48x48 dp** for all buttons.
- **Thumb Zones**: Place critical interactions (Restart, Play, Pause toggle) within easy thumb reach (bottom and middle zones of screen).
- **Safe Area Insets**: Wrap all Flutter overlays in `SafeArea` to avoid camera cutouts, notches, and OS gesture bars.
- **Immediate Input**: Zero unnecessary dialog confirmations before restarting. One tap on Game Over restarts the game instantly.

### Desktop/PC Ergonomics:
- Visible keyboard prompt indicators (`[SPACE] Play`, `[ESC] Pause`, `[R] Restart`).
- Fluid window resizing handling: The game viewport scales uniformly with letterboxing/pillarboxing while UI overlays adapt to window edges.

---

## 3. HUD & Overlay Architecture

```text
+-------------------------------------------------------+
|  [||] Pause                               Score: 1,420 | <-- Top HUD
|                                                       |
|                                                       |
|                     [GAMEPLAY]                        |
|                                                       |
|                                                       |
|  [=== Stability ===]                                  | <-- Bottom Telemetry
+-------------------------------------------------------+
```

### In-Game HUD:
- **Zero Clutter**: Display only vital data during play (Current Score, Multiplier, Stability bar).
- **Peripheral Positioning**: Keep HUD elements pinned to screen edges so the central play area remains unobstructed.

### Overlays (Flutter Widgets over Flame):
1. **Ready Screen**: Clean title, micro-instructions ("Tap to flip direction"), and a pulsating prompt.
2. **Pause Menu**: Freezes game simulation, offers "Resume", "Restart", and "Main Menu" with audio volume slider.
3. **Game Over / Results**:
   - Final Score highlighted prominently.
   - High Score banner (with distinct celebration animation if beaten).
   - Prominent **"Play Again"** primary button.

---

## 4. Visual Feedback & Juice

- **Impact Sparks**: Short, non-persistent geometric bursts (3 to 6 particles, lifetime < 300ms).
- **Screen Shake**: Subtle and brief (duration < 150ms, amplitude 3-5px) reserved for game-ending collisions.
- **Flash Feedback**: Single-frame white flash or color pulse on point collection.
- **Rule**: Feedback must *never* mask an approaching hazard or disorient the player.

---

## 5. Accessibility Guidelines

- **Dual-Coding**: Never use color as the sole differentiator between safe objects and hazards.
  - *Example*: Player = Circle with outline; Hazard = Sharp triangle or spiked polygon; Collectible = Diamond or ring.
- **Motion Reduction**: Provide an option in Settings to disable screen shake for players sensitive to sudden motion.
