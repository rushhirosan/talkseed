import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';

/// カードを引くアニメーション付きウィジェット
/// - 裏向きカードをタップで引く
/// - スライド＆フリップでオモテを表示
/// - 自己内省デッキでは category 指定で色・アイコンを変えられる
/// - チェックイン・チェックアウトでは levelLabel で初級/中級/上級を表示
class CardDrawWidget extends StatefulWidget {
  /// 引いたテーマ（null = 未引く）
  final String? theme;

  /// カードを引くリクエスト（親がテーマを選んで setState する）
  final VoidCallback onDrawRequest;

  /// テーマが空で引けない場合
  final bool canDraw;

  /// 自己内省・1on1用：テーマのカテゴリ（色・アイコンを変える）
  final ReflectionDeckCategory? category;

  /// チェックイン・チェックアウト用：難易度ラベル（初級・中級・上級）
  final String? levelLabel;

  const CardDrawWidget({
    super.key,
    this.theme,
    required this.onDrawRequest,
    this.canDraw = true,
    this.category,
    this.levelLabel,
  });

  @override
  State<CardDrawWidget> createState() => _CardDrawWidgetState();
}

class _CardDrawWidgetState extends State<CardDrawWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _slideAnimation;

  String? _previousTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(CardDrawWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != null &&
        widget.theme != _previousTheme &&
        widget.theme != oldWidget.theme) {
      _previousTheme = widget.theme;
      _controller.forward(from: 0);
    }
    if (widget.theme == null) {
      _previousTheme = null;
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.canDraw) return;
    if (widget.theme != null) return; // すでに引いている
    widget.onDrawRequest();
  }

  static const Color _black = Colors.black87;
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasTheme = widget.theme != null;
    final isAnimating = _controller.isAnimating;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 280,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // デッキ（裏の山）
                if (hasTheme || isAnimating)
                  Positioned(
                    bottom: 8,
                    child: _buildCardBack(opacity: 0.6, scale: 0.92),
                  ),
                // メインカード（引く時は下からスライドアップ）
                Transform.translate(
                  offset: Offset(
                    0,
                    (hasTheme || isAnimating)
                        ? 24 * (1 - _slideAnimation.value)
                        : 0,
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(math.pi * _flipAnimation.value),
                    child: _flipAnimation.value < 0.5
                        ? _buildCardBack()
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: _buildCardFace(
                              widget.theme ?? '',
                              l10n,
                              widget.category,
                              widget.levelLabel,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack({double opacity = 1, double scale = 1}) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 260,
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF37474F),
                const Color(0xFF455A64),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _black.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: _black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.style,
              size: 48,
              color: _white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(
    String theme,
    AppLocalizations l10n, [
    ReflectionDeckCategory? category,
    String? levelLabel,
  ]) {
    final showPlaceholder = theme.isEmpty;
    final style = category != null
        ? ReflectionDeckCategoryStyle.forCategory(category)
        : null;

    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        color: style?.color ?? _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (levelLabel != null && levelLabel.isNotEmpty) ...[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    levelLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (style != null && !showPlaceholder) ...[
              Icon(style.icon, size: 24, color: _black.withOpacity(0.7)),
              const SizedBox(height: 8),
            ],
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: showPlaceholder
                      ? Text(
                          l10n.selectThemePromptCard,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: _black.withOpacity(0.6),
                          ),
                        )
                      : Text(
                          theme,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _black,
                            height: 1.3,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
