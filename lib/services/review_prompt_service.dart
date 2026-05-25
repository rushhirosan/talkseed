import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 3回目のセッション完了後に App Store / Google Play のレビューを促す。
class ReviewPromptService {
  ReviewPromptService._();

  static const _keyCompletedSessionCount = 'completed_session_count';
  static const _keyHasRequestedReview = 'has_requested_review';
  static const sessionThreshold = 3;

  /// セッション完了時に呼ぶ。3回目以降でレビュー未表示なら [requestReview] を試みる。
  static Future<void> onSessionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyCompletedSessionCount) ?? 0) + 1;
    await prefs.setInt(_keyCompletedSessionCount, count);

    if (count < sessionThreshold || (prefs.getBool(_keyHasRequestedReview) ?? false)) {
      return;
    }

    final review = InAppReview.instance;
    if (!await review.isAvailable()) {
      return;
    }

    await review.requestReview();
    await prefs.setBool(_keyHasRequestedReview, true);
  }

  /// テスト用: カウンタとフラグをリセット
  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompletedSessionCount);
    await prefs.remove(_keyHasRequestedReview);
  }
}
