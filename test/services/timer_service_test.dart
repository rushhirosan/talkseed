import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/services/timer_service.dart';

void main() {
  group('TimerService', () {
    test('initial remainingTime equals initialDuration', () {
      final service = TimerService(
        initialDuration: const Duration(seconds: 60),
      );
      expect(service.remainingTime, const Duration(seconds: 60));
      service.dispose();
    });

    test('reset updates remainingTime', () {
      final service = TimerService(
        initialDuration: const Duration(seconds: 30),
      );
      service.reset(const Duration(seconds: 90));
      expect(service.remainingTime, const Duration(seconds: 90));
      service.dispose();
    });

    test('isRunning is false before start', () {
      final service = TimerService(
        initialDuration: const Duration(seconds: 60),
      );
      expect(service.isRunning, false);
      expect(service.isPaused, false);
      service.dispose();
    });

    test('stop clears timer', () {
      final service = TimerService(
        initialDuration: const Duration(seconds: 60),
      );
      service.start();
      expect(service.isRunning, true);
      service.stop();
      expect(service.isRunning, false);
      service.dispose();
    });

    test('pause sets isPaused', () {
      final service = TimerService(
        initialDuration: const Duration(seconds: 60),
      );
      service.start();
      service.pause();
      expect(service.isPaused, true);
      expect(service.isRunning, false);
      service.dispose();
    });

    test('resume after pause restarts timer', () {
      final service = TimerService(
        initialDuration: const Duration(seconds: 60),
      );
      service.start();
      service.pause();
      expect(service.isRunning, false);
      service.resume();
      expect(service.isRunning, true);
      service.dispose();
    });

    test('onFinished is called when time reaches zero', () async {
      var finished = false;
      final service = TimerService(
        initialDuration: const Duration(seconds: 1),
        onFinished: () => finished = true,
      );
      service.start();
      expect(finished, false);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      expect(finished, true);
      service.dispose();
    });
  });
}
