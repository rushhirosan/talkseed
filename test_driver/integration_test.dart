import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final outputDir = Directory('build/monkey_screenshots');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  await integrationDriver(
    onScreenshot: (String name, List<int> bytes,
        [Map<String, Object?>? args]) async {
      final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final file = File('${outputDir.path}/$safeName.png');
      file.writeAsBytesSync(bytes);
      return true;
    },
  );
}
