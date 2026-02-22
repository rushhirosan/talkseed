import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:theme_dice/main.dart' as app;

void main() {
  final binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized()
          as IntegrationTestWidgetsFlutterBinding;
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  const steps = int.fromEnvironment('MONKEY_STEPS', defaultValue: 250);
  const seed = int.fromEnvironment('MONKEY_SEED', defaultValue: 42);
  const screenshotEvery =
      int.fromEnvironment('MONKEY_SCREENSHOT_EVERY', defaultValue: 25);

  testWidgets('monkey test (crash + UX regressions)', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    final random = Random(seed);
    final view = tester.view;
    final screenSize = view.physicalSize / view.devicePixelRatio;

    for (var i = 0; i < steps; i++) {
      await _performRandomAction(
        tester,
        random,
        screenSize,
      );

      await tester.pump(const Duration(milliseconds: 200));

      if (screenshotEvery > 0 && i % screenshotEvery == 0) {
        await _safeScreenshot(binding, 'monkey_step_$i');
      }
    }
  });
}

Future<void> _performRandomAction(
  WidgetTester tester,
  Random random,
  Size screenSize,
) async {
  final action = random.nextInt(5);

  switch (action) {
    case 0:
      await _randomTap(tester, random, screenSize);
      break;
    case 1:
      await _randomScroll(tester, random, screenSize);
      break;
    case 2:
      await _randomTextEntry(tester, random);
      break;
    case 3:
      await _randomBack(tester);
      break;
    case 4:
    default:
      await _randomTapAnywhere(tester, random, screenSize);
      break;
  }
}

Future<void> _randomTap(
  WidgetTester tester,
  Random random,
  Size screenSize,
) async {
  final candidates = <Element>[];

  for (final element in tester.allElements) {
    final widget = element.widget;
    if (widget is IconButton ||
        widget is TextButton ||
        widget is ElevatedButton ||
        widget is OutlinedButton ||
        widget is FloatingActionButton ||
        widget is InkWell ||
        widget is GestureDetector ||
        widget is ListTile ||
        widget is Switch ||
        widget is Checkbox ||
        widget is Radio ||
        widget is DropdownButton ||
        widget is PopupMenuButton) {
      if (_isVisible(tester, element, screenSize)) {
        candidates.add(element);
      }
    }
  }

  if (candidates.isEmpty) {
    await _randomTapAnywhere(tester, random, screenSize);
    return;
  }

  final element = candidates[random.nextInt(candidates.length)];
  final rect = _elementRect(element);
  if (rect == null) return;

  await _safeAction(() => tester.tapAt(rect.center));
}

Future<void> _randomTapAnywhere(
  WidgetTester tester,
  Random random,
  Size screenSize,
) async {
  final x = random.nextDouble() * screenSize.width;
  final y = random.nextDouble() * screenSize.height;
  await _safeAction(() => tester.tapAt(Offset(x, y)));
}

Future<void> _randomScroll(
  WidgetTester tester,
  Random random,
  Size screenSize,
) async {
  final scrollables = find.byType(Scrollable).evaluate().toList();
  if (scrollables.isEmpty) return;

  final element = scrollables[random.nextInt(scrollables.length)];
  if (!_isVisible(tester, element, screenSize)) return;

  final rect = _elementRect(element);
  if (rect == null) return;

  final dx = (random.nextDouble() - 0.5) * rect.width * 0.6;
  final dy = (random.nextDouble() - 0.5) * rect.height * 0.6;

  await _safeAction(() => tester.dragFrom(rect.center, Offset(dx, dy)));
}

Future<void> _randomTextEntry(
  WidgetTester tester,
  Random random,
) async {
  final fields = find.byType(EditableText).evaluate().toList();
  if (fields.isEmpty) return;

  final element = fields[random.nextInt(fields.length)];
  await _safeAction(() async {
    final finder = find.byElementPredicate((e) => e == element);
    await tester.tap(finder);
    await tester.enterText(finder, _randomString(random, 8));
  });
}

Future<void> _randomBack(WidgetTester tester) async {
  await _safeAction(() => tester.pageBack());
}

String _randomString(Random random, int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(
    length,
    (_) => chars[random.nextInt(chars.length)],
  ).join();
}

Rect? _elementRect(Element element) {
  final renderObject = element.renderObject;
  if (renderObject is! RenderBox || !renderObject.hasSize) {
    return null;
  }

  final topLeft = renderObject.localToGlobal(Offset.zero);
  return topLeft & renderObject.size;
}

bool _isVisible(
  WidgetTester tester,
  Element element,
  Size screenSize,
) {
  final rect = _elementRect(element);
  if (rect == null) return false;

  final screenRect = Offset.zero & screenSize;
  if (!rect.overlaps(screenRect)) return false;

  // Ignore elements that are mostly off-screen.
  final visibleRect = rect.intersect(screenRect);
  return visibleRect.width * visibleRect.height >
      (rect.width * rect.height * 0.2);
}

Future<void> _safeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await _safeAction(() => binding.takeScreenshot(name));
}

Future<void> _safeAction(Future<void> Function() action) async {
  try {
    await action();
  } catch (e) {
    // Ignore invalid taps/scrolls so the monkey test continues.
    debugPrint('Monkey action skipped: $e');
  }
}
