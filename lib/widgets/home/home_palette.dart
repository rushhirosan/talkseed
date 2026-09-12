import 'package:flutter/material.dart';

/// アプリ共通のダーク UI パレット（トップ画面・設定・履歴など）
class HomePalette {
  HomePalette._();
  static const bg = Color(0xFF0D0D14);
  static const surface = Color(0xFF16161F);
  static const surface2 = Color(0xFF1E1E2A);
  static const accent = Color(0xFFF5C842);
  static const accentOrange = Color(0xFFFFB347);
  static const accentCoral = Color(0xFFFF6B6B);
  static const purple = Color(0xFFA78BFA);
  static const text = Color(0xFFF0EEF8);

  /// 説明・ヒントなど、読んでほしい補助テキスト（暗背景で AA 目安）
  static const textSecondary = Color(0xFFB8B8D4);

  /// メタ情報・disabled 用（textSecondary より一段弱いが読める）
  static const textMuted = Color(0xFF9A9AB8);
  static const border = Color(0x12FFFFFF);
  static const headerBg = Color(0xCC0D0D14);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentOrange],
  );

  static const logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentOrange],
  );

  static const randomButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentOrange],
  );
}
