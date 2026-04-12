import 'package:flutter/material.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

/// タイマー表示ウィジェット
class TimerDisplay extends StatelessWidget {
  final TimerService? timerService;
  final bool showControls;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  /// 終了後に [TimerService.addTime] と [TimerService.start] を呼ぶ延長（null なら非表示）
  final VoidCallback? onExtendOneMinute;

  const TimerDisplay({
    super.key,
    this.timerService,
    this.showControls = true,
    this.onPause,
    this.onResume,
    this.onExtendOneMinute,
  });
  
  // カラーパレット（設定画面と統一）
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _timeUpBorder = Color(0xFFC62828);
  static const Color _timeUpBg = Color(0xFFFFEBEE);
  
  /// 残り時間を文字列に変換（MM:SS形式）
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// 残り時間に応じた色を取得
  Color _getTimerColor(Duration remainingTime) {
    final totalSeconds = remainingTime.inSeconds;
    if (totalSeconds <= 10) {
      return Colors.red;
    } else if (totalSeconds <= 30) {
      return Colors.orange;
    }
    return _black;
  }
  
  @override
  Widget build(BuildContext context) {
    if (timerService == null) {
      return const SizedBox.shrink();
    }
    
    final l10n = AppLocalizations.of(context)!;
    final remainingTime = timerService!.remainingTime;
    final isRunning = timerService!.isRunning;
    final isPaused = timerService!.isPaused;
    final timeUp = timerService!.hasFinished;

    final borderColor = timeUp ? _timeUpBorder : _black;
    final bgColor = timeUp ? _timeUpBg : _white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: timeUp ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatDuration(remainingTime),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: timeUp
                      ? _timeUpBorder
                      : _getTimerColor(remainingTime),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (showControls && !timeUp) ...[
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRunning && !isPaused)
                      IconButton(
                        icon: const Icon(Icons.pause, color: _black, size: 22),
                        iconSize: 22,
                        padding: const EdgeInsets.all(6),
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: onPause,
                        tooltip: l10n.pause,
                      )
                    else if (isPaused)
                      IconButton(
                        icon:
                            const Icon(Icons.play_arrow, color: _black, size: 22),
                        iconSize: 22,
                        padding: const EdgeInsets.all(6),
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: onResume,
                        tooltip: l10n.resume,
                      ),
                  ],
                ),
              ],
            ],
          ),
          if (timeUp) ...[
            const SizedBox(height: 4),
            Text(
              l10n.timerTimeUp,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _timeUpBorder,
              ),
            ),
            if (onExtendOneMinute != null) ...[
              const SizedBox(height: 2),
              TextButton(
                onPressed: onExtendOneMinute,
                style: TextButton.styleFrom(
                  foregroundColor: _timeUpBorder,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.timerExtendOneMinute),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
