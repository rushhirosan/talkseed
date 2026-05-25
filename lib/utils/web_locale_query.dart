import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Parses `?lang=en` / `?lang=ja` from a query value. Returns null if absent or invalid.
Locale? parseLangQueryParam(String? lang) {
  switch (lang?.toLowerCase()) {
    case 'en':
      return const Locale('en');
    case 'ja':
      return const Locale('ja');
    default:
      return null;
  }
}

/// Web-only locale override from [Uri.base] `lang` query. Mobile always returns null.
Locale? localeFromWebQuery() {
  if (!kIsWeb) return null;
  return parseLangQueryParam(Uri.base.queryParameters['lang']);
}
