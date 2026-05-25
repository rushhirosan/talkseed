import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_dice/services/review_prompt_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ReviewPromptService.resetForTesting();
  });

  tearDown(() async {
    await ReviewPromptService.resetForTesting();
  });

  test('increments session count on each completion', () async {
    await ReviewPromptService.onSessionCompleted();
    await ReviewPromptService.onSessionCompleted();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('completed_session_count'), 2);
    expect(prefs.getBool('has_requested_review'), isNull);
  });

  test('does not set review flag before 3rd session', () async {
    await ReviewPromptService.onSessionCompleted();
    await ReviewPromptService.onSessionCompleted();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_requested_review'), isNull);
  });
}
