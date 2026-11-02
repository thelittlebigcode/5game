---
name: gameplay-balancing-and-qa
description: Quality assurance testing, deterministic simulation validation, difficulty scaling math, and phase progress reporting according to CONTEXTO.md section 15. Use when writing game tests, balancing difficulty curves, verifying memory leaks on restart, or generating milestone reports.
---

# Gameplay Balancing and QA Testing

This skill provides methodologies for validating arcade gameplay fairness, stability, test coverage, and documentation reporting.

## 1. Deterministic Testing & Seeding

Arcade patterns must be testable without relying on uncontrolled randomness.

```dart
class HazardSpawner {
  final math.Random random;

  HazardSpawner({int? seed}) : random = math.Random(seed);

  double nextSpawnInterval() {
    return 1.5 + random.nextDouble() * 0.8;
  }
}
```

In unit tests:
```dart
test('Generates predictable obstacle sequence given fixed seed', () {
  final spawner = HazardSpawner(seed: 42);
  final first = spawner.nextSpawnInterval();
  final second = spawner.nextSpawnInterval();
  expect(first, closeTo(2.08, 0.01));
});
```

## 2. Difficulty Scaling Formulas

Difficulty should increase progressively and fairly:
- **Linear Scaling**: `speed(t) = baseSpeed + acceleration * t`
- **Capped Exponential Scaling**: `speed(t) = minSpeed + (maxSpeed - minSpeed) * (1 - exp(-k * t))`
- **Step / Wave Scaling**: Increases speed or frequency every $N$ seconds or every score threshold.

Always clamp maximum speed so the game remains humanly readable and physically reactable.

## 3. Session Restart & Memory Leak Validation

A game must reset cleanly. In tests or review:
1. Verify that restarting from `finished` back to `ready` resets:
   - Score to 0.
   - Speed to `baseSpeed`.
   - Multipliers to 1x.
   - Clears all spawned obstacle components.
2. Verify that paused states freeze all game timers and delta updates (`dt == 0`).

## 4. Phase Progress Report Template (CONTEXTO.md Section 15)

Every completed development phase must be reported in Spanish with this exact structure:

```markdown
### 1. Objetivo de la fase
[Descripción concisa del objetivo]

### 2. Qué se implementó
[Lista de funcionalidades, mecánicas y componentes desarrollados]

### 3. Archivos creados o modificados
- `lib/...`
- `test/...`

### 4. Decisiones técnicas
[Justificación de patrones, dependencias o algoritmos escogidos]

### 5. Pruebas y comandos ejecutados
- `flutter test`
- `dart analyze`

### 6. Resultado de las pruebas
[Resumen de tests pasados / fallidos y análisis estático]

### 7. Problemas conocidos
[Limitaciones o deuda técnica temporal]

### 8. Cómo ejecutar o probar la versión
[Instrucciones paso a paso para ejecutar y jugar la entrega]

### 9. Qué queda pendiente
[Detalles que se pospusieron conscientemente]

### 10. Recomendación para la siguiente fase
[Próximo paso sugerido según el roadmap de CONTEXTO.md]
```
