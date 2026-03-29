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
        final height = constraints.maxHeight;
        // 制約が不正な場合（初回レイアウト等）は子をそのまま返す
        if (!width.isFinite || width <= 0 || !height.isFinite || height <= 0) {
          return child;
        }
        if (width <= breakpoint) return child;

        // 広い画面では余白を残しつつ maxContentWidth まで拡大
        final effectiveWidth =
            (width - 80).clamp(0.0, maxContentWidth).toDouble();

        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            // Web向け: 黄色と重ならない落ち着いた中性色。アプリ内の黄色アクセントが際立つ
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF5F6F8), // 明るいグレー
                Color(0xFFE8EAED), // ソフトグレー
                Color(0xFFE1E4E8), // やや濃いめのグレー
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Material(
              elevation: 16,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: effectiveWidth,
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
