import 'package:flutter/material.dart';

/// 画面遷移のトランジションを提供するユーティリティ
///
/// - [forwardRoute]: 次に進む遷移（新しい画面が右からスライドイン）
/// - [backRoute]: 戻る遷移（前の画面が左からスライドイン、戻る感を演出）
class RouteTransitions {
  RouteTransitions._();

  /// 次に進むトランジション（新しい画面が右からスライドイン）
  static PageRoute<T> forwardRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // 右から
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// 戻るトランジション（前の画面が左からスライドイン）
  static PageRoute<T> backRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-0.3, 0.0); // 左から（戻る感を演出）
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
