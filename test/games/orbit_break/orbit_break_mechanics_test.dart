import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/games/orbit_break/components/orbital_player_component.dart';
import 'package:juego_5/games/orbit_break/controllers/orbit_difficulty_controller.dart';

void main() {
  group('OrbitBreak Unit Tests', () {
    test('OrbitalPlayerComponent flips direction and moves dt-based', () {
      final player = OrbitalPlayerComponent(orbitRadius: 100.0);
      expect(player.direction, 1);
      final initialAngle = player.currentAngle;

      // Actualizar 0.2 segundos hacia adelante
      player.update(0.2);
      expect(player.currentAngle, greaterThan(initialAngle));

      // Invertir dirección
      player.flipDirection();
      expect(player.direction, -1);

      // Actualizar 0.1 segundos hacia atrás
      final angleBeforeReverse = player.currentAngle;
      player.update(0.1);
      expect(player.currentAngle, lessThan(angleBeforeReverse));
    });

    test(
      'OrbitDifficultyController scales speed with time and caps at maxSpeed',
      () {
        final controller = OrbitDifficultyController(seed: 10);
        expect(
          controller.currentAngularSpeed,
          OrbitDifficultyController.baseSpeed,
        );

        // Simular 30 segundos
        controller.update(
          30.0,
          onSpawnHazard: (angle, sweep) {},
          onSpawnOrb: (angle) {},
        );
        expect(
          controller.currentAngularSpeed,
          greaterThan(OrbitDifficultyController.baseSpeed),
        );

        // Simular 200 segundos
        controller.update(
          170.0,
          onSpawnHazard: (angle, sweep) {},
          onSpawnOrb: (angle) {},
        );
        expect(
          controller.currentAngularSpeed,
          OrbitDifficultyController.maxSpeed,
        );

        // Reinicio
        controller.reset();
        expect(
          controller.currentAngularSpeed,
          OrbitDifficultyController.baseSpeed,
        );
      },
    );

    test('OrbitDifficultyController spawns hazards and orbs deterministically with seed', () {
      final controller = OrbitDifficultyController(seed: 42);
      int hazardsSpawned = 0;
      int orbsSpawned = 0;

      // 5 segundos de simulación a 60 FPS (dt = 1/60)
      const dt = 1.0 / 60.0;
      for (int i = 0; i < 300; i++) {
        controller.update(
          dt,
          onSpawnHazard: (angle, sweep) => hazardsSpawned++,
          onSpawnOrb: (angle) => orbsSpawned++,
        );
      }

      expect(hazardsSpawned, greaterThan(0));
      expect(orbsSpawned, greaterThan(0));
    });
  });
}
