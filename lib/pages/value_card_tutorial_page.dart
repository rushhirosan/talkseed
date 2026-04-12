import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

/// 価値観カード専用チュートリアル画面
class ValueCardTutorialPage extends StatefulWidget {
  const ValueCardTutorialPage({super.key});

  @override
  State<ValueCardTutorialPage> createState() => _ValueCardTutorialPageState();
}

class _ValueCardTutorialPageState extends State<ValueCardTutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color _purpleBackground = Color(0xFF4F20D1);
  static const Color _yellowBanner = Color(0xFFFFEB3B);
  static const Color _whiteText = Colors.white;

  List<_ValueTutorialPageData>? _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pages == null) {
      final l10n = AppLocalizations.of(context)!;
      _pages = [
        _ValueTutorialPageData(
          title: l10n.valueTutorialPage1Title,
          body: l10n.valueTutorialPage1Body,
          icon: Icons.groups,
        ),
        _ValueTutorialPageData(
          title: l10n.valueTutorialPage2Title,
          body: l10n.valueTutorialPage2Body,
          icon: Icons.reorder,
        ),
        _ValueTutorialPageData(
          title: l10n.valueTutorialPage3Title,
          body: l10n.valueTutorialPage3Body,
          icon: Icons.share,
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
    setState(() => _currentPage = index);
  }

  void _nextPage() {
    final pages = _pages;
    if (pages != null && _currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.dismiss,
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                physics: const PageScrollPhysics(),
                itemBuilder: (context, index) =>
                    _buildTutorialPage(pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0 ? _previousPage : null,
                        icon: const Icon(Icons.arrow_back, color: _whiteText),
                        disabledColor: _whiteText.withOpacity(0.3),
                      ),
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
                              ? l10n.valueNext
                              : l10n.dismiss,
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

  Widget _buildTutorialPage(_ValueTutorialPageData pageData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 700;
        final isNarrowScreen = constraints.maxWidth < 400;
        final titleFontSize = isSmallScreen
            ? (isNarrowScreen ? 22.0 : 28.0)
            : (isNarrowScreen ? 26.0 : 38.0);
        final bodyFontSize = isSmallScreen
            ? (isNarrowScreen ? 13.0 : 15.0)
            : (isNarrowScreen ? 15.0 : 17.0);
        final useColumnLayout = isNarrowScreen || constraints.maxHeight < 600;
        final iconSize = useColumnLayout
            ? (isSmallScreen ? 72.0 : 96.0)
            : (isSmallScreen ? 120.0 : 180.0);
        final iconSizeSingle = iconSize / 2;

        Widget textColumn = SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    'Talk Shuffle',
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
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  pageData.title,
                  style: TextStyle(
                    color: _whiteText,
                    fontSize: titleFontSize.clamp(20.0, 56.0),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              Text(
                pageData.body,
                style: TextStyle(
                  color: _whiteText.withOpacity(0.95),
                  fontSize: bodyFontSize,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );

        Widget iconSection = Transform.rotate(
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

class _ValueTutorialPageData {
  final String title;
  final String body;
  final IconData icon;

  _ValueTutorialPageData({
    required this.title,
    required this.body,
    required this.icon,
  });
}
