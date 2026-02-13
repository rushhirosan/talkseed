import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/game_session.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_config.dart';

void main() {
  late SessionConfig config;

  setUp(() {
    config = const SessionConfig(
      playerCount: 3,
      timerDuration: Duration(minutes: 3),
    );
  });

  group('GameSession', () {
    test('startSession sets isActive and resets index/round', () {
      final session = GameSession(
        config: config,
        themes: {},
        currentPlayerIndex: 2,
        currentRound: 2,
        isActive: false,
      );
      session.startSession();
      expect(session.isActive, true);
      expect(session.currentPlayerIndex, 0);
      expect(session.currentRound, 1);
    });

    test('isLastPlayer is true only for last index', () {
      final session = GameSession(config: config, themes: {});
      session.startSession();
      expect(session.currentPlayerIndex, 0);
      expect(session.isLastPlayer, false);
      session.nextPlayer();
      expect(session.currentPlayerIndex, 1);
      expect(session.isLastPlayer, false);
      session.nextPlayer();
      expect(session.currentPlayerIndex, 2);
      expect(session.isLastPlayer, true);
    });

    test('nextPlayer advances index and ends session after last player', () {
      final session = GameSession(config: config, themes: {});
      session.startSession();
      session.nextPlayer();
      expect(session.currentPlayerIndex, 1);
      expect(session.isActive, true);
      session.nextPlayer();
      expect(session.currentPlayerIndex, 2);
      session.nextPlayer();
      expect(session.isActive, false);
    });

    test('addRoundResult appends to rounds', () {
      final session = GameSession(config: config, themes: {});
      session.startSession();
      expect(session.rounds, isEmpty);
      session.addRoundResult('Theme A');
      expect(session.rounds, hasLength(1));
      expect(session.rounds.first.theme, 'Theme A');
      expect(session.rounds.first.playerIndex, 0);
      expect(session.rounds.first.roundNumber, 1);
    });

    test('endSession sets isActive to false', () {
      final session = GameSession(config: config, themes: {});
      session.startSession();
      expect(session.isActive, true);
      session.endSession();
      expect(session.isActive, false);
    });

    test('currentPlayerName returns custom name when provided', () {
      final configWithNames = config.copyWith(
        playerNames: ['Alice', 'Bob', 'Carol'],
      );
      final session = GameSession(config: configWithNames, themes: {});
      session.startSession();
      expect(session.currentPlayerName, 'Alice');
      session.nextPlayer();
      expect(session.currentPlayerName, 'Bob');
      session.nextPlayer();
      expect(session.currentPlayerName, 'Carol');
    });

    test('currentPlayerName returns null when no custom names', () {
      final session = GameSession(config: config, themes: {});
      session.startSession();
      expect(session.currentPlayerName, isNull);
    });
  });

  group('RoundResult', () {
    test('stores all fields', () {
      final result = RoundResult(
        roundNumber: 1,
        playerIndex: 0,
        playerName: 'Alice',
        theme: 'My theme',
        timestamp: DateTime(2025, 2, 1, 12, 0),
      );
      expect(result.roundNumber, 1);
      expect(result.playerIndex, 0);
      expect(result.playerName, 'Alice');
      expect(result.theme, 'My theme');
      expect(result.timestamp, DateTime(2025, 2, 1, 12, 0));
    });
  });
}
