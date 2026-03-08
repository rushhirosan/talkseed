import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../utils/preferences_helper.dart';
import 'dart:math' as math;

/// チュートリアル画面
class TutorialPage extends StatefulWidget {
  final VoidCallback onComplete;
  /// true のときサイコロ関連のみ表示（カードの説明を除外）
  final bool diceOnly;

  const TutorialPage({
    super.key,
    required this.onComplete,
    this.diceOnly = false,
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
      // 「テーマを設定しよう」「設定を変更する」は不要のため除外
      final dicePages = [
        TutorialPageData(
          title: l10n.tutorialWelcome,
          body: l10n.tutorialWelcomeBody,
          icon: Icons.casino,
          icon2: Icons.style,
        ),
        TutorialPageData(
          title: l10n.tutorialRollDice,
          body: l10n.tutorialRollDiceBody,
          icon: Icons.play_arrow,
        ),
        // 参加人数を選ぶ（準備完了の一つ前）
        TutorialPageData(
          title: l10n.valueTutorialPage1Title,
          body: l10n.valueTutorialPage1Body,
          icon: Icons.groups,
        ),
        TutorialPageData(
          title: l10n.tutorialReady,
          body: l10n.tutorialReadyBody,
          icon: Icons.check_circle,
        ),
      ];
      final cardPagesWithoutPlayerCount = [
        TutorialPageData(
          title: l10n.valueTutorialPage2Title,
          body: l10n.valueTutorialPage2Body,
          icon: Icons.reorder,
        ),
        TutorialPageData(
          title: l10n.valueTutorialPage3Title,
          body: l10n.valueTutorialPage3Body,
          icon: Icons.share,
        ),
      ];
      _pages = widget.diceOnly
          ? dicePages
          : [
              dicePages[0], // Welcome
              dicePages[1], // RollDice
              ...cardPagesWithoutPlayerCount,
              dicePages[2], // 参加人数を選ぶ
              dicePages[3], // Ready
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
                  return _buildTutorialPage(
                    pages[index],
                    showVersion: index == 0,
                  );
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
                      // 戻るボタン（初回画面では戻り先がないため非表示）
                      _currentPage > 0
                          ? IconButton(
                              onPressed: _previousPage,
                              icon: const Icon(Icons.arrow_back, color: _whiteText),
                            )
                          : const SizedBox(width: 48),
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

  Widget _buildTutorialPage(TutorialPageData pageData, {bool showVersion = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面サイズに応じてレイアウトを調整
        final isSmallScreen = constraints.maxHeight < 700;
        final isNarrowScreen = constraints.maxWidth < 400;
        // フォントサイズを画面に合わせて縮小（はみ出し防止）
        final titleFontSize = isSmallScreen
            ? (isNarrowScreen ? 22.0 : 28.0)
            : (isNarrowScreen ? 26.0 : 38.0);
        final bodyFontSize = isSmallScreen
            ? (isNarrowScreen ? 13.0 : 15.0)
            : (isNarrowScreen ? 15.0 : 17.0);
        final useColumnLayout = isNarrowScreen || constraints.maxHeight < 600;

        Widget textColumn = SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 黄色のバナー（少し回転）
              Transform.rotate(
                angle: -0.1,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrowScreen ? 16 : 24,
                    vertical: isNarrowScreen ? 8 : 12,
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
                  child: Text(
                    'Talk Seed',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isNarrowScreen ? 18 : 24,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 32),
              // メインタイトル（FittedBoxで収まるように）
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  pageData.title,
                  style: TextStyle(
                    color: _whiteText,
                    fontSize: math.max(titleFontSize, 20),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              // 本文（スクロール可能）
              Text(
                pageData.body,
                style: TextStyle(
                  color: _whiteText.withOpacity(0.95),
                  fontSize: bodyFontSize,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              if (showVersion)
                Text(
                  'v1.0 | ${DateTime.now().year}',
                  style: TextStyle(
                    color: _whiteText.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        );

        final iconSize = useColumnLayout
            ? (isSmallScreen ? 72.0 : 96.0)
            : (isSmallScreen ? 120.0 : 180.0);
        final iconSizeSingle = useColumnLayout
            ? (isSmallScreen ? 36.0 : 48.0)
            : (isSmallScreen ? 60.0 : 90.0);

        Widget iconSection = pageData.icon2 != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconCircle(
                    pageData.icon,
                    size: iconSize,
                    iconSize: iconSizeSingle,
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  _buildIconCircle(
                    pageData.icon2!,
                    size: iconSize,
                    iconSize: iconSizeSingle,
                  ),
                ],
              )
            : Transform.rotate(
                angle: -0.1,
                child: _buildIconCircle(
                  pageData.icon,
                  size: iconSize,
                  iconSize: iconSizeSingle,
                ),
              );

        final content = Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 20 : 32,
            vertical: isNarrowScreen ? 16 : 24,
          ),
          child: useColumnLayout
              ? SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      // 上部: テキスト（スクロール可能）
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: textColumn,
                        ),
                      ),
                      SizedBox(height: isNarrowScreen ? 20 : 28),
                      // 中央付近: アイコン
                      iconSection,
                      // 下部: アイコンを視覚的に中央寄せするための余白
                      Expanded(
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: textColumn,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 24 : 40),
                    Expanded(
                      flex: 1,
                      child: Center(child: iconSection),
                    ),
                  ],
                ),
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
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
