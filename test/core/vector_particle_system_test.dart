import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/core/graphics/vector_particle_system.dart';

void main() {
  group('VectorParticleSystem Tests', () {
    test('Spawns burst of particles deterministically with seed', () {
      final system = VectorParticleSystem(seed: 123);
      expect(system.particleCount, 0);

      system.spawnBurst(
        x: 100,
        y: 100,
        color: const Color(0xFF00F5D4),
        count: 10,
        lifeTime: 0.5,
      );

      expect(system.particleCount, 10);

      // Simular paso del tiempo
      system.update(0.3);
      expect(system.particleCount, 10);

      // Superar tiempo de vida
      system.update(0.6);
      expect(system.particleCount, 0);
    });

    test('Clear removes all particles immediately', () {
      final system = VectorParticleSystem(seed: 42);
      system.spawnBurst(x: 0, y: 0, color: const Color(0xFFFF007F), count: 8);
      expect(system.particleCount, 8);
      system.clear();
      expect(system.particleCount, 0);
    });
  });
}
