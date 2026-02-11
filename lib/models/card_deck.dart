import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

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
