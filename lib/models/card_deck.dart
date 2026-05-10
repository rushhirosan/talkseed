import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/discussion_category_group.dart';

/// 自己内省・1on1デッキのセクション（色・アイコン用）
/// 軽さ×深さのレイヤー: チェックイン → 自己内省 → 成長・関係性
enum ReflectionDeckCategory {
  /// チェックイン（TableTopics寄り・空気づくり）
  checkin,
  /// 自己内省（中核・The School of Life を軽く）
  selfReflection,
  /// 成長・関係性（深め・1on1後半）
  growthRelationship,
}

/// 自己内省デッキのセクション見た目
class ReflectionDeckCategoryStyle {
  final Color color;
  final IconData icon;

  const ReflectionDeckCategoryStyle({required this.color, required this.icon});

  static const checkin = ReflectionDeckCategoryStyle(
    color: Color(0xFFE8F5E9), // 緑
    icon: Icons.wb_sunny_outlined,
  );
  static const selfReflection = ReflectionDeckCategoryStyle(
    color: Color(0xFFFFF9C4), // 黄
    icon: Icons.psychology_outlined,
  );
  static const growthRelationship = ReflectionDeckCategoryStyle(
    color: Color(0xFFFFEBEE), // 赤系
    icon: Icons.people_outline,
  );

  static ReflectionDeckCategoryStyle forCategory(ReflectionDeckCategory c) {
    switch (c) {
      case ReflectionDeckCategory.checkin:
        return checkin;
      case ReflectionDeckCategory.selfReflection:
        return selfReflection;
      case ReflectionDeckCategory.growthRelationship:
        return growthRelationship;
    }
  }
}

/// セクションID（JSON）を ReflectionDeckCategory に変換
ReflectionDeckCategory? reflectionCategoryFromSectionId(String sectionId) {
  switch (sectionId) {
    case 'checkin':
      return ReflectionDeckCategory.checkin;
    case 'selfReflection':
      return ReflectionDeckCategory.selfReflection;
    case 'growthRelationship':
      return ReflectionDeckCategory.growthRelationship;
    default:
      return null;
  }
}

/// カードデッキの種類
enum CardDeckType {
  /// チームビルディング（価値観カード風）
  teamBuilding,

  /// 問題解決の型を練習するカード（ゴール・選択肢・リスク・次アクション）
  problemSolving,

  /// 現代の社会課題を議論するカード
  socialIssues,

  /// チェックイン・チェックアウト（checkin_checkout_work.json の両方）
  checkIn,

  /// 自己内省・1on1（self_reflection_1on1.json・軽さ×深さの3セクション）
  oneOnOne,
}

/// 仕事用カードデッキの定義
class CardDeck {
  final CardDeckType type;
  final String Function(AppLocalizations l10n) nameBuilder;
  final String Function(AppLocalizations l10n) descriptionBuilder;
  final List<String> themeKeys;

  const CardDeck({
    required this.type,
    required this.nameBuilder,
    required this.descriptionBuilder,
    required this.themeKeys,
  });

  String name(AppLocalizations l10n) => nameBuilder(l10n);
  String description(AppLocalizations l10n) => descriptionBuilder(l10n);
  List<String> themes(AppLocalizations l10n) =>
      themeKeys.map((k) => _getThemeString(k, l10n)).toList();

