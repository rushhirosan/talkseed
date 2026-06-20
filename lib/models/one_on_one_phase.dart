import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';

/// ガイド付き1on1の5フェーズ（問いバンク7セクションを統合）
enum OneOnOnePhase {
  checkin,
  workAndWorkstyle,
  growthAndCareer,
  growthRelationship,
  closing;

  static const List<OneOnOnePhase> orderedPhases = [
    checkin,
    workAndWorkstyle,
    growthAndCareer,
    growthRelationship,
    closing,
  ];

  /// セッション履歴保存用キー
  String get sessionId {
    switch (this) {
      case OneOnOnePhase.checkin:
        return 'checkin';
      case OneOnOnePhase.workAndWorkstyle:
        return 'workAndWorkstyle';
      case OneOnOnePhase.growthAndCareer:
        return 'growthAndCareer';
      case OneOnOnePhase.growthRelationship:
        return 'growthRelationship';
      case OneOnOnePhase.closing:
        return 'closing';
    }
  }

  /// [self_reflection_1on1.json] からマージするセクションキー
  List<String> get questionSectionIds {
    switch (this) {
      case OneOnOnePhase.checkin:
        return const ['checkin'];
      case OneOnOnePhase.workAndWorkstyle:
        return const ['workStatus', 'motivationWorkstyle'];
      case OneOnOnePhase.growthAndCareer:
        return const ['selfReflection', 'careerFuture'];
      case OneOnOnePhase.growthRelationship:
        return const ['growthRelationship'];
      case OneOnOnePhase.closing:
        return const ['closing'];
    }
  }

  String title(AppLocalizations l10n) {
    switch (this) {
      case OneOnOnePhase.checkin:
        return l10n.oneOnOnePhaseCheckin;
      case OneOnOnePhase.workAndWorkstyle:
        return l10n.oneOnOnePhaseWorkAndWorkstyle;
      case OneOnOnePhase.growthAndCareer:
        return l10n.oneOnOnePhaseGrowthAndCareer;
      case OneOnOnePhase.growthRelationship:
        return l10n.oneOnOnePhaseGrowth;
      case OneOnOnePhase.closing:
        return l10n.oneOnOnePhaseClosing;
    }
  }

  String hint(AppLocalizations l10n) {
    switch (this) {
      case OneOnOnePhase.checkin:
        return l10n.oneOnOnePhaseHintCheckin;
      case OneOnOnePhase.workAndWorkstyle:
        return l10n.oneOnOnePhaseHintWorkAndWorkstyle;
      case OneOnOnePhase.growthAndCareer:
        return l10n.oneOnOnePhaseHintGrowthAndCareer;
      case OneOnOnePhase.growthRelationship:
        return l10n.oneOnOnePhaseHintGrowth;
      case OneOnOnePhase.closing:
        return l10n.oneOnOnePhaseHintClosing;
    }
  }

  static String titleForSessionId(AppLocalizations l10n, String sessionId) {
    for (final phase in orderedPhases) {
      if (phase.sessionId == sessionId) {
        return phase.title(l10n);
      }
    }
    return ReflectionDeckCategory.titleForSectionId(l10n, sessionId);
  }
}

/// ガイド付き1on1のセッション型プリセット
enum OneOnOneSessionFormat {
  lite,
  growth,
  relationship,
  full;

  List<OneOnOnePhase> get phases {
    switch (this) {
      case OneOnOneSessionFormat.lite:
        return const [
          OneOnOnePhase.checkin,
          OneOnOnePhase.workAndWorkstyle,
          OneOnOnePhase.closing,
        ];
      case OneOnOneSessionFormat.growth:
        return const [
          OneOnOnePhase.checkin,
          OneOnOnePhase.workAndWorkstyle,
          OneOnOnePhase.growthAndCareer,
          OneOnOnePhase.closing,
        ];
      case OneOnOneSessionFormat.relationship:
        return const [
          OneOnOnePhase.checkin,
          OneOnOnePhase.workAndWorkstyle,
          OneOnOnePhase.growthRelationship,
          OneOnOnePhase.closing,
        ];
      case OneOnOneSessionFormat.full:
        return OneOnOnePhase.orderedPhases;
    }
  }

  String title(AppLocalizations l10n) {
    switch (this) {
      case OneOnOneSessionFormat.lite:
        return l10n.oneOnOneFormatLite;
      case OneOnOneSessionFormat.growth:
        return l10n.oneOnOneFormatGrowth;
      case OneOnOneSessionFormat.relationship:
        return l10n.oneOnOneFormatRelationship;
      case OneOnOneSessionFormat.full:
        return l10n.oneOnOneFormatFull;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case OneOnOneSessionFormat.lite:
        return l10n.oneOnOneFormatLiteDesc;
      case OneOnOneSessionFormat.growth:
        return l10n.oneOnOneFormatGrowthDesc;
      case OneOnOneSessionFormat.relationship:
        return l10n.oneOnOneFormatRelationshipDesc;
      case OneOnOneSessionFormat.full:
        return l10n.oneOnOneFormatFullDesc;
    }
  }

  IconData get icon {
    switch (this) {
      case OneOnOneSessionFormat.lite:
        return Icons.bolt_outlined;
      case OneOnOneSessionFormat.growth:
        return Icons.trending_up;
      case OneOnOneSessionFormat.relationship:
        return Icons.people_outline;
      case OneOnOneSessionFormat.full:
        return Icons.layers_outlined;
    }
  }
}
