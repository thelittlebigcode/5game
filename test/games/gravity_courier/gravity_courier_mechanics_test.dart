import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:juego_5/games/gravity_courier/components/cargo_module_component.dart';
import 'package:juego_5/games/gravity_courier/components/courier_hazard_component.dart';
import 'package:juego_5/games/gravity_courier/components/courier_player_component.dart';
import 'package:juego_5/games/gravity_courier/controllers/gravity_courier_controller.dart';
import 'package:juego_5/games/gravity_courier/gravity_courier_game.dart';
import 'package:juego_5/games/gravity_courier/models/wall_side.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Gravity Courier - WallSide & Player Mechanics Tests', () {
    test('WallSide defines correct opposite and wall coordinates', () {
      expect(WallSide.left.opposite, equals(WallSide.right));
      expect(WallSide.right.opposite, equals(WallSide.left));

      expect(WallSide.left.wallX, equals(30.0));
      expect(WallSide.right.wallX, equals(420.0));

      expect(WallSide.left.gravityDirection, equals(-1.0));
      expect(WallSide.right.gravityDirection, equals(1.0));
    });

    test(
      'CourierPlayerComponent toggles gravity side and clamps to boundaries',
      () {
        final player = CourierPlayerComponent();
        expect(player.gravitySide, equals(WallSide.left));
        expect(player.position.x, equals(CourierPlayerComponent.leftLimit));

        // Alternar gravedad a la derecha
        player.toggleGravity();
        expect(player.gravitySide, equals(WallSide.right));

        // Simular avance de física hacia la derecha con dt
        player.update(0.1);
        expect(player.velocityX, greaterThan(0.0));
        expect(
          player.position.x,
          greaterThan(CourierPlayerComponent.leftLimit),
        );

        // Simular avance continuado hasta llegar y chocar con el límite derecho
        for (int i = 0; i < 20; i++) {
          player.update(0.1);
        }
        expect(player.position.x, equals(CourierPlayerComponent.rightLimit));
        expect(player.velocityX, equals(0.0)); // Se estabiliza en la pared
      },
    );

    test(
      'CourierPlayerComponent carries cargo and adjusts acceleration & inertia',
      () {
        final player = CourierPlayerComponent();
        expect(player.hasCargo, isFalse);
        expect(player.carriedCargoCount, equals(0));

        player.addCargo();
        expect(player.hasCargo, isTrue);
        expect(player.carriedCargoCount, equals(1));

        // Alternar gravedad
        player.toggleGravity();
        player.update(0.05);

        // Con carga, la aceleración es menor que en modo normal
        final speedWithCargo = player.velocityX;

        final normalPlayer = CourierPlayerComponent();
        normalPlayer.toggleGravity();
        normalPlayer.update(0.05);
        final normalSpeed = normalPlayer.velocityX;

        expect(speedWithCargo, lessThan(normalSpeed));
      },
    );
  });

  group('Gravity Courier - Hazard & Cargo Components Tests', () {
    test(
      'Hazard components initialize with correct hitboxes and types',
      () async {
        final spikes = CourierHazardComponent(
          hazardType: HazardType.wallSpikes,
          wallSide: WallSide.left,
          position: Vector2(30.0, 100.0),
          size: Vector2(26.0, 80.0),
        );
        await spikes.onLoad();

        expect(spikes.children.whereType<RectangleHitbox>().length, equals(1));
        expect(spikes.hazardType, equals(HazardType.wallSpikes));
        expect(spikes.wallSide, equals(WallSide.left));
      },
    );

    test('MovingGate hazard oscillates width dt-based', () {
      final gate = CourierHazardComponent(
        hazardType: HazardType.movingGate,
        wallSide: WallSide.left,
        position: Vector2(30.0, 150.0),
        size: Vector2(30.0, 22.0),
        maxGateWidth: 120.0,
      );

      final initialWidth = gate.size.x;
      gate.update(0.3);
      expect(gate.size.x, isNot(equals(initialWidth)));
    });

    test('CargoModuleComponent initializes with circular hitbox', () async {
      final cargo = CargoModuleComponent(position: Vector2(200.0, 100.0));
      await cargo.onLoad();

      expect(cargo.children.whereType<CircleHitbox>().length, equals(1));
      expect(cargo.isCollected, isFalse);
    });
  });

  group('Gravity Courier - Controller & Difficulty Scaling Tests', () {
    test(
      'GravityCourierController scales speed with time and respects maxSpeed',
      () {
        final controller = GravityCourierController();
        expect(
          controller.currentScrollSpeed,
          equals(GravityCourierController.baseScrollSpeed),
        );

        // Simular 10 segundos de juego
        controller.update(10.0);
        expect(
          controller.currentScrollSpeed,
          greaterThan(GravityCourierController.baseScrollSpeed),
        );

        // Simular mucho tiempo para alcanzar el tope
        controller.update(200.0);
        expect(
          controller.currentScrollSpeed,
          equals(GravityCourierController.maxScrollSpeed),
        );
      },
    );

    test('GravityCourierController generates procedural hazards deterministically with seed', () {
      final controllerA = GravityCourierController(seed: 42);
      final controllerB = GravityCourierController(seed: 42);

      // Simular varios frames
      List<HazardSpawnConfig> hazardsA = [];
      List<HazardSpawnConfig> hazardsB = [];

      for (int i = 0; i < 100; i++) {
        controllerA.update(0.016);
        controllerB.update(0.016);
        hazardsA.addAll(controllerA.checkHazardSpawns(0.016));
        hazardsB.addAll(controllerB.checkHazardSpawns(0.016));
      }

      expect(hazardsA.length, greaterThan(0));
      expect(hazardsA.length, equals(hazardsB.length));

      for (int i = 0; i < hazardsA.length; i++) {
        expect(hazardsA[i].type, equals(hazardsB[i].type));
        expect(hazardsA[i].wallSide, equals(hazardsB[i].wallSide));
        expect(hazardsA[i].x, equals(hazardsB[i].x));
      }
    });
  });

  group('Gravity Courier - Persistence Tests', () {
    test(
      'LocalPersistenceService records high score for Gravity Courier',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalPersistenceService(prefs);

        expect(storage.getHighScore(GravityCourierGame.gameId), equals(0));

        final saved = await storage.saveHighScore(
          GravityCourierGame.gameId,
          480,
        );
        expect(saved, isTrue);
        expect(storage.getHighScore(GravityCourierGame.gameId), equals(480));

        final lowerAttempt = await storage.saveHighScore(
          GravityCourierGame.gameId,
          200,
        );
        expect(lowerAttempt, isFalse);
        expect(storage.getHighScore(GravityCourierGame.gameId), equals(480));
      },
    );
  });
}