  static String _getThemeString(String key, AppLocalizations l10n) {
    switch (key) {
      case 'themeTrust':
        return l10n.themeTrust;
      case 'themeChallenge':
        return l10n.themeChallenge;
      case 'themeGratitude':
        return l10n.themeGratitude;
      case 'themeFeedback':
        return l10n.themeFeedback;
      case 'themeFlexibility':
        return l10n.themeFlexibility;
      case 'themeResponsibility':
        return l10n.themeResponsibility;
      case 'themeGrowth':
        return l10n.themeGrowth;
      case 'themeWorkLifeBalance':
        return l10n.themeWorkLifeBalance;
      case 'themeCollaboration':
        return l10n.themeCollaboration;
      case 'themeTransparency':
        return l10n.themeTransparency;
      case 'themeWeeklyHighlight':
        return l10n.themeWeeklyHighlight;
      case 'themeTodayGoal':
        return l10n.themeTodayGoal;
      case 'themeBlocker':
        return l10n.themeBlocker;
      case 'themeWeekendPlan':
        return l10n.themeWeekendPlan;
      case 'themeCurrentMood':
        return l10n.themeCurrentMood;
      case 'themeOneWord':
        return l10n.themeOneWord;
      case 'themeWellDone':
        return l10n.themeWellDone;
      case 'themeStruggle':
        return l10n.themeStruggle;
      case 'themeWantToGrow':
        return l10n.themeWantToGrow;
      case 'themeFeedbackWant':
        return l10n.themeFeedbackWant;
      case 'themeRecentWorry':
        return l10n.themeRecentWorry;
      case 'themeProudOf':
        return l10n.themeProudOf;
      case 'themeSupporting':
        return l10n.themeSupporting;
      case 'themeGoodPoint':
        return l10n.themeGoodPoint;
      case 'themeImprovePoint':
        return l10n.themeImprovePoint;
      case 'themeLearnings':
        return l10n.themeLearnings;
      case 'themeNextAction':
        return l10n.themeNextAction;
      case 'themeThanks':
        return l10n.themeThanks;
      case 'themeSurprised':
        return l10n.themeSurprised;
      case 'themeRecentHobby':
        return l10n.themeRecentHobby;
      case 'themeFavoriteFood':
        return l10n.themeFavoriteFood;
      case 'themeWantToVisit':
        return l10n.themeWantToVisit;
      case 'themeChildhoodMemory':
        return l10n.themeChildhoodMemory;
      case 'themeUniqueSkill':
        return l10n.themeUniqueSkill;
      case 'themeSecret':
        return l10n.themeSecret;
      case 'themeFavoriteWord':
        return l10n.themeFavoriteWord;
      case 'themeMotto':
        return l10n.themeMotto;
      case 'themeImportantThing':
        return l10n.themeImportantThing;
      case 'themeBelief':
        return l10n.themeBelief;
      case 'themeHonesty':
        return l10n.themeHonesty;
      case 'themeInnovation':
        return l10n.themeInnovation;
      case 'themeStability':
        return l10n.themeStability;
      case 'themeAutonomy':
        return l10n.themeAutonomy;
      case 'themeCommunity':
        return l10n.themeCommunity;
      case 'themeQuality':
        return l10n.themeQuality;
      case 'themeSpeed':
        return l10n.themeSpeed;
      case 'themeCustomerFirst':
        return l10n.themeCustomerFirst;
      case 'themeLearning':
        return l10n.themeLearning;
      case 'themeBalance':
        return l10n.themeBalance;
      case 'themeCreativity':
        return l10n.themeCreativity;
      case 'themeEmpathy':
        return l10n.themeEmpathy;
      case 'themeConsistency':
        return l10n.themeConsistency;
      case 'themeRespect':
        return l10n.themeRespect;
      case 'themeValuePriority':
        return l10n.themeValuePriority;
      case 'themeValueIntegrity':
        return l10n.themeValueIntegrity;
      case 'themeProbLogical1':
        return l10n.themeProbLogical1;
      case 'themeProbLogical2':
        return l10n.themeProbLogical2;
      case 'themeProbLogical3':
        return l10n.themeProbLogical3;
      case 'themeProbLogical4':
        return l10n.themeProbLogical4;
      case 'themeProbLogical5':
        return l10n.themeProbLogical5;
      case 'themeProbLogical6':
        return l10n.themeProbLogical6;
      case 'themeProbLogical7':
        return l10n.themeProbLogical7;
      case 'themeProbLogical8':
        return l10n.themeProbLogical8;
      case 'themeProbLogical9':
        return l10n.themeProbLogical9;
      case 'themeProbLogical10':
        return l10n.themeProbLogical10;
      case 'themeProbCreative1':
        return l10n.themeProbCreative1;
      case 'themeProbCreative2':
        return l10n.themeProbCreative2;
      case 'themeProbCreative3':
        return l10n.themeProbCreative3;
      case 'themeProbCreative4':
        return l10n.themeProbCreative4;
      case 'themeProbCreative5':
        return l10n.themeProbCreative5;
      case 'themeProbCreative6':
        return l10n.themeProbCreative6;
      case 'themeProbCreative7':
        return l10n.themeProbCreative7;
      case 'themeProbCreative8':
        return l10n.themeProbCreative8;
      case 'themeProbCreative9':
        return l10n.themeProbCreative9;
      case 'themeProbCreative10':
        return l10n.themeProbCreative10;
      case 'themeProbFermi1':
        return l10n.themeProbFermi1;
      case 'themeProbFermi2':
        return l10n.themeProbFermi2;
      case 'themeProbFermi3':
        return l10n.themeProbFermi3;
      case 'themeProbFermi4':
        return l10n.themeProbFermi4;
      case 'themeProbFermi5':
        return l10n.themeProbFermi5;
      case 'themeProbFermi6':
        return l10n.themeProbFermi6;
      case 'themeProbFermi7':
        return l10n.themeProbFermi7;
      case 'themeProbFermi8':
        return l10n.themeProbFermi8;
      case 'themeProbFermi9':
        return l10n.themeProbFermi9;
      case 'themeProbFermi10':
        return l10n.themeProbFermi10;
      case 'themeProbDilemma1':
        return l10n.themeProbDilemma1;
      case 'themeProbDilemma2':
        return l10n.themeProbDilemma2;
      case 'themeProbDilemma3':
        return l10n.themeProbDilemma3;
      case 'themeProbDilemma4':
        return l10n.themeProbDilemma4;
      case 'themeProbDilemma5':
        return l10n.themeProbDilemma5;
      case 'themeProbDilemma6':
        return l10n.themeProbDilemma6;
      case 'themeProbDilemma7':
        return l10n.themeProbDilemma7;
      case 'themeProbDilemma8':
        return l10n.themeProbDilemma8;
      case 'themeProbDilemma9':
        return l10n.themeProbDilemma9;
      case 'themeProbDilemma10':
        return l10n.themeProbDilemma10;
      case 'themeSocGeo1':
        return l10n.themeSocGeo1;
      case 'themeSocGeo2':
        return l10n.themeSocGeo2;
      case 'themeSocGeo3':
        return l10n.themeSocGeo3;
      case 'themeSocGeo4':
        return l10n.themeSocGeo4;
      case 'themeSocGeo5':
        return l10n.themeSocGeo5;
      case 'themeSocGeo6':
        return l10n.themeSocGeo6;
      case 'themeSocGeo7':
        return l10n.themeSocGeo7;
      case 'themeSocGeo8':
        return l10n.themeSocGeo8;
      case 'themeSocGeo9':
        return l10n.themeSocGeo9;
      case 'themeSocGeo10':
        return l10n.themeSocGeo10;
      case 'themeSocAiGap1':
        return l10n.themeSocAiGap1;
      case 'themeSocAiGap2':
        return l10n.themeSocAiGap2;
      case 'themeSocAiGap3':
        return l10n.themeSocAiGap3;
      case 'themeSocAiGap4':
        return l10n.themeSocAiGap4;
      case 'themeSocAiGap5':
        return l10n.themeSocAiGap5;
      case 'themeSocAiGap6':
        return l10n.themeSocAiGap6;
      case 'themeSocAiGap7':
        return l10n.themeSocAiGap7;
      case 'themeSocAiGap8':
        return l10n.themeSocAiGap8;
      case 'themeSocAiGap9':
        return l10n.themeSocAiGap9;
      case 'themeSocAiGap10':
        return l10n.themeSocAiGap10;
      case 'themeSocClimate1':
        return l10n.themeSocClimate1;
      case 'themeSocClimate2':
        return l10n.themeSocClimate2;
      case 'themeSocClimate3':
        return l10n.themeSocClimate3;
      case 'themeSocClimate4':
        return l10n.themeSocClimate4;
      case 'themeSocClimate5':
        return l10n.themeSocClimate5;
      case 'themeSocClimate6':
        return l10n.themeSocClimate6;
      case 'themeSocClimate7':
        return l10n.themeSocClimate7;
      case 'themeSocClimate8':
        return l10n.themeSocClimate8;
      case 'themeSocClimate9':
        return l10n.themeSocClimate9;
      case 'themeSocClimate10':
        return l10n.themeSocClimate10;
      case 'themeSocDemocracy1':
        return l10n.themeSocDemocracy1;
      case 'themeSocDemocracy2':
        return l10n.themeSocDemocracy2;
      case 'themeSocDemocracy3':
        return l10n.themeSocDemocracy3;
      case 'themeSocDemocracy4':
        return l10n.themeSocDemocracy4;
      case 'themeSocDemocracy5':
        return l10n.themeSocDemocracy5;
      case 'themeSocDemocracy6':
        return l10n.themeSocDemocracy6;
      case 'themeSocDemocracy7':
        return l10n.themeSocDemocracy7;
      case 'themeSocDemocracy8':
        return l10n.themeSocDemocracy8;
      case 'themeSocDemocracy9':
        return l10n.themeSocDemocracy9;
      case 'themeSocDemocracy10':
        return l10n.themeSocDemocracy10;
      case 'themeSocJapanDecline1':
        return l10n.themeSocJapanDecline1;
      case 'themeSocJapanDecline2':
        return l10n.themeSocJapanDecline2;
      case 'themeSocJapanDecline3':
        return l10n.themeSocJapanDecline3;
      case 'themeSocJapanDecline4':
        return l10n.themeSocJapanDecline4;
      case 'themeSocJapanDecline5':
        return l10n.themeSocJapanDecline5;
      case 'themeSocJapanDecline6':
        return l10n.themeSocJapanDecline6;
      case 'themeSocJapanDecline7':
        return l10n.themeSocJapanDecline7;
      case 'themeSocJapanDecline8':
        return l10n.themeSocJapanDecline8;
      case 'themeSocJapanDecline9':
        return l10n.themeSocJapanDecline9;
      case 'themeSocJapanDecline10':
        return l10n.themeSocJapanDecline10;
      case 'themeSocJapanImmigration1':
        return l10n.themeSocJapanImmigration1;
      case 'themeSocJapanImmigration2':
        return l10n.themeSocJapanImmigration2;
      case 'themeSocJapanImmigration3':
        return l10n.themeSocJapanImmigration3;
      case 'themeSocJapanImmigration4':
        return l10n.themeSocJapanImmigration4;
      case 'themeSocJapanImmigration5':
        return l10n.themeSocJapanImmigration5;
      case 'themeSocJapanImmigration6':
        return l10n.themeSocJapanImmigration6;
      case 'themeSocJapanImmigration7':
        return l10n.themeSocJapanImmigration7;
      case 'themeSocJapanImmigration8':
        return l10n.themeSocJapanImmigration8;
      case 'themeSocJapanImmigration9':
        return l10n.themeSocJapanImmigration9;
      case 'themeSocJapanImmigration10':
        return l10n.themeSocJapanImmigration10;
      case 'themeSocJapanWork1':
        return l10n.themeSocJapanWork1;
      case 'themeSocJapanWork2':
        return l10n.themeSocJapanWork2;
      case 'themeSocJapanWork3':
        return l10n.themeSocJapanWork3;
      case 'themeSocJapanWork4':
        return l10n.themeSocJapanWork4;
      case 'themeSocJapanWork5':
        return l10n.themeSocJapanWork5;
      case 'themeSocJapanWork6':
        return l10n.themeSocJapanWork6;
      case 'themeSocJapanWork7':
        return l10n.themeSocJapanWork7;
      case 'themeSocJapanWork8':
        return l10n.themeSocJapanWork8;
      case 'themeSocJapanWork9':
        return l10n.themeSocJapanWork9;
      case 'themeSocJapanWork10':
        return l10n.themeSocJapanWork10;
      case 'themeSocJapanLocal1':
        return l10n.themeSocJapanLocal1;
      case 'themeSocJapanLocal2':
        return l10n.themeSocJapanLocal2;
      case 'themeSocJapanLocal3':
        return l10n.themeSocJapanLocal3;
      case 'themeSocJapanLocal4':
        return l10n.themeSocJapanLocal4;
      case 'themeSocJapanLocal5':
        return l10n.themeSocJapanLocal5;
      case 'themeSocJapanLocal6':
        return l10n.themeSocJapanLocal6;
      case 'themeSocJapanLocal7':
        return l10n.themeSocJapanLocal7;
      case 'themeSocJapanLocal8':
        return l10n.themeSocJapanLocal8;
      case 'themeSocJapanLocal9':
        return l10n.themeSocJapanLocal9;
      case 'themeSocJapanLocal10':
        return l10n.themeSocJapanLocal10;
      default:
        return key;
    }
  }

