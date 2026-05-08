import 'package:flutter/material.dart';

/// Talk Shuffle の統一カラートークン（親しみ・カジュアル向けの紫＋黄ベース）。
///
/// 画面ごとの `Color(0xFF...)` を増やさず、ここを唯一のソースにする。
@immutable
class TalkShuffleTokens extends ThemeExtension<TalkShuffleTokens> {
  const TalkShuffleTokens({
    required this.brandPurple,
    required this.brandYellow,
    required this.scaffoldHome,
    required this.scaffoldPlayWarm,
    required this.scaffoldTutorial,
    required this.surfaceCard,
    required this.shellLavender,
    required this.rowHighlightLavender,
    required this.borderLavender,
    required this.deckIconValues,
    required this.deckIconProblem,
    required this.deckIconSocial,
    required this.deckTileTeamBuilding,
    required this.deckTileProblemSolving,
    required this.deckTileSocialIssues,
    required this.deckTileCheckIn,
    required this.deckTileOneOnOne,
    required this.playerPastel0,
    required this.playerPastel1,
    required this.playerPastel2,
    required this.playerPastel3,
    required this.bootstrapSurface,
  });

  /// 主アクセント（CTA・チュートリアル背景など）
  final Color brandPurple;

  /// 副アクセント（ホーム背景・強調ボタンなど）
  final Color brandYellow;

  /// モード選択など「元気な入口」
  final Color scaffoldHome;

  /// プレイ・設定まわりの暖かいクリーム系
  final Color scaffoldPlayWarm;

  /// チュートリアル全画面
  final Color scaffoldTutorial;

  /// 大きなカードコンテナ
  final Color surfaceCard;

  /// チェックボックス周りなど薄いシェル
  final Color shellLavender;

  /// リスト行のうち1行だけハイライトしたいとき
  final Color rowHighlightLavender;

  final Color borderLavender;

  final Color deckIconValues;
  final Color deckIconProblem;
  final Color deckIconSocial;

  /// カード設定のデッキタイル（元の青緑橙…を紫黄トーンに寄せた差分）
  final Color deckTileTeamBuilding;
  final Color deckTileProblemSolving;
  final Color deckTileSocialIssues;
  final Color deckTileCheckIn;
  final Color deckTileOneOnOne;

  /// ドラッグ候補・プレイヤー行などの軽い差し色（同一色相感）
  final Color playerPastel0;
  final Color playerPastel1;
  final Color playerPastel2;
  final Color playerPastel3;

  /// スプラッシュ / Hive 待ちなどのニュートラル
  final Color bootstrapSurface;

  static const TalkShuffleTokens standard = TalkShuffleTokens(
    brandPurple: Color(0xFF5A3FC0),
    brandYellow: Color(0xFFFFEA5A),
    scaffoldHome: Color(0xFFFFEA5A),
    scaffoldPlayWarm: Color(0xFFFFF8ED),
    scaffoldTutorial: Color(0xFF5A3FC0),
    surfaceCard: Color(0xFFF8F3E8),
    shellLavender: Color(0xFFF5F2FC),
    rowHighlightLavender: Color(0xFFE8E2F5),
    borderLavender: Color(0xFFD4CFE8),
    deckIconValues: Color(0xFF5E52C8),
    deckIconProblem: Color(0xFF7B5ED4),
    deckIconSocial: Color(0xFF4B64C9),
    deckTileTeamBuilding: Color(0xFFF5F2FC),
    deckTileProblemSolving: Color(0xFFEEF4FF),
    deckTileSocialIssues: Color(0xFFF3EBFA),
    deckTileCheckIn: Color(0xFFFFF6E6),
    deckTileOneOnOne: Color(0xFFECEAF8),
    playerPastel0: Color(0xFFE8E2F5),
    playerPastel1: Color(0xFFFFF3D4),
    playerPastel2: Color(0xFFEDE7F6),
    playerPastel3: Color(0xFFFCE8DC),
    bootstrapSurface: Color(0xFFF5F2FC),
  );

  Color playerPastel(int index) {
    final list = [playerPastel0, playerPastel1, playerPastel2, playerPastel3];
    return list[index % list.length];
  }

