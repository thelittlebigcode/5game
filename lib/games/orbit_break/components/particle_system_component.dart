import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/graphics/vector_particle_system.dart';

/// Componente de Flame que encapsula el sistema de partículas vectoriales compartido
class ParticleSystemComponent extends Component {
  final VectorParticleSystem particleSystem;

  ParticleSystemComponent({int? seed})
    : particleSystem = VectorParticleSystem(seed: seed);

  @override
  void update(double dt) {
    super.update(dt);
    particleSystem.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    particleSystem.render(canvas);
  }

  void spawnBurst({
    required double x,
    required double y,
    required Color color,
    int count = 20,
    double minSpeed = 60.0,
    double maxSpeed = 220.0,
    double particleSize = 3.5,
    double lifeTime = 0.65,
  }) {
    particleSystem.spawnBurst(
      x: x,
      y: y,
      color: color,
      count: count,
      minSpeed: minSpeed,
      maxSpeed: maxSpeed,
      particleSize: particleSize,
      lifeTime: lifeTime,
    );
  }

  void clear() {
    particleSystem.clear();
  }
}