  static final List<CardDeck> allDecks = [
    /// チームビルディング（価値観カード風）
    /// ファシリテーター持ち or 場に置いて、スマホを回さずにプレイ
    /// 4人×5枚＋山札で約26枚
    CardDeck(
      type: CardDeckType.teamBuilding,
      nameBuilder: (l10n) => l10n.deckTeamBuilding,
      descriptionBuilder: (l10n) => l10n.deckTeamBuildingDesc,
      themeKeys: [
        'themeTrust',
        'themeChallenge',
        'themeGratitude',
        'themeFeedback',
        'themeFlexibility',
        'themeResponsibility',
        'themeGrowth',
        'themeWorkLifeBalance',
        'themeCollaboration',
        'themeTransparency',
        'themeValuePriority',
        'themeValueIntegrity',
        'themeHonesty',
        'themeInnovation',
        'themeStability',
        'themeAutonomy',
        'themeCommunity',
        'themeQuality',
        'themeSpeed',
        'themeCustomerFirst',
        'themeLearning',
        'themeBalance',
        'themeCreativity',
        'themeEmpathy',
        'themeConsistency',
        'themeRespect',
      ],
    ),
    CardDeck(
      type: CardDeckType.problemSolving,
      nameBuilder: (l10n) => l10n.deckProblemSolving,
      descriptionBuilder: (l10n) => l10n.deckProblemSolvingDesc,
      themeKeys: const [
        'themeProbLogical1',
        'themeProbLogical2',
        'themeProbLogical3',
        'themeProbLogical4',
        'themeProbLogical5',
        'themeProbLogical6',
        'themeProbLogical7',
        'themeProbLogical8',
        'themeProbLogical9',
        'themeProbLogical10',
        'themeProbCreative1',
        'themeProbCreative2',
        'themeProbCreative3',
        'themeProbCreative4',
        'themeProbCreative5',
        'themeProbCreative6',
        'themeProbCreative7',
        'themeProbCreative8',
        'themeProbCreative9',
        'themeProbCreative10',
        'themeProbFermi1',
        'themeProbFermi2',
        'themeProbFermi3',
        'themeProbFermi4',
        'themeProbFermi5',
        'themeProbFermi6',
        'themeProbFermi7',
        'themeProbFermi8',
        'themeProbFermi9',
        'themeProbFermi10',
        'themeProbDilemma1',
        'themeProbDilemma2',
        'themeProbDilemma3',
        'themeProbDilemma4',
        'themeProbDilemma5',
        'themeProbDilemma6',
        'themeProbDilemma7',
        'themeProbDilemma8',
        'themeProbDilemma9',
        'themeProbDilemma10',
      ],
    ),
    CardDeck(
      type: CardDeckType.socialIssues,
      nameBuilder: (l10n) => l10n.deckSocialIssues,
      descriptionBuilder: (l10n) => l10n.deckSocialIssuesDesc,
      themeKeys: const [
        'themeSocGeo1',
        'themeSocGeo2',
        'themeSocGeo3',
        'themeSocGeo4',
        'themeSocGeo5',
        'themeSocGeo6',
        'themeSocGeo7',
        'themeSocGeo8',
        'themeSocGeo9',
        'themeSocGeo10',
        'themeSocAiGap1',
        'themeSocAiGap2',
        'themeSocAiGap3',
        'themeSocAiGap4',
        'themeSocAiGap5',
        'themeSocAiGap6',
        'themeSocAiGap7',
        'themeSocAiGap8',
        'themeSocAiGap9',
        'themeSocAiGap10',
        'themeSocClimate1',
        'themeSocClimate2',
        'themeSocClimate3',
        'themeSocClimate4',
        'themeSocClimate5',
        'themeSocClimate6',
        'themeSocClimate7',
        'themeSocClimate8',
        'themeSocClimate9',
        'themeSocClimate10',
        'themeSocDemocracy1',
        'themeSocDemocracy2',
        'themeSocDemocracy3',
        'themeSocDemocracy4',
        'themeSocDemocracy5',
        'themeSocDemocracy6',
        'themeSocDemocracy7',
        'themeSocDemocracy8',
        'themeSocDemocracy9',
        'themeSocDemocracy10',
        'themeSocJapanDecline1',
        'themeSocJapanDecline2',
        'themeSocJapanDecline3',
        'themeSocJapanDecline4',
        'themeSocJapanDecline5',
        'themeSocJapanDecline6',
        'themeSocJapanDecline7',
        'themeSocJapanDecline8',
        'themeSocJapanDecline9',
        'themeSocJapanDecline10',
        'themeSocJapanImmigration1',
        'themeSocJapanImmigration2',
        'themeSocJapanImmigration3',
        'themeSocJapanImmigration4',
        'themeSocJapanImmigration5',
        'themeSocJapanImmigration6',
        'themeSocJapanImmigration7',
        'themeSocJapanImmigration8',
        'themeSocJapanImmigration9',
        'themeSocJapanImmigration10',
        'themeSocJapanWork1',
        'themeSocJapanWork2',
        'themeSocJapanWork3',
        'themeSocJapanWork4',
        'themeSocJapanWork5',
        'themeSocJapanWork6',
        'themeSocJapanWork7',
        'themeSocJapanWork8',
        'themeSocJapanWork9',
        'themeSocJapanWork10',
        'themeSocJapanLocal1',
        'themeSocJapanLocal2',
        'themeSocJapanLocal3',
        'themeSocJapanLocal4',
        'themeSocJapanLocal5',
        'themeSocJapanLocal6',
        'themeSocJapanLocal7',
        'themeSocJapanLocal8',
        'themeSocJapanLocal9',
        'themeSocJapanLocal10',
      ],
    ),
    /// チェックイン・チェックアウト（checkin_checkout_work.json から両方読み込み）
    CardDeck(
      type: CardDeckType.checkIn,
      nameBuilder: (l10n) => l10n.deckCheckIn,
      descriptionBuilder: (l10n) => l10n.deckCheckInDesc,
      themeKeys: const [],
    ),
    /// 自己内省・1on1（self_reflection_1on1.json の3セクション）
    CardDeck(
      type: CardDeckType.oneOnOne,
      nameBuilder: (l10n) => l10n.deckSelfReflection,
      descriptionBuilder: (l10n) => l10n.deckSelfReflectionDesc,
      themeKeys: const [],
    ),
  ];

