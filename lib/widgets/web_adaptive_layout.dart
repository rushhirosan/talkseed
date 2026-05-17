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

    // LayoutBuilder は子画面側と入れ子にすると戻る遷移時に mutation エラーになりやすいため MediaQuery を使う
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    if (!width.isFinite || width <= 0 || !height.isFinite || height <= 0) {
      return child;
    }
    if (width <= breakpoint) return child;

    final effectiveWidth =
        (width - 80).clamp(120.0, maxContentWidth).toDouble();

    final double innerHeight;
    if (maxContentHeight == null) {
      innerHeight = height.isFinite ? height : 900.0;
    } else if (!height.isFinite) {
      innerHeight = maxContentHeight!;
    } else {
      innerHeight = height.clamp(120.0, maxContentHeight!);
    }

    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F6F8),
            Color(0xFFE8EAED),
            Color(0xFFE1E4E8),
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
              height: innerHeight,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
