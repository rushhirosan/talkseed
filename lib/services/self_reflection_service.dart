import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';

/// self_reflection_1on1.json から問いを読み込むサービス
/// セクションID: checkin | selfReflection | growthRelationship
class SelfReflectionService {
  static const String _assetPath = 'data/self_reflection_1on1.json';

  static Map<String, dynamic>? _cached;

  static Future<Map<String, dynamic>> _loadJson() async {
    if (_cached != null) return _cached!;
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(_assetPath);
    } catch (e) {
      throw DataLoadException.assetLoadFailed(_assetPath, e);
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw DataParseException.schemaMismatch(
          _assetPath,
          'Expected Map, got ${decoded.runtimeType}',
        );
      }
      _cached = decoded;
      return _cached!;
    } on ThemeDiceException {
      rethrow;
    } catch (e) {
      throw DataParseException.invalidJson(_assetPath, e);
    }
  }

  /// 全問いとセクションIDのペアを返す（表示順）
  static Future<List<({String question, String sectionId})>> loadQuestions() async {
    final data = await _loadJson();
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
  static Future<({List<String> themes, Map<String, String> sectionIdByTheme})> loadThemesWithSections() async {
    final items = await loadQuestions();
    final themes = items.map((e) => e.question).toList();
    final sectionIdByTheme = {for (final e in items) e.question: e.sectionId};
    return (themes: themes, sectionIdByTheme: sectionIdByTheme);
  }
}
