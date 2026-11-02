import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:juego_5/core/theme/arcade_colors.dart';
import 'package:juego_5/games/pulse_shift/components/barrier_component.dart';
import 'package:juego_5/games/pulse_shift/components/pulse_player_component.dart';
import 'package:juego_5/games/pulse_shift/controllers/pulse_shift_controller.dart';
import 'package:juego_5/games/pulse_shift/models/lane.dart';
import 'package:juego_5/games/pulse_shift/pulse_shift_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PulseShift Lane & Player Tests', () {
    test('Lane model defines distinct coordinates, opposites and colors', () {
      expect(Lane.left.xPosition, -75.0);
      expect(Lane.right.xPosition, 75.0);
      expect(Lane.left.opposite, Lane.right);
      expect(Lane.right.opposite, Lane.left);

      expect(Lane.left.primaryColor, ArcadeColors.arcadeMagenta);
      expect(Lane.right.primaryColor, ArcadeColors.neonCyan);
    });

    test(
      'PulsePlayerComponent shifts lane snappily and changes target position',
      () {
        final player = PulsePlayerComponent();
        expect(player.currentLane, Lane.left);
        expect(player.targetX, Lane.left.xPosition);

        // Shift to right
        player.shiftLane();
        expect(player.currentLane, Lane.right);
        expect(player.targetX, Lane.right.xPosition);

        // dt-based update moves position toward target
        player.update(0.1);
        expect(player.position.x, greaterThan(Lane.left.xPosition));

        // Shift back to left
        player.shiftLane();
        expect(player.currentLane, Lane.left);
        expect(player.targetX, Lane.left.xPosition);

        // Reset
        player.reset();
        expect(player.currentLane, Lane.left);
        expect(player.position.x, Lane.left.xPosition);
      },
    );
  });

  group('PulseShift Dynamic Obstacle & PhaseGate Tests', () {
    test('PhaseGate barrier reacts to player lane shift while fixed barrier does not', () {
      final fixedBarrier = BarrierComponent(
        currentLane: Lane.left,
        initialY: -100.0,
        speed: 260.0,
        type: BarrierType.fixed,
      );

      final phaseBarrier = BarrierComponent(
        currentLane: Lane.left,
        initialY: -100.0,
        speed: 260.0,
        type: BarrierType.phaseGate,
      );

      // Player shifts
      fixedBarrier.onPlayerShiftedLane();
      phaseBarrier.onPlayerShiftedLane();

      // Fixed barrier keeps lane
      expect(fixedBarrier.currentLane, Lane.left);
      expect(fixedBarrier.targetX, Lane.left.xPosition);

      // Phase gate switches to opposite lane
      expect(phaseBarrier.currentLane, Lane.right);
      expect(phaseBarrier.targetX, Lane.right.xPosition);
    });

    test('BarrierComponent scrolls downward dt-based', () {
      final barrier = BarrierComponent(
        currentLane: Lane.right,
        initialY: 0.0,
        speed: 300.0,
      );

      barrier.update(0.2); // 0.2 * 300 = 60
      expect(barrier.position.y, closeTo(60.0, 0.01));
    });
  });

  group('PulseShift Controller & Difficulty Tests', () {
    test('PulseShiftController scales speed with elapsed time and caps at maxSpeed', () {
      final controller = PulseShiftController(seed: 10);
      expect(controller.currentSpeed, PulseShiftController.baseSpeed);

      // Simulate 20 seconds
      controller.update(
        20.0,
        onSpawnBarrier: (lane, type) {},
        onSpawnOrb: (lane) {},
      );
      expect(
        controller.currentSpeed,
        greaterThan(PulseShiftController.baseSpeed),
      );

      // Simulate 100 more seconds -> reaches maxSpeed
      controller.update(
        100.0,
        onSpawnBarrier: (lane, type) {},
        onSpawnOrb: (lane) {},
      );
      expect(controller.currentSpeed, PulseShiftController.maxSpeed);

      controller.reset();
      expect(controller.currentSpeed, PulseShiftController.baseSpeed);
      expect(controller.elapsedTime, 0.0);
    });

    test(
      'PulseShiftController procedural generation is deterministic with seed',
      () {
        final controllerA = PulseShiftController(seed: 777);
        final controllerB = PulseShiftController(seed: 777);

        final barriersA = <String>[];
        final barriersB = <String>[];

        const dt = 1.0 / 60.0;
        for (int i = 0; i < 400; i++) {
          controllerA.update(
            dt,
            onSpawnBarrier: (lane, type) =>
                barriersA.add('${lane.name}_${type.name}'),
            onSpawnOrb: (lane) {},
          );
          controllerB.update(
            dt,
            onSpawnBarrier: (lane, type) =>
                barriersB.add('${lane.name}_${type.name}'),
            onSpawnOrb: (lane) {},
          );
        }

        expect(barriersA.isNotEmpty, isTrue);
        expect(barriersA, equals(barriersB));
      },
    );
  });

  group('PulseShift Persistence Tests', () {
    test(
      'LocalPersistenceService records high score for Pulse Shift',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalPersistenceService(prefs);

        expect(storage.getHighScore(PulseShiftGame.gameId), 0);

        await storage.saveHighScore(PulseShiftGame.gameId, 450);
        expect(storage.getHighScore(PulseShiftGame.gameId), 450);

        // Lower score does not overwrite
        await storage.saveHighScore(PulseShiftGame.gameId, 300);
        expect(storage.getHighScore(PulseShiftGame.gameId), 450);

        // Higher score overwrites
        await storage.saveHighScore(PulseShiftGame.gameId, 890);
        expect(storage.getHighScore(PulseShiftGame.gameId), 890);
      },
    );
  });
}