  /// 初回リリースで表示するデッキ（チェックイン・1on1は非表示）
  static List<CardDeck> get visibleDecks => allDecks
      .where((d) =>
          d.type != CardDeckType.checkIn && d.type != CardDeckType.oneOnOne)
      .toList();

  /// [themeKey]（ARB のキー名）から議論デッキのカテゴリーIDを返す
  static String discussionCategoryIdForThemeKey(String themeKey) {
    if (themeKey.startsWith('themeProbLogical')) return 'prob_logical';
    if (themeKey.startsWith('themeProbCreative')) return 'prob_creative';
    if (themeKey.startsWith('themeProbFermi')) return 'prob_fermi';
    if (themeKey.startsWith('themeProbDilemma')) return 'prob_dilemma';
    if (themeKey.startsWith('themeSocGeo')) return 'soc_geo';
    if (themeKey.startsWith('themeSocAiGap')) return 'soc_ai_gap';
    if (themeKey.startsWith('themeSocClimate')) return 'soc_climate';
    if (themeKey.startsWith('themeSocDemocracy')) return 'soc_democracy';
    if (themeKey.startsWith('themeSocJapanDecline')) return 'soc_japan_decline';
    if (themeKey.startsWith('themeSocJapanImmigration')) {
      return 'soc_japan_immigration';
    }
    if (themeKey.startsWith('themeSocJapanWork')) return 'soc_japan_work';
    if (themeKey.startsWith('themeSocJapanLocal')) return 'soc_japan_local';
    return 'uncategorized';
  }

