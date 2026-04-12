import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import 'package:theme_dice/utils/preferences_helper.dart';

/// タイマー終了時のフィードバック（バイブと通知音は別設定）
class TimerFeedback {
  TimerFeedback._();

  static Future<void> play() async {
    final vibrationOn = await PreferencesHelper.loadVibrationEnabled();
    if (vibrationOn) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 150);
      }
    }
    final soundOn = await PreferencesHelper.loadTimerSoundEnabled();
    if (soundOn) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
