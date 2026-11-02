import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Partícula vectorial simple para el motor de efectos compartidos
class VectorParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final Color color;
  final double size;

  VectorParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.color,
    required this.size,
  }) : life = maxLife;

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    return life > 0;
  }

  void render(Canvas canvas, Paint paint) {
    if (life <= 0) return;
    final alpha = (life / maxLife).clamp(0.0, 1.0);
    paint.color = color.withValues(alpha: alpha);
    canvas.drawCircle(Offset(x, y), size * alpha, paint);
  }
}

/// Emisor compartido de partículas vectoriales ligeras
class VectorParticleSystem {
  final List<VectorParticle> _particles = [];
  final Paint _particlePaint = Paint()..isAntiAlias = true;
  final math.Random _random;

  VectorParticleSystem({int? seed}) : _random = math.Random(seed);

  int get particleCount => _particles.length;

  void spawnBurst({
    required double x,
    required double y,
    required Color color,
    int count = 16,
    double minSpeed = 50.0,
    double maxSpeed = 180.0,
    double particleSize = 3.0,
    double lifeTime = 0.5,
  }) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = minSpeed + _random.nextDouble() * (maxSpeed - minSpeed);
      _particles.add(
        VectorParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          maxLife: lifeTime * (0.8 + _random.nextDouble() * 0.4),
          color: color,
          size: particleSize,
        ),
      );
    }
  }

  void update(double dt) {
    _particles.removeWhere((p) => !p.update(dt));
  }

  void render(Canvas canvas) {
    for (final particle in _particles) {
      particle.render(canvas, _particlePaint);
    }
  }

  void clear() {
    _particles.clear();
  }
}