  @override
  TalkShuffleTokens copyWith({
    Color? brandPurple,
    Color? brandYellow,
    Color? scaffoldHome,
    Color? scaffoldPlayWarm,
    Color? scaffoldTutorial,
    Color? surfaceCard,
    Color? shellLavender,
    Color? rowHighlightLavender,
    Color? borderLavender,
    Color? deckIconValues,
    Color? deckIconProblem,
    Color? deckIconSocial,
    Color? deckTileTeamBuilding,
    Color? deckTileProblemSolving,
    Color? deckTileSocialIssues,
    Color? deckTileCheckIn,
    Color? deckTileOneOnOne,
    Color? playerPastel0,
    Color? playerPastel1,
    Color? playerPastel2,
    Color? playerPastel3,
    Color? bootstrapSurface,
  }) {
    return TalkShuffleTokens(
      brandPurple: brandPurple ?? this.brandPurple,
      brandYellow: brandYellow ?? this.brandYellow,
      scaffoldHome: scaffoldHome ?? this.scaffoldHome,
      scaffoldPlayWarm: scaffoldPlayWarm ?? this.scaffoldPlayWarm,
      scaffoldTutorial: scaffoldTutorial ?? this.scaffoldTutorial,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      shellLavender: shellLavender ?? this.shellLavender,
      rowHighlightLavender: rowHighlightLavender ?? this.rowHighlightLavender,
      borderLavender: borderLavender ?? this.borderLavender,
      deckIconValues: deckIconValues ?? this.deckIconValues,
      deckIconProblem: deckIconProblem ?? this.deckIconProblem,
      deckIconSocial: deckIconSocial ?? this.deckIconSocial,
      deckTileTeamBuilding: deckTileTeamBuilding ?? this.deckTileTeamBuilding,
      deckTileProblemSolving:
          deckTileProblemSolving ?? this.deckTileProblemSolving,
      deckTileSocialIssues: deckTileSocialIssues ?? this.deckTileSocialIssues,
      deckTileCheckIn: deckTileCheckIn ?? this.deckTileCheckIn,
      deckTileOneOnOne: deckTileOneOnOne ?? this.deckTileOneOnOne,
      playerPastel0: playerPastel0 ?? this.playerPastel0,
      playerPastel1: playerPastel1 ?? this.playerPastel1,
      playerPastel2: playerPastel2 ?? this.playerPastel2,
      playerPastel3: playerPastel3 ?? this.playerPastel3,
      bootstrapSurface: bootstrapSurface ?? this.bootstrapSurface,
    );
  }

  @override
  ThemeExtension<TalkShuffleTokens> lerp(
    covariant ThemeExtension<TalkShuffleTokens>? other,
    double t,
  ) {
    if (other is! TalkShuffleTokens) return this;
    if (t == 0) return this;
    if (t == 1) return other;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return TalkShuffleTokens(
      brandPurple: c(brandPurple, other.brandPurple),
      brandYellow: c(brandYellow, other.brandYellow),
      scaffoldHome: c(scaffoldHome, other.scaffoldHome),
      scaffoldPlayWarm: c(scaffoldPlayWarm, other.scaffoldPlayWarm),
      scaffoldTutorial: c(scaffoldTutorial, other.scaffoldTutorial),
      surfaceCard: c(surfaceCard, other.surfaceCard),
      shellLavender: c(shellLavender, other.shellLavender),
      rowHighlightLavender: c(rowHighlightLavender, other.rowHighlightLavender),
      borderLavender: c(borderLavender, other.borderLavender),
      deckIconValues: c(deckIconValues, other.deckIconValues),
      deckIconProblem: c(deckIconProblem, other.deckIconProblem),
      deckIconSocial: c(deckIconSocial, other.deckIconSocial),
      deckTileTeamBuilding: c(deckTileTeamBuilding, other.deckTileTeamBuilding),
      deckTileProblemSolving:
          c(deckTileProblemSolving, other.deckTileProblemSolving),
      deckTileSocialIssues: c(deckTileSocialIssues, other.deckTileSocialIssues),
      deckTileCheckIn: c(deckTileCheckIn, other.deckTileCheckIn),
      deckTileOneOnOne: c(deckTileOneOnOne, other.deckTileOneOnOne),
      playerPastel0: c(playerPastel0, other.playerPastel0),
      playerPastel1: c(playerPastel1, other.playerPastel1),
      playerPastel2: c(playerPastel2, other.playerPastel2),
      playerPastel3: c(playerPastel3, other.playerPastel3),
      bootstrapSurface: c(bootstrapSurface, other.bootstrapSurface),
    );
  }
}

extension TalkShuffleThemeX on BuildContext {
  TalkShuffleTokens get talkShuffle =>
      Theme.of(this).extension<TalkShuffleTokens>() ??
      TalkShuffleTokens.standard;
}

/// アプリ全体の [ThemeData]。色の入口はここだけに寄せる。
ThemeData buildTalkShuffleTheme() {
  const tokens = TalkShuffleTokens.standard;
  final scheme = ColorScheme.fromSeed(
    seedColor: tokens.brandPurple,
    brightness: Brightness.light,
  ).copyWith(
    primary: tokens.brandPurple,
    onPrimary: Colors.white,
    secondary: tokens.brandYellow,
    onSecondary: const Color(0xFF1A1A1A),
    surface: Colors.white,
    onSurface: const Color(0xDE000000),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: const [TalkShuffleTokens.standard],
    scaffoldBackgroundColor: tokens.scaffoldPlayWarm,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xDE000000),
    ),
  );
}
