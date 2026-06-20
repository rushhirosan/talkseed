import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';

/// self_reflection_1on1_*.json から問いを読み込むサービス
/// セクションID: checkin | workStatus | selfReflection | growthRelationship |
/// careerFuture | motivationWorkstyle | closing
class SelfReflectionService {
  static const String _assetPathJa = 'data/self_reflection_1on1.json';
  static const String _assetPathEn = 'data/self_reflection_1on1_en.json';

  static final Map<String, Map<String, dynamic>> _cachedByLanguage = {};

  static String _assetPathFor(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return _assetPathJa;
      case 'en':
        return _assetPathEn;
      default:
        return _assetPathEn;
    }
  }

  static Future<Map<String, dynamic>> _loadJson(String languageCode) async {
    final cached = _cachedByLanguage[languageCode];
    if (cached != null) return cached;

    final assetPath = _assetPathFor(languageCode);
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(assetPath);
    } catch (e) {
      throw DataLoadException.assetLoadFailed(assetPath, e);
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw DataParseException.schemaMismatch(
          assetPath,
          'Expected Map, got ${decoded.runtimeType}',
        );
      }
      _cachedByLanguage[languageCode] = decoded;
      return decoded;
    } on ThemeDiceException {
      rethrow;
    } catch (e) {
      throw DataParseException.invalidJson(assetPath, e);
    }
  }

  /// 全問いとセクションIDのペアを返す（表示順）
  static Future<List<({String question, String sectionId})>> loadQuestions({
    required String languageCode,
  }) async {
    final data = await _loadJson(languageCode);
    final sections = data['sections'] as Map<String, dynamic>? ?? {};
    final result = <({String question, String sectionId})>[];
    for (final entry in sections.entries) {
      final sectionId = entry.key;
      final list = (entry.value as List<dynamic>?)?.cast<String>() ?? [];
      for (final q in list) {
        result.add((question: q, sectionId: sectionId));
      }
    }
    return result;
  }

  /// 問い文字列のリストと、問い→セクションIDのマップを返す
  static Future<
      ({
        List<String> themes,
        Map<String, String> sectionIdByTheme,
      })> loadThemesWithSections({
    required String languageCode,
  }) async {
    final items = await loadQuestions(languageCode: languageCode);
    final themes = items.map((e) => e.question).toList();
    final sectionIdByTheme = {for (final e in items) e.question: e.sectionId};
    return (
      themes: themes,
      sectionIdByTheme: sectionIdByTheme,
    );
  }

  /// ガイド付き1on1用：5フェーズごとの問いリスト（JSON 7セクションをマージ）
  static Future<Map<OneOnOnePhase, List<String>>> loadSessionPhases({
    required String languageCode,
  }) async {
    final data = await _loadJson(languageCode);
    final sections = data['sections'] as Map<String, dynamic>? ?? {};
    final questionsByPhase = <OneOnOnePhase, List<String>>{};

    for (final phase in OneOnOnePhase.orderedPhases) {
      final merged = <String>[];
      for (final sectionId in phase.questionSectionIds) {
        final list =
            (sections[sectionId] as List<dynamic>?)?.cast<String>() ?? [];
        merged.addAll(list);
      }
      questionsByPhase[phase] = merged;
    }

    return questionsByPhase;
  }
}
