import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego_5/core/storage/local_persistence_service.dart';
import 'package:juego_5/games/split_second/components/dual_entity_component.dart';
import 'package:juego_5/games/split_second/components/split_hazard_component.dart';
import 'package:juego_5/games/split_second/components/synergy_orb_component.dart';
import 'package:juego_5/games/split_second/controllers/split_second_controller.dart';
import 'package:juego_5/games/split_second/models/track_side.dart';
import 'package:juego_5/games/split_second/split_second_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Split Second - TrackSide & DualEntity Mechanics Tests', () {
    test('TrackSide defines correct centers and lane coordinates', () {
      expect(TrackSide.leftTrack.centerX, equals(112.5));
      expect(TrackSide.rightTrack.centerX, equals(337.5));

      // Carril interior vs exterior en pista izquierda
      expect(TrackSide.leftTrack.laneX(true), equals(112.5 + 55.0)); // 167.5
      expect(TrackSide.leftTrack.laneX(false), equals(112.5 - 55.0)); // 57.5

      // Carril interior vs exterior en pista derecha
      expect(TrackSide.rightTrack.laneX(true), equals(337.5 - 55.0)); // 282.5
      expect(TrackSide.rightTrack.laneX(false), equals(337.5 + 55.0)); // 392.5
    });

    test('DualEntityComponent toggles lane and updates target position', () {
      final leftEntity = DualEntityComponent(
        trackSide: TrackSide.leftTrack,
        isInner: false,
      );

      expect(leftEntity.isInner, isFalse);
      expect(leftEntity.targetX, equals(57.5));
      expect(leftEntity.position.x, equals(57.5));

      // Acción de evasión
      leftEntity.toggleLane();
      expect(leftEntity.isInner, isTrue);
      expect(leftEntity.targetX, equals(167.5));

      // dt-based update interpola hacia targetX
      leftEntity.update(0.05);
      expect(leftEntity.position.x, greaterThan(57.5));
      expect(leftEntity.position.x, lessThanOrEqualTo(167.5));
    });

    test('Synchronized primary action toggles both entities together', () {
      final leftEntity = DualEntityComponent(
        trackSide: TrackSide.leftTrack,
        isInner: false,
      );
      final rightEntity = DualEntityComponent(
        trackSide: TrackSide.rightTrack,
        isInner: false,
      );

      expect(leftEntity.isInner, isFalse);
      expect(rightEntity.isInner, isFalse);

      // Simular primary action que commuta ambas
      leftEntity.toggleLane();
      rightEntity.toggleLane();

      expect(leftEntity.isInner, isTrue);
      expect(rightEntity.isInner, isTrue);
    });
  });

  group('Split Second - Hazards & Synergy Orb Components Tests', () {
    test(
      'SplitHazardComponent initializes with RectangleHitbox and track info',
      () async {
        final hazard = SplitHazardComponent(
          trackSide: TrackSide.leftTrack,
          isInner: true,
          position: Vector2(167.5, 100.0),
        );
        await hazard.onLoad();

        expect(hazard.children.whereType<RectangleHitbox>().length, equals(1));
        expect(hazard.trackSide, equals(TrackSide.leftTrack));
        expect(hazard.isInner, isTrue);
      },
    );

    test('SynergyOrbComponent initializes with CircleHitbox', () async {
      final orb = SynergyOrbComponent(
        trackSide: TrackSide.rightTrack,
        isInner: false,
        position: Vector2(392.5, 80.0),
      );
      await orb.onLoad();

      expect(orb.children.whereType<CircleHitbox>().length, equals(1));
      expect(orb.isCollected, isFalse);
    });
  });

  group('Split Second - Controller & Difficulty Scaling Tests', () {
    test(
      'SplitSecondController scales speed with time and caps at maxSpeed',
      () {
        final controller = SplitSecondController();
        expect(
          controller.currentScrollSpeed,
          equals(SplitSecondController.baseScrollSpeed),
        );

        controller.update(10.0);
        expect(
          controller.currentScrollSpeed,
          greaterThan(SplitSecondController.baseScrollSpeed),
        );

        controller.update(200.0);
        expect(
          controller.currentScrollSpeed,
          equals(SplitSecondController.maxScrollSpeed),
        );
      },
    );

    test(
      'SplitSecondController procedural generation is deterministic with seed',
      () {
        final controllerA = SplitSecondController(seed: 99);
        final controllerB = SplitSecondController(seed: 99);

        List<SplitHazardConfig> hazardsA = [];
        List<SplitHazardConfig> hazardsB = [];

        for (int i = 0; i < 120; i++) {
          controllerA.update(0.016);
          controllerB.update(0.016);
          hazardsA.addAll(
            controllerA.checkHazardSpawns(
              0.016,
              leftPlayerInner: false,
              rightPlayerInner: false,
            ),
          );
          hazardsB.addAll(
            controllerB.checkHazardSpawns(
              0.016,
              leftPlayerInner: false,
              rightPlayerInner: false,
            ),
          );
        }

        expect(hazardsA.length, greaterThan(0));
        expect(hazardsA.length, equals(hazardsB.length));

        for (int i = 0; i < hazardsA.length; i++) {
          expect(hazardsA[i].trackSide, equals(hazardsB[i].trackSide));
          expect(hazardsA[i].isInner, equals(hazardsB[i].isInner));
          expect(hazardsA[i].y, equals(hazardsB[i].y));
        }
      },
    );
  });

  group('Split Second - Persistence Tests', () {
    test(
      'LocalPersistenceService records high score for Split Second',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalPersistenceService(prefs);

        expect(storage.getHighScore(SplitSecondGame.gameId), equals(0));

        final saved = await storage.saveHighScore(SplitSecondGame.gameId, 650);
        expect(saved, isTrue);
        expect(storage.getHighScore(SplitSecondGame.gameId), equals(650));

        final lowerAttempt = await storage.saveHighScore(
          SplitSecondGame.gameId,
          400,
        );
        expect(lowerAttempt, isFalse);
        expect(storage.getHighScore(SplitSecondGame.gameId), equals(650));
      },
    );
  });
}
