import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/models/bingo_deck.dart';

/// conversation_bingo_*.json からビンゴのお題を読み込む
class BingoService {
  static const String _assetPathJa = 'data/conversation_bingo.json';
  static const String _assetPathEn = 'data/conversation_bingo_en.json';

  static final Map<String, BingoDeck> _cachedByLanguage = {};

  static String _assetPathFor(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return _assetPathJa;
      default:
        return _assetPathEn;
    }
  }

  static Future<BingoDeck> loadDeck({required String languageCode}) async {
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
      final deck = BingoDeck.fromJson(decoded);
      final minCells =
          BingoBoard.cellCountForSize(BingoBoard.sizeLarge);
      if (deck.prompts.length < minCells) {
        throw DataParseException.schemaMismatch(
          assetPath,
          'prompts must have at least $minCells items',
        );
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
