import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../utils/preferences_helper.dart';

/// チュートリアル画面
class TutorialPage extends StatelessWidget {
  final VoidCallback onComplete;

  const TutorialPage({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'Theme Diceへようこそ！',
          body: 'サイコロを振って、ランダムにテーマを選ぶアプリです。\n\nアイデア出しや意思決定の補助に使えます。',
          image: _buildIconImage(Icons.casino, context),
          decoration: _getPageDecoration(context),
        ),
        PageViewModel(
          title: 'テーマを設定しよう',
          body: '最初にサイコロの各面に表示するテーマを設定します。\n\n右側の候補からドラッグ＆ドロップして、\nまたは直接入力してください。',
          image: _buildIconImage(Icons.edit, context),
          decoration: _getPageDecoration(context),
        ),
        PageViewModel(
          title: 'サイコロを振る',
          body: '設定が完了したら「サイコロを振る」ボタンを押してください。\n\n3Dアニメーションでサイコロが転がり、\nランダムなテーマが選ばれます。',
          image: _buildIconImage(Icons.play_arrow, context),
          decoration: _getPageDecoration(context),
        ),
        PageViewModel(
          title: '設定を変更する',
          body: 'いつでも設定画面からテーマを変更できます。\n\n右上の設定アイコンからアクセスできます。',
          image: _buildIconImage(Icons.settings, context),
          decoration: _getPageDecoration(context),
        ),
        PageViewModel(
          title: '準備完了！',
          body: 'それでは、早速使ってみましょう。\n\nテーマを設定して、サイコロを振ってください！',
          image: _buildIconImage(Icons.check_circle, context),
          decoration: _getPageDecoration(context),
        ),
      ],
      onDone: () async {
        // 初回起動フラグを無効化
        await PreferencesHelper.setFirstLaunchCompleted();
        onComplete();
      },
      onSkip: () async {
        // スキップ時もフラグを無効化
        await PreferencesHelper.setFirstLaunchCompleted();
        onComplete();
      },
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      skip: const Text('スキップ', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('始める', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.primary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  /// アイコンを表示するためのウィジェット
  Widget _buildIconImage(IconData icon, BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// ページのデコレーションを取得
  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16.0,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: const EdgeInsets.only(top: 120),
    );
  }
}
