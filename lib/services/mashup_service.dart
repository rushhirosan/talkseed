import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/models/mashup_deck.dart';

/// topic_mashup_*.json からマッシュアップの軸を読み込むサービス
class MashupService {
  static const String _assetPathJa = 'data/topic_mashup.json';
  static const String _assetPathEn = 'data/topic_mashup_en.json';

  static final Map<String, MashupDeck> _cachedByLanguage = {};

  static String _assetPathFor(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return _assetPathJa;
      default:
        return _assetPathEn;
    }
  }

  static Future<MashupDeck> loadDeck({required String languageCode}) async {
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
      final deck = MashupDeck.fromJson(decoded);
      if (deck.axes.isEmpty) {
        throw DataParseException.schemaMismatch(assetPath, 'axes is empty');
      }
      _cachedByLanguage[languageCode] = deck;
      return deck;
    } on ThemeDiceException {
      rethrow;
    } catch (e) {
      throw DataParseException.invalidJson(assetPath, e);
    }
  }
}
