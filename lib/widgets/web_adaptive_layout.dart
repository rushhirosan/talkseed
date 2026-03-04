import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web 向けに画面幅を制限し、中央配置と背景デザインで体験を最適化するラッパー。
/// モバイルでは透過（そのまま表示）。Web + 広い画面では中央に最大幅のコンテナで表示。
class WebAdaptiveLayout extends StatelessWidget {
  const WebAdaptiveLayout({
    super.key,
    required this.child,
    this.maxContentWidth = 480,
    this.maxContentHeight,
    this.breakpoint = 640,
  });

  final Widget child;
  /// コンテンツの最大幅（px）。モバイルアプリの自然な幅を維持。
  final double maxContentWidth;
  /// コンテンツの最大高さ（px）。null なら制限なし。
  final double? maxContentHeight;
  /// この幅を超えたら Web 向けレイアウトを適用
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

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
