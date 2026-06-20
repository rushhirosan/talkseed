import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/services/self_reflection_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SelfReflectionService', () {
    test('loadSessionPhases returns Japanese prompts for ja', () async {
      final phases = await SelfReflectionService.loadSessionPhases(
        languageCode: 'ja',
      );
      final checkin = phases[OneOnOnePhase.checkin]!;
      expect(checkin.first, contains('エネルギー'));
    });

    test('loadSessionPhases merges work and motivation sections', () async {
      final phases = await SelfReflectionService.loadSessionPhases(
        languageCode: 'ja',
      );
      final work = phases[OneOnOnePhase.workAndWorkstyle]!;
      expect(work.length, greaterThan(10));
      expect(work.any((q) => q.contains('優先順位')), isTrue);
      expect(work.any((q) => q.contains('ストレス')), isTrue);
    });

    test('loadSessionPhases returns English prompts for en', () async {
      final phases = await SelfReflectionService.loadSessionPhases(
        languageCode: 'en',
      );
      final checkin = phases[OneOnOnePhase.checkin]!;
      expect(checkin.first, contains('energy'));
      expect(checkin.first, isNot(contains('エネルギー')));
    });

    test('loadSessionPhases falls back to English for unknown locale', () async {
      final phases = await SelfReflectionService.loadSessionPhases(
        languageCode: 'fr',
      );
      final checkin = phases[OneOnOnePhase.checkin]!;
      expect(checkin.first, contains('energy'));
    });
  });
}
