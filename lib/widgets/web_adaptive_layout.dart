import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 広い画面向けに全体の幅を制限し、中央配置で体験を最適化するラッパー。
/// Web・デスクトップ: 広い画面で中央カード表示。モバイル: 透過。
class WebAdaptiveLayout extends StatelessWidget {
  const WebAdaptiveLayout({
    super.key,
    required this.child,
    this.maxContentWidth = 480,
    this.maxContentHeight,
    this.breakpoint = 640,
  });

  final Widget child;
  /// コンテンツの最大幅（px）
  final double maxContentWidth;
  /// コンテンツの最大高さ（px）。null なら制限なし。
  final double? maxContentHeight;
  /// この幅を超えたら幅制限レイアウトを適用
  final double breakpoint;

  bool get _isWideScreenPlatform =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  Widget build(BuildContext context) {
    if (!_isWideScreenPlatform) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= breakpoint) return child;

        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFEB3B), // mustard yellow (アプリのメイン背景と統一)
                Color(0xFFFFF176),
                Color(0xFFFFE082),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Material(
              elevation: 12,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: maxContentWidth,
                  height: maxContentHeight != null
                      ? constraints.maxHeight.clamp(0, maxContentHeight!)
                      : constraints.maxHeight,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
