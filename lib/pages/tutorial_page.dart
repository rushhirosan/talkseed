import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/widgets/home/home_ambient_background.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import '../utils/preferences_helper.dart';
import 'dart:math' as math;

/// チュートリアル画面（全6ページ）
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

  // 色は Theme / TalkShuffleTokens に統一（ここではローカル定義しない）

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
          icon: Icons.waving_hand,
        ),
        TutorialPageData(
          title: l10n.tutorialRollDice,
          body: l10n.tutorialRollDiceBody,
          icon: Icons.casino,
        ),
        TutorialPageData(
          title: l10n.tutorialValues,
          body: l10n.tutorialValuesBody,
          icon: Icons.favorite_border,
        ),
        TutorialPageData(
          title: l10n.tutorialGroupDiscussion,
          body: l10n.tutorialGroupDiscussionBody,
          icon: Icons.forum_outlined,
        ),
        TutorialPageData(
          title: l10n.tutorialPlayersHistory,
          body: l10n.tutorialPlayersHistoryBody,
          icon: Icons.groups_outlined,
        ),
        TutorialPageData(
          title: l10n.tutorialReady,
          body: l10n.tutorialReadyBody,
          icon: Icons.check_circle_outline,
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
        backgroundColor: HomePalette.bg,
        body: Center(child: CircularProgressIndicator(color: HomePalette.accent)),
      );
    }

    return Scaffold(
      backgroundColor: HomePalette.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: HomeAmbientBackground()),
          SafeArea(
            child: Column(
              children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _completeTutorial,
                    child: Text(
                      l10n.skip,
                      style: GoogleFonts.zenKakuGothicNew(
                        color: HomePalette.textMuted,
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
                    context,
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
                      (index) => _buildPageIndicator(
                        context,
                        index == _currentPage,
                      ),
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
                              icon: const Icon(
                                Icons.arrow_back,
                                color: HomePalette.textMuted,
                              ),
                            )
                          : const SizedBox(width: 48),
                      Expanded(
                        child: HomePrimaryButton(
                          label: _currentPage < pages.length - 1
                              ? l10n.valueNext
                              : l10n.start,
                          onPressed: _nextPage,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
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
        ],
      ),
    );
  }

  Widget _buildTutorialPage(
    BuildContext context,
    TutorialPageData pageData, {
    bool showVersion = false,
  }) {
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
                    gradient: HomePalette.logoGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: HomePalette.accent.withValues(alpha: 0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Text(
                    'Talk Shuffle',
                    style: GoogleFonts.syne(
                      color: HomePalette.bg,
                      fontWeight: FontWeight.w800,
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
                  style: GoogleFonts.zenKakuGothicNew(
                    color: HomePalette.text,
                    fontSize: math.max(titleFontSize, 20),
                    fontWeight: FontWeight.w800,
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
                style: GoogleFonts.zenKakuGothicNew(
                  color: HomePalette.textMuted,
                  fontSize: bodyFontSize,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              if (showVersion)
                Text(
                  'v1.0 | ${DateTime.now().year}',
                  style: GoogleFonts.zenKakuGothicNew(
                    color: HomePalette.textMuted,
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

        // 2つアイコンの Row は FittedBox で包み、overflow を防止
        Widget iconSection = pageData.icon2 != null
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconCircle(
                      context,
                      pageData.icon,
                      size: iconSize,
                      iconSize: iconSizeSingle,
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    _buildIconCircle(
                      context,
                      pageData.icon2!,
                      size: iconSize,
                      iconSize: iconSizeSingle,
                    ),
                  ],
                ),
              )
            : Transform.rotate(
                angle: -0.1,
                child: _buildIconCircle(
                  context,
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
    BuildContext context,
    IconData icon, {
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HomePalette.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: HomePalette.border,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: HomePalette.text,
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? HomePalette.accent
            : Colors.white.withValues(alpha: 0.2),
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
