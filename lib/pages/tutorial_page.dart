import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../utils/preferences_helper.dart';
import 'dart:math' as math;

/// チュートリアル画面
class TutorialPage extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialPage({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // デザインの色定義（Figmaデザインのテイストに合わせて調整）
  static const Color _purpleBackground = Color(0xFF4F20D1); // 明るい紫色（Figmaデザインに合わせて）
  static const Color _yellowBanner = Color(0xFFFFEB3B); // 黄色
  static const Color _whiteText = Colors.white;

  // チュートリアルページのデータ
  List<TutorialPageData>? _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pages == null) {
      final l10n = AppLocalizations.of(context)!;
      _pages = [
        TutorialPageData(
          title: l10n.tutorialWelcome,
          body: l10n.tutorialWelcomeBody,
          icon: Icons.casino,
          icon2: Icons.style,
        ),
        TutorialPageData(
          title: l10n.tutorialSetTheme,
          body: l10n.tutorialSetThemeBody,
          icon: Icons.edit,
        ),
        TutorialPageData(
          title: l10n.tutorialRollDice,
          body: l10n.tutorialRollDiceBody,
          icon: Icons.play_arrow,
        ),
        TutorialPageData(
          title: l10n.tutorialCards,
          body: l10n.tutorialCardsBody,
          icon: Icons.style,
        ),
        TutorialPageData(
          title: l10n.tutorialChangeSettings,
          body: l10n.tutorialChangeSettingsBody,
          icon: Icons.settings,
        ),
        TutorialPageData(
          title: l10n.tutorialReady,
          body: l10n.tutorialReadyBody,
          icon: Icons.check_circle,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    final pages = _pages;
    if (pages != null && _currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeTutorial() async {
    await PreferencesHelper.setFirstLaunchCompleted();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages ?? [];
    
    if (pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
        backgroundColor: _purpleBackground,
        body: SafeArea(
        child: Column(
          children: [
            // スキップボタン
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _completeTutorial,
                    child: Text(
                      l10n.skip,
                      style: const TextStyle(
                        color: _whiteText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ページビュー
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                physics: const PageScrollPhysics(), // ページスクロールの物理挙動を明示
                itemBuilder: (context, index) {
                  return _buildTutorialPage(pages[index]);
                },
              ),
            ),
            // ページインジケーターとナビゲーションボタン
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // ページインジケーター
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ナビゲーションボタン
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 戻るボタン
                      IconButton(
                        onPressed: _currentPage > 0 ? _previousPage : null,
                        icon: const Icon(Icons.arrow_back, color: _whiteText),
                        disabledColor: _whiteText.withOpacity(0.3),
                      ),
                      // 次へ/完了ボタン
                      FilledButton(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          backgroundColor: _yellowBanner,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentPage < pages.length - 1
                              ? 'Next'
                              : l10n.start,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
    );
  }

  Widget _buildTutorialPage(TutorialPageData pageData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面サイズに応じてレイアウトを調整
        final isSmallScreen = constraints.maxHeight < 700;
        
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(), // PageViewのスクロールと競合しないように
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Row(
                children: [
                  // 左側: テキストコンテンツ
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 黄色のバナー（少し回転）- Figmaデザインのテイスト
                        Transform.rotate(
                          angle: -0.1, // 約-6度
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _yellowBanner,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Talk Seed',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 32 : 48),
                        // メインタイトル - Figmaデザインのテイスト
                        Text(
                          pageData.title,
                          style: TextStyle(
                            color: _whiteText,
                            fontSize: isSmallScreen ? 42 : 56,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        // 本文
                        Text(
                          pageData.body,
                          style: TextStyle(
                            color: _whiteText.withOpacity(0.95),
                            fontSize: isSmallScreen ? 18 : 20,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 24 : 40),
                        // バージョン情報 - Figmaデザインのテイスト（左下に配置）
                        Text(
                          'v1.0 | ${DateTime.now().year}',
                          style: TextStyle(
                            color: _whiteText.withOpacity(0.75),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 32 : 48),
                  // 右側: アイコン/イラスト - デザインのテイストに合わせて調整
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: pageData.icon2 != null
                          ? Transform.rotate(
                              angle: -0.1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildIconCircle(
                                    pageData.icon,
                                    size: isSmallScreen ? 88 : 110,
                                    iconSize: isSmallScreen ? 44 : 56,
                                  ),
                                  SizedBox(height: isSmallScreen ? 12 : 20),
                                  _buildIconCircle(
                                    pageData.icon2!,
                                    size: isSmallScreen ? 88 : 110,
                                    iconSize: isSmallScreen ? 44 : 56,
                                  ),
                                ],
                              ),
                            )
                          : Transform.rotate(
                              angle: -0.1,
                              child: _buildIconCircle(
                                pageData.icon,
                                size: isSmallScreen ? 180 : 240,
                                iconSize: isSmallScreen ? 90 : 120,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconCircle(
    IconData icon, {
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _whiteText.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: _whiteText.withOpacity(0.25),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: _whiteText.withOpacity(0.9),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _yellowBanner : _whiteText.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// チュートリアルページのデータ
class TutorialPageData {
  final String title;
  final String body;
  final IconData icon;
  /// 1ページ目など、2つアイコンを並べる場合は指定（例: サイコロ＋カード）
  final IconData? icon2;

  TutorialPageData({
    required this.title,
    required this.body,
    required this.icon,
    this.icon2,
  });
}
