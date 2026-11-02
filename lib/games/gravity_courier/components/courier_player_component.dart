import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';
import '../models/wall_side.dart';
import 'cargo_module_component.dart';
import 'courier_hazard_component.dart';

/// Nave repartidora / transportador de gravedad lateral en Gravity Courier.
class CourierPlayerComponent extends PositionComponent with CollisionCallbacks {
  static const double playerWidth = 24.0;
  static const double playerHeight = 24.0;

  // Límites laterales de contacto con paredes
  static const double leftLimit = 30.0 + playerWidth / 2; // 42.0
  static const double rightLimit = 420.0 - playerWidth / 2; // 408.0

  // Constantes de física horizontal
  static const double normalGravityAcceleration = 1800.0;
  static const double loadedGravityAcceleration =
      1200.0; // Inercia más pesada con carga
  static const double normalMaxSpeed = 750.0;
  static const double loadedMaxSpeed = 550.0;

  WallSide gravitySide = WallSide.left;
  double velocityX = 0.0;

  // Estado de carga
  int carriedCargoCount = 0;
  bool get hasCargo => carriedCargoCount > 0;

  final void Function(CourierHazardComponent hazard)? onHitHazard;
  final void Function(CargoModuleComponent cargo)? onCollectCargo;

  final Paint _shipPaint = Paint()
    ..color = ArcadeColors.neonCyan
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _shipFillPaint = Paint()
    ..color = ArcadeColors.neonCyan.withValues(alpha: 0.25)
    ..style = PaintingStyle.fill;

  final Paint _cargoAuraPaint = Paint()
    ..color = ArcadeColors.electricAmber.withValues(alpha: 0.4)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  CourierPlayerComponent({this.onHitHazard, this.onCollectCargo})
    : super(
        position: Vector2(leftLimit, 620.0),
        size: Vector2(playerWidth, playerHeight),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 11.0));
  }

  /// Alterna la gravedad lateral hacia la pared opuesta.
  void toggleGravity() {
    gravitySide = gravitySide.opposite;
  }

  void addCargo() {
    carriedCargoCount++;
  }

  void reset() {
    gravitySide = WallSide.left;
    position.setValues(leftLimit, 620.0);
    velocityX = 0.0;
    carriedCargoCount = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final acceleration = hasCargo
        ? loadedGravityAcceleration
        : normalGravityAcceleration;
    final maxSpeed = hasCargo ? loadedMaxSpeed : normalMaxSpeed;

    // Aplicar fuerza gravitatoria hacia la pared activa
    velocityX += gravitySide.gravityDirection * acceleration * dt;
    velocityX = velocityX.clamp(-maxSpeed, maxSpeed);

    // Actualizar posición X
    position.x += velocityX * dt;

    // Colisión / contacto contra pared izquierda
    if (position.x <= leftLimit) {
      position.x = leftLimit;
      if (gravitySide == WallSide.left && velocityX < 0) {
        velocityX = 0.0;
      }
    }

    // Colisión / contacto contra pared derecha
    if (position.x >= rightLimit) {
      position.x = rightLimit;
      if (gravitySide == WallSide.right && velocityX > 0) {
        velocityX = 0.0;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is CourierHazardComponent) {
      onHitHazard?.call(other);
    } else if (other is CargoModuleComponent) {
      onCollectCargo?.call(other);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final path = Path();
    // Nave triangular estilizada con alerones que apuntan según la gravedad
    final halfW = size.x / 2;
    final halfH = size.y / 2;

    if (gravitySide == WallSide.right) {
      // Orientación apuntando a la pared derecha
      path.moveTo(halfW, 0); // Vértice derecho
      path.lineTo(-halfW, -halfH);
      path.lineTo(-halfW * 0.4, 0);
      path.lineTo(-halfW, halfH);
      path.close();
    } else {
      // Orientación apuntando a la pared izquierda
      path.moveTo(-halfW, 0); // Vértice izquierdo
      path.lineTo(halfW, -halfH);
      path.lineTo(halfW * 0.4, 0);
      path.lineTo(halfW, halfH);
      path.close();
    }

    canvas.drawPath(path, _shipFillPaint);
    canvas.drawPath(path, _shipPaint);

    // Indicador visual de módulo acoplado si transporta carga
    if (hasCargo) {
      canvas.drawCircle(Offset.zero, 14.0, _cargoAuraPaint);
      final cargoRect = Rect.fromCenter(
        center: Offset.zero,
        width: 8.0,
        height: 8.0,
      );
      final innerCargoPaint = Paint()..color = ArcadeColors.electricAmber;
      canvas.drawRect(cargoRect, innerCargoPaint);
    }
  }
}
