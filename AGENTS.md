# AGENTS.md

Repository is currently **documentation-only**: there is no `pubspec.yaml`, `lib/`, `test/`, or OpenCode config yet. Do not assume a Flutter app exists; the first implementation task is scaffolding it per `CONTEXTO.md` §16, starting with Orbit Break.

## Sources of truth

- `CONTEXTO.md` — functional, technical, quality, and reporting requirements (Spanish).
- `ETAPAS.md` — staged delivery plan and current checklists. `docs/ETAPAS.md` is an identical copy: update **both** if the plan changes.
- `.agents/rules/game_development_rules.md` — always-on rules.
- `.agents/skills/*/SKILL.md` and `.agents/agents/team_architecture.md` — patterns and agent-role boundaries.
- No `opencode.json` exists; these files are loaded as repo guidance, not automatically.

## Verified toolchain

- Flutter 3.47.5 stable, Dart 3.13.4 (Windows x64), as of 2026-11-01.
- Re-check `flutter --version` before pinning dependency versions; do not invent package versions.
- Targets: PC/Windows first, Android as expansion.

## Hard project constraints

- **Offline strict**: no remote servers, APIs, CDNs, auth, analytics, ads, IAP, or post-install downloads. All assets bundled; all records/settings local (`shared_preferences` is the planned dependency).
- **Portrait orientation only**, fixed vertical window on PC.
- **Vector minimalism**: programmatic `Canvas`/`Paint` shapes, no sprite-heavy assets; palette from `ETAPAS.md` (`#39FF14`, `#00F5D4`, `#FF007F`, `#FFB703`, `#FFFFFF` on `#0A0A0F`).
- **One game at a time**, in the order Orbit Break → Perfect Drop → Pulse Shift → Gravity Courier → Split Second. Do not build all five in one pass.
- Each game lives in `lib/games/<game>/` and must not import another game's internals. Shared systems go in `lib/core/` and `lib/shared/`.
- Unified primary action for keyboard (Space/Enter/arrows/click) and touch (tap); pause with Escape/back.
- Simulation must be `dt`-based, deterministic, and seeded in tests; pause/finish must halt updates.
- Game session states are exactly `ready`, `playing`, `paused`, `finished`.
- Work in Spanish for docs and reports. Progress reports must follow the 10-point format in `CONTEXTO.md` §15, and must not claim commands/builds were run if they were not.

## Resolution note

`ETAPAS.md` fixes the logical portrait resolution at **450×800**; the skills examples use 480×800 and `CONTEXTO.md` still lists resolution as pending. Treat 450×800 as the current target but reconcile the docs rather than silently choosing a third value.

## Commands (once the Flutter scaffold exists)

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test test/games/orbit_break/<file>_test.dart   # single file
flutter test --plain-name "test name"                   # single test
flutter run -d windows                                  # PC target
```

Run `format` → `analyze` → `test` before reporting a stage complete. No CI, pre-commit hooks, codegen, or migrations are configured yet.
