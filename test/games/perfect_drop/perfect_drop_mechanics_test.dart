import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:juego_5/core/theme/arcade_colors.dart';
import 'package:juego_5/games/perfect_drop/components/moving_block_component.dart';
import 'package:juego_5/games/perfect_drop/controllers/perfect_drop_controller.dart';
import 'package:juego_5/games/perfect_drop/models/block_type.dart';
import 'package:juego_5/games/perfect_drop/models/slice_calculator.dart';
import 'package:juego_5/games/perfect_drop/perfect_drop_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PerfectDrop SliceCalculator Tests', () {
    test('Exact center alignment awards Perfect Drop with combo increment', () {
      final result = SliceCalculator.calculate(
        movingCenterX: 0.0,
        movingWidth: 200.0,
        targetCenterX: 0.0,
        targetWidth: 200.0,
        blockType: BlockType.standard,
        currentCombo: 0,
      );

      expect(result.isPerfect, isTrue);
      expect(result.isMiss, isFalse);
      expect(result.placedCenterX, 0.0);
      expect(result.placedWidth, 200.0);
      expect(result.overhangCenterX, isNull);
      expect(result.overhangWidth, isNull);
      expect(result.combo, 1);
      expect(result.pointsAwarded, greaterThan(0));
    });

    test('Alignment within tolerance still triggers Perfect Drop', () {
      // Tolerance for standard is 3.0
      final result = SliceCalculator.calculate(
        movingCenterX: 2.5,
        movingWidth: 150.0,
        targetCenterX: 0.0,
        targetWidth: 150.0,
        blockType: BlockType.standard,
        currentCombo: 1,
      );

      expect(result.isPerfect, isTrue);
      expect(result.placedCenterX, 0.0);
      expect(result.placedWidth, 150.0);
      expect(result.combo, 2);
    });

    test(
      'Misalignment outside tolerance calculates exact cut and right overhang',
      () {
        // Target [ -50, 50 ] (center 0, width 100)
        // Moving [ -20, 80 ] (center 30, width 100)
        // Overlap: [ -20, 50 ] => width 70, center 15
        // Overhang: [ 50, 80 ] => width 30, center 65
        final result = SliceCalculator.calculate(
          movingCenterX: 30.0,
          movingWidth: 100.0,
          targetCenterX: 0.0,
          targetWidth: 100.0,
          blockType: BlockType.standard,
          currentCombo: 3,
        );

        expect(result.isPerfect, isFalse);
        expect(result.isMiss, isFalse);
        expect(result.placedCenterX, closeTo(15.0, 0.01));
        expect(result.placedWidth, closeTo(70.0, 0.01));
        expect(result.isOverhangOnRight, isTrue);
        expect(result.overhangCenterX, closeTo(65.0, 0.01));
        expect(result.overhangWidth, closeTo(30.0, 0.01));
        expect(result.combo, 0); // Combo breaks
      },
    );

    test('Misalignment to the left calculates exact cut and left overhang', () {
      // Target [ -50, 50 ] (center 0, width 100)
      // Moving [ -80, 20 ] (center -30, width 100)
      // Overlap: [ -50, 20 ] => width 70, center -15
      // Overhang: [ -80, -50 ] => width 30, center -65
      final result = SliceCalculator.calculate(
        movingCenterX: -30.0,
        movingWidth: 100.0,
        targetCenterX: 0.0,
        targetWidth: 100.0,
        blockType: BlockType.standard,
        currentCombo: 0,
      );

      expect(result.isPerfect, isFalse);
      expect(result.isMiss, isFalse);
      expect(result.placedCenterX, closeTo(-15.0, 0.01));
      expect(result.placedWidth, closeTo(70.0, 0.01));
      expect(result.isOverhangOnRight, isFalse);
      expect(result.overhangCenterX, closeTo(-65.0, 0.01));
      expect(result.overhangWidth, closeTo(30.0, 0.01));
    });

    test('Total miss triggers isMiss defeat condition', () {
      // Target [ -50, 50 ]
      // Moving [ 60, 160 ] (center 110, width 100) -> no overlap
      final result = SliceCalculator.calculate(
        movingCenterX: 110.0,
        movingWidth: 100.0,
        targetCenterX: 0.0,
        targetWidth: 100.0,
        blockType: BlockType.standard,
        currentCombo: 1,
      );

      expect(result.isMiss, isTrue);
      expect(result.placedWidth, 0.0);
      expect(result.combo, 0);
    });

    test('Sliver overlap below minSurvivingWidth counts as miss', () {
      // Target [ -50, 50 ]
      // Moving [ 46, 146 ] -> overlap is only 4px (< minSurvivingWidth 8.0)
      final result = SliceCalculator.calculate(
        movingCenterX: 96.0,
        movingWidth: 100.0,
        targetCenterX: 0.0,
        targetWidth: 100.0,
        blockType: BlockType.standard,
        currentCombo: 2,
      );

      expect(result.isMiss, isTrue);
      expect(result.placedWidth, 0.0);
    });

    test('Consecutive perfect combo expands platform slightly up to max', () {
      // Starting from a reduced width of 80.0
      // 2 combos
      final r2 = SliceCalculator.calculate(
        movingCenterX: 0.0,
        movingWidth: 80.0,
        targetCenterX: 0.0,
        targetWidth: 80.0,
        blockType: BlockType.standard,
        currentCombo: 1,
        maxWidth: 200.0,
      );
      expect(r2.combo, 2);
      expect(r2.placedWidth, 80.0);

      // 3rd combo triggers expansion
      final r3 = SliceCalculator.calculate(
        movingCenterX: 0.0,
        movingWidth: 80.0,
        targetCenterX: 0.0,
        targetWidth: 80.0,
        blockType: BlockType.standard,
        currentCombo: 2,
        maxWidth: 200.0,
      );
      expect(r3.combo, 3);
      expect(r3.placedWidth, greaterThan(80.0));
    });
  });

  group('PerfectDrop BlockType & Controller Tests', () {
    test('BlockType values have distinct colors and characteristics', () {
      expect(BlockType.standard.color, ArcadeColors.neonGreen);
      expect(BlockType.speedy.color, ArcadeColors.flashWhite);
      expect(BlockType.heavy.color, ArcadeColors.electricAmber);
      expect(BlockType.elastic.color, ArcadeColors.arcadeMagenta);

      expect(BlockType.speedy.speedMultiplier, greaterThan(1.0));
      expect(BlockType.heavy.speedMultiplier, lessThan(1.0));
      expect(
        BlockType.heavy.perfectTolerance,
        greaterThan(BlockType.standard.perfectTolerance),
      );
    });

    test('PerfectDropController scales speed with tower height and caps at maxSpeed', () {
      final controller = PerfectDropController(seed: 123);
      expect(controller.currentBaseSpeed, PerfectDropController.baseSpeed);

      // Stack 10 blocks
      for (int i = 0; i < 10; i++) {
        controller.incrementHeight();
      }
      expect(
        controller.currentBaseSpeed,
        greaterThan(PerfectDropController.baseSpeed),
      );

      // Stack 60 blocks to hit cap
      for (int i = 0; i < 60; i++) {
        controller.incrementHeight();
      }
      expect(controller.currentBaseSpeed, PerfectDropController.maxSpeed);

      controller.reset();
      expect(controller.towerHeight, 0);
      expect(controller.currentBaseSpeed, PerfectDropController.baseSpeed);
    });

    test('PerfectDropController deterministic block progression with seed', () {
      final controllerA = PerfectDropController(seed: 99);
      final controllerB = PerfectDropController(seed: 99);

      // First 3 are always standard
      for (int i = 0; i < 3; i++) {
        expect(controllerA.nextBlockType(), BlockType.standard);
        expect(controllerB.nextBlockType(), BlockType.standard);
        controllerA.incrementHeight();
        controllerB.incrementHeight();
      }

      // Next 10 blocks should match identically
      for (int i = 0; i < 10; i++) {
        final typeA = controllerA.nextBlockType();
        final typeB = controllerB.nextBlockType();
        expect(typeA, equals(typeB));
        controllerA.incrementHeight();
        controllerB.incrementHeight();
      }
    });
  });

  group('PerfectDrop Component & Persistence Tests', () {
    test('MovingBlockComponent moves dt-based and bounces at boundaries', () {
      final moving = MovingBlockComponent(
        initialX: 0.0,
        centerY: 100.0,
        blockWidth: 100.0,
        blockHeight: 28.0,
        speed: 100.0,
        blockType: BlockType.standard,
        direction: 1,
        minX: -150.0,
        maxX: 150.0,
      );

      // Update 0.5s -> should move to ~50.0
      moving.update(0.5);
      expect(moving.position.x, closeTo(50.0, 1.0));
      expect(moving.direction, 1);

      // Update 2.0s -> reaches boundary (150) and bounces to -1 direction
      moving.update(2.0);
      expect(moving.position.x, lessThanOrEqualTo(150.0));
      expect(moving.direction, -1);
    });

    test(
      'LocalPersistenceService records high score for Perfect Drop',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalPersistenceService(prefs);

        expect(storage.getHighScore(PerfectDropGame.gameId), 0);

        await storage.saveHighScore(PerfectDropGame.gameId, 180);
        expect(storage.getHighScore(PerfectDropGame.gameId), 180);

        // Lower score does not overwrite
        await storage.saveHighScore(PerfectDropGame.gameId, 120);
        expect(storage.getHighScore(PerfectDropGame.gameId), 180);

        // Higher score overwrites
        await storage.saveHighScore(PerfectDropGame.gameId, 250);
        expect(storage.getHighScore(PerfectDropGame.gameId), 250);
      },
    );
  });
}
