import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/pages/dice_page.dart';
import 'package:theme_dice/pages/initial_settings_page.dart';
import 'package:theme_dice/pages/mode_selection_page.dart';
import 'package:theme_dice/pages/tutorial_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talk Seed',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''),
        Locale('en', ''),
      ],
      // デバッグ用：特定の言語を強制する場合は以下のコメントを外してください
      // locale: const Locale('en', ''), // 英語を強制
      // locale: const Locale('ja', ''), // 日本語を強制
      home: const MainPage(),
    );
  }
}

/// 初回起動チェックとチュートリアル表示を管理するメインページ
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = true;
  bool _showTutorial = false;
  /// 案B: 再訪時にデフォルトモードで開く用
  List<String>? _savedThemes;
  /// 起動時直接表示: 'dice' のみ（カードは廃止）| null = モード選択
  String? _defaultPlayMode;

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  /// 初回起動・チュートリアル・デフォルト遊び方のチェック（案B）
  Future<void> _checkInitialRoute() async {
    try {
      final isFirstLaunch = await PreferencesHelper.isFirstLaunch();
      if (isFirstLaunch) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showTutorial = true;
            _savedThemes = null;
            _defaultPlayMode = null;
          });
        }
        return;
      }
      final defaultMode = await PreferencesHelper.loadDefaultPlayMode();
      // カードで開くは廃止（複数デッキのため）。過去に topic_card が保存されていれば未設定扱いにする
      final effectiveMode = defaultMode == 'topic_card' ? null : defaultMode;
      if (effectiveMode == null || !mounted) {
        if (mounted) {
          if (defaultMode == 'topic_card') {
            PreferencesHelper.saveDefaultPlayMode(null);
          }
          setState(() {
            _isLoading = false;
            _showTutorial = false;
            _savedThemes = null;
            _defaultPlayMode = null;
          });
        }
        return;
      }
      final themes = await PreferencesHelper.loadLastThemes();
      if (effectiveMode == 'dice') {
        if (themes != null && themes.length == 6 && mounted) {
          setState(() {
            _isLoading = false;
            _showTutorial = false;
            _savedThemes = themes;
            _defaultPlayMode = 'dice';
          });
        } else if (mounted) {
          setState(() {
            _isLoading = false;
            _showTutorial = false;
            _savedThemes = null;
            _defaultPlayMode = null;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showTutorial = false;
          _savedThemes = null;
          _defaultPlayMode = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showTutorial = false;
          _savedThemes = null;
          _defaultPlayMode = null;
        });
      }
    }
  }

  /// チュートリアル完了時のコールバック（必ず初期画面へ）
  void _onTutorialComplete() {
    if (!mounted) return;
    setState(() {
      _showTutorial = false;
      _defaultPlayMode = null;
      _savedThemes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ローディング中
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // チュートリアル表示
    if (_showTutorial) {
      return TutorialPage(onComplete: _onTutorialComplete);
    }

    // 案B: デフォルトが未設定ならモード選択画面（選ぶだけのシンプルな画面）
    final shouldShowInitial = _defaultPlayMode == null;
    if (shouldShowInitial) {
      return const ModeSelectionPage();
    }

    // 案B: デフォルトがサイコロならサイコロ画面を直接表示
    if (_defaultPlayMode == 'dice' && _savedThemes != null && _savedThemes!.length == 6) {
      return DicePage(
        initialType: PolyhedronType.cube,
        initialThemes: {PolyhedronType.cube: _savedThemes!},
      );
    }

    // サイコロ以外（topic_card は廃止）は初期設定 or モード選択へ
    return const InitialSettingsPage();
  }
}
