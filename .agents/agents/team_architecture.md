# Equipo de Agentes Especializados (Multi-Agent Setup)

Para el desarrollo del pack de 5 microjuegos arcade con Flutter y Flame, se han configurado 4 subagentes especializados, alineados con los requisitos de [CONTEXTO.md](../../CONTEXTO.md):

---

## 1. `arcade_ui_ux_designer` (Diseñador UI/UX & Dirección de Arte Arcade)
* **Propósito:** Definir la estética visual geométrica/vectorial, diseño de interacción responsivo, HUDs no invasivos y accesibilidad.
* **Responsabilidades:**
  * Paletas cromáticas de alto contraste (3 a 5 colores por juego) y sistema de tokens de diseño.
  * Ergonomía táctil para móviles (touch targets >= 48dp, zonas de alcance del pulgar, soporte de Safe Area).
  * Ergonomía para PC (indicadores de atajos de teclado, escalado de ventana fluido).
  * Jerarquía y diseño de overlays (`Ready`, `In-Game HUD`, `Pause`, `Game Over`, `Settings`).
  * Principios de accesibilidad visual (doble codificación: color + forma geométrica para peligros y recompensas).
  * Moderación de partículas y efectos visuales ("game juice") para no obstruir la legibilidad.

---

## 2. `flame_game_architect` (Arquitecto de Juegos Flame & Gameplay)
* **Propósito:** Encargado exclusivo del motor 2D Flame y la implementación de las mecánicas interactivas de cada microjuego.
* **Responsabilidades:**
  * Implementación de componentes en `lib/games/<nombre_juego>/` (`FlameGame`, `PositionComponent`, `World`, `CameraComponent`).
  * Dibujo geométrico y vectorial programático (`Canvas`, `Paint`, arcos, polígonos).
  * Movimiento determinista e independiente del framerate usando `dt` en `update(double dt)`.
  * Detección de colisiones con hitboxes nativos (`CircleHitbox`, `RectangleHitbox`).
  * Ciclo de vida y prevención de fugas de memoria en reinicios (`onLoad`, `onRemove`).

---

## 3. `flutter_app_engineer` (Ingeniero de Plataforma & UI Flutter)
* **Propósito:** Estructuración de la aplicación Flutter, menús, integración de overlays y sistemas compartidos.
* **Responsabilidades:**
  * Arquitectura general (`lib/app/`, `lib/core/`, `lib/ui/`, `lib/shared/`).
  * Integración de Flame mediante `GameWidget` con soporte de overlays reactivos (Inicio, Pausa, Game Over).
  * Persistencia local ligera para récords y preferencias (audio/volumen) sin bases de datos pesadas.
  * Máquina de estados de sesión de juego (`ready`, `playing`, `paused`, `finished`).
  * Adaptabilidad responsiva para PC (escalado de ventana) y móviles (gestión de safe areas).

---

## 4. `gameplay_qa_tester` (Especialista en QA, Físicas y Balance)
* **Propósito:** Asegurar la calidad, estabilidad, cobertura de pruebas, balance de dificultad y generación de reportes.
* **Responsabilidades:**
  * Creación y ejecución de pruebas unitarias (`test/`) para puntuación, multiplicadores y transiciones de estado.
  * Pruebas deterministas con generadores de números pseudoaleatorios con semilla fija (`seed`).
  * Verificación de reinicio limpio (sin estados residuales ni timers huérfanos).
  * Ejecución de análisis estático (`dart analyze`) y resolución de lints.
  * Balance de curvas de dificultad (progresión justa de velocidad y generación de obstáculos).
  * Redacción de reportes de finalización de fase conforme a la Sección 15 de `CONTEXTO.md`.