  static List<String> discussionCategoryDisplayOrder(CardDeckType deckType) {
    switch (deckType) {
      case CardDeckType.problemSolving:
        return const [
          'prob_logical',
          'prob_creative',
          'prob_fermi',
          'prob_dilemma',
        ];
      case CardDeckType.socialIssues:
        return const [
          'soc_geo',
          'soc_ai_gap',
          'soc_climate',
          'soc_democracy',
          'soc_japan_decline',
          'soc_japan_immigration',
          'soc_japan_work',
          'soc_japan_local',
        ];
      default:
        return const ['uncategorized'];
    }
  }

  /// l10n のカテゴリー見出し（議論画面の行タイトル）
  static String discussionCategoryTitle(
    AppLocalizations l10n,
    String categoryId,
  ) {
    switch (categoryId) {
      case 'prob_logical':
        return l10n.discussionCatProbLogical;
      case 'prob_creative':
        return l10n.discussionCatProbCreative;
      case 'prob_fermi':
        return l10n.discussionCatProbFermi;
      case 'prob_dilemma':
        return l10n.discussionCatProbDilemma;
      case 'soc_geo':
        return l10n.discussionCatSocGeo;
      case 'soc_ai_gap':
        return l10n.discussionCatSocAiGap;
      case 'soc_climate':
        return l10n.discussionCatSocClimate;
      case 'soc_democracy':
        return l10n.discussionCatSocDemocracy;
      case 'soc_japan_decline':
        return l10n.discussionCatSocJapanDecline;
      case 'soc_japan_immigration':
        return l10n.discussionCatSocJapanImmigration;
      case 'soc_japan_work':
        return l10n.discussionCatSocJapanWork;
      case 'soc_japan_local':
        return l10n.discussionCatSocJapanLocal;
      default:
        return l10n.discussionUncategorizedTitle;
    }
  }

