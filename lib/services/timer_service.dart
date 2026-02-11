import 'dart:async';
import 'package:flutter/material.dart';

/// タイマー機能を提供するサービスクラス
class TimerService {
  Timer? _timer;
  Duration _remainingTime;
  final VoidCallback? onTick;
  final VoidCallback? onFinished;
  bool _isPaused = false;
  
  TimerService({
    required Duration initialDuration,
    this.onTick,
    this.onFinished,
  }) : _remainingTime = initialDuration;
  
  /// タイマーを開始
  void start() {
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
        onFinished?.call();
      }
    });
  }
  
  /// タイマーを一時停止
  void pause() {
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
  }
  
  /// タイマーをリセット
  void reset(Duration duration) {
    stop();
    _remainingTime = duration;
  }
  
  /// 残り時間を取得
  Duration get remainingTime => _remainingTime;
  
  /// タイマーが動作中かどうか
  bool get isRunning => _timer?.isActive ?? false;
  
  /// タイマーが一時停止中かどうか
  bool get isPaused => _isPaused;
  
  /// リソースを解放
  void dispose() {
    _timer?.cancel();
  }
}
