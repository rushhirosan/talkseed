import 'dart:async';
import 'package:flutter/material.dart';

/// タイマー機能を提供するサービスクラス
class TimerService {
  /// 設定 UI の「無制限」。プリセット互換のため 1 時間をセンチネルに使う。
  static const Duration unlimitedDuration = Duration(hours: 1);

  Timer? _timer;
  Duration _remainingTime;
  final VoidCallback? onTick;
  final VoidCallback? onFinished;
  bool _isPaused = false;

  /// カウントダウンが 0 になって自然終了したとき true（[reset] や [addTime] で false）
  bool _finished = false;

  /// 無制限モードで「動作中」扱い（実カウントはしない）
  bool _unlimitedActive = false;
  bool _unlimited;

  TimerService({
    required Duration initialDuration,
    this.onTick,
    this.onFinished,
  })  : _remainingTime = initialDuration,
        _unlimited = initialDuration == unlimitedDuration;

  /// 「無制限」として扱っているか
  bool get isUnlimited => _unlimited;

  /// タイマーを開始
  void start() {
    if (_unlimited) {
      _isPaused = false;
      _finished = false;
      _timer?.cancel();
      _timer = null;
      _unlimitedActive = true;
      return;
    }

    if (_isPaused) {
      _isPaused = false;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        onTick?.call();
      } else {
        stop();
        _finished = true;
        onFinished?.call();
      }
    });
  }

  /// タイマーを一時停止
  void pause() {
    if (_unlimited) {
      _unlimitedActive = false;
      _isPaused = true;
      return;
    }
    _timer?.cancel();
    _isPaused = true;
  }

  /// タイマーを再開
  void resume() {
    if (_isPaused) {
      start();
    }
  }

  /// タイマーを停止
  void stop() {
    _timer?.cancel();
    _isPaused = false;
    _unlimitedActive = false;
  }

  /// タイマーをリセット
  void reset(Duration duration) {
    stop();
    _remainingTime = duration;
    _unlimited = duration == unlimitedDuration;
    _finished = false;
  }

  /// 残り時間を増やす（延長）。自然終了フラグを解除する。
  void addTime(Duration extra) {
    if (_unlimited) {
      return;
    }
    final seconds = _remainingTime.inSeconds + extra.inSeconds;
    _remainingTime =
        seconds <= 0 ? Duration.zero : Duration(seconds: seconds);
    _finished = false;
  }

  /// カウントダウン終了後、まだ [reset] / [addTime] されていない状態か
  bool get hasFinished => _finished;

  /// 残り時間を取得
  Duration get remainingTime => _remainingTime;

  /// タイマーが動作中かどうか
  bool get isRunning =>
      _unlimited ? _unlimitedActive && !_isPaused : (_timer?.isActive ?? false);

  /// タイマーが一時停止中かどうか
  bool get isPaused => _isPaused;

  /// リソースを解放
  void dispose() {
    _timer?.cancel();
  }
}