  /// [discussionPromptCap] を適用したうえでシャッフルし、カテゴリー別の行に分割する
  static List<DiscussionCategoryGroup> buildShuffledDiscussionCategories({
    required CardDeckType deckType,
    required AppLocalizations l10n,
    required Random random,
    int? cap,
  }) {
    final deck = allDecks.firstWhere((d) => d.type == deckType);
    final n = deck.themeKeys.length;
    if (n == 0) return [];
    var pairs = List.generate(
      n,
      (i) => (
        deck.themeKeys[i],
        _getThemeString(deck.themeKeys[i], l10n),
      ),
    );
    pairs.shuffle(random);
    final maxCap = cap ?? pairs.length;
    if (maxCap < pairs.length) {
      pairs = pairs.sublist(0, maxCap);
    }
    final byCat = <String, List<String>>{};
    for (final p in pairs) {
      final id = discussionCategoryIdForThemeKey(p.$1);
      byCat.putIfAbsent(id, () => []).add(p.$2);
    }
    final order = discussionCategoryDisplayOrder(deckType);
    final out = <DiscussionCategoryGroup>[];
    final seen = <String>{};
    for (final id in order) {
      final list = byCat[id];
      if (list != null && list.isNotEmpty) {
        seen.add(id);
        out.add(
          DiscussionCategoryGroup(
            categoryId: id,
            title: discussionCategoryTitle(l10n, id),
            prompts: list,
          ),
        );
      }
    }
    for (final e in byCat.entries) {
      if (seen.contains(e.key)) continue;
      out.add(
        DiscussionCategoryGroup(
          categoryId: e.key,
          title: discussionCategoryTitle(l10n, e.key),
          prompts: e.value,
        ),
      );
    }
    return out;
  }

  /// デッキ種別なし（後方互換）: フラットなお題リストだけから1行のグループを作る
  static List<DiscussionCategoryGroup> buildFlatDiscussionCategories({
    required List<String> themes,
    required AppLocalizations l10n,
    required Random random,
    int? cap,
  }) {
    var list = List<String>.from(themes)..shuffle(random);
    final maxCap = cap ?? list.length;
    if (maxCap < list.length) {
      list = list.sublist(0, maxCap);
    }
    if (list.isEmpty) return [];
    return [
      DiscussionCategoryGroup(
        categoryId: 'uncategorized',
        title: l10n.discussionUncategorizedTitle,
        prompts: list,
      ),
    ];
  }

  /// 自己内省デッキ用: 問い→セクションIDのマップから themeCategoryMap を組み立てる
  static Map<String, ReflectionDeckCategory> buildReflectionCategoryMap(
    Map<String, String> sectionIdByTheme,
  ) {
    final map = <String, ReflectionDeckCategory>{};
    for (final e in sectionIdByTheme.entries) {
      final cat = reflectionCategoryFromSectionId(e.value);
      if (cat != null) map[e.key] = cat;
    }
    return map;
  }
}
