import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/models/checkin_checkout_item.dart';

/// checkin_checkout_work.json から問いを読み込むサービス
class CheckInCheckOutService {
  static const String _assetPath = 'data/checkin_checkout_work.json';

  static Map<String, dynamic>? _cached;

  /// JSON を読み込み、キャッシュする
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

  static List<CheckInCheckOutItem> _itemsFromSection(
    Map<String, dynamic> section,
  ) {
    final beginner =
        (section['beginner'] as List<dynamic>?)?.cast<String>() ?? [];
    final intermediate =
        (section['intermediate'] as List<dynamic>?)?.cast<String>() ?? [];
    final advanced =
        (section['advanced'] as List<dynamic>?)?.cast<String>() ?? [];
    return [
      ...beginner.map((t) => CheckInCheckOutItem(text: t, level: CheckInLevel.beginner)),
      ...intermediate.map((t) => CheckInCheckOutItem(text: t, level: CheckInLevel.intermediate)),
      ...advanced.map((t) => CheckInCheckOutItem(text: t, level: CheckInLevel.advanced)),
    ];
  }

  /// チェックイン用の問い一覧（初級・中級・上級付き）
  static Future<List<CheckInCheckOutItem>> loadCheckInItems() async {
    final data = await _loadJson();
    final checkIn = data['checkIn'] as Map<String, dynamic>? ?? {};
    return _itemsFromSection(checkIn);
  }

  /// チェックアウト用の問い一覧（初級・中級・上級付き）
  static Future<List<CheckInCheckOutItem>> loadCheckOutItems() async {
    final data = await _loadJson();
    final checkOut = data['checkOut'] as Map<String, dynamic>? ?? {};
    return _itemsFromSection(checkOut);
  }

  /// チェックイン用の問い一覧（文字列のみ・後方互換）
  static Future<List<String>> loadCheckInQuestions() async {
    final items = await loadCheckInItems();
    return items.map((e) => e.text).toList();
  }

  /// チェックアウト用の問い一覧（文字列のみ・後方互換）
  static Future<List<String>> loadCheckOutQuestions() async {
    final items = await loadCheckOutItems();
    return items.map((e) => e.text).toList();
  }

  /// チェックイン・チェックアウト統合（両方の問いをまとめて返す）
  static Future<List<String>> loadCheckInCheckOutQuestions() async {
    final checkIn = await loadCheckInQuestions();
    final checkOut = await loadCheckOutQuestions();
    return [...checkIn, ...checkOut];
  }
}
