import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/session_config.dart';

void main() {
  group('SessionConfig', () {
    test('defaultConfig has expected values', () {
      const config = SessionConfig.defaultConfig;
      expect(config.playMode, PlayMode.dice);
      expect(config.playerCount, 4);
      expect(config.timerDuration, const Duration(minutes: 3));
      expect(config.enableTimer, true);
      expect(config.playerNames, isNull);
    });

    test('getPlayerName returns null when playerNames is null', () {
      const config = SessionConfig(
        playerCount: 4,
        timerDuration: Duration(minutes: 3),
      );
      expect(config.getPlayerName(0), isNull);
      expect(config.getPlayerName(3), isNull);
    });

    test('getPlayerName returns null for empty string in playerNames', () {
      const config = SessionConfig(
        playerCount: 2,
        timerDuration: Duration(minutes: 3),
        playerNames: ['Alice', ''],
      );
      expect(config.getPlayerName(0), 'Alice');
      expect(config.getPlayerName(1), isNull);
    });

    test('getPlayerName returns name when within bounds', () {
      const config = SessionConfig(
        playerCount: 2,
        timerDuration: Duration(minutes: 3),
        playerNames: ['Alice', 'Bob'],
      );
      expect(config.getPlayerName(0), 'Alice');
      expect(config.getPlayerName(1), 'Bob');
    });

    test('getPlayerName returns null when index >= length', () {
      const config = SessionConfig(
        playerCount: 2,
        timerDuration: Duration(minutes: 3),
        playerNames: ['Alice', 'Bob'],
      );
      expect(config.getPlayerName(2), isNull);
    });

    test('getPlayerName with negative index throws RangeError', () {
      const config = SessionConfig(
        playerCount: 2,
        timerDuration: Duration(minutes: 3),
        playerNames: ['Alice', 'Bob'],
      );
      expect(() => config.getPlayerName(-1), throwsRangeError);
    });

    test('copyWith preserves unspecified fields', () {
      const config = SessionConfig(
        playMode: PlayMode.dice,
        playerCount: 4,
        timerDuration: Duration(minutes: 5),
        enableTimer: true,
      );
      final copied = config.copyWith(playerCount: 6);
      expect(copied.playerCount, 6);
      expect(copied.playMode, config.playMode);
      expect(copied.timerDuration, config.timerDuration);
      expect(copied.enableTimer, config.enableTimer);
    });

    test('copyWith updates timerDuration', () {
      const config = SessionConfig(
        playerCount: 4,
        timerDuration: Duration(minutes: 3),
      );
      final copied = config.copyWith(timerDuration: const Duration(minutes: 10));
      expect(copied.timerDuration, const Duration(minutes: 10));
    });

    test('constructor asserts playerCount 2-10', () {
      expect(
        () => SessionConfig(
          playerCount: 1,
          timerDuration: Duration.zero,
        ),
        throwsAssertionError,
      );
      expect(
        () => SessionConfig(
          playerCount: 11,
          timerDuration: Duration.zero,
        ),
        throwsAssertionError,
      );
    });

    test('constructor accepts playerCount 2 and 10', () {
      expect(
        SessionConfig(
          playerCount: 2,
          timerDuration: Duration.zero,
        ).playerCount,
        2,
      );
      expect(
        SessionConfig(
          playerCount: 10,
          timerDuration: Duration.zero,
        ).playerCount,
        10,
      );
    });
  });
}
