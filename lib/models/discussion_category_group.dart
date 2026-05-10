/// 議論デッキ（問題解決・社会課題）のカテゴリー行：見出しとその列のお題テキスト
class DiscussionCategoryGroup {
  final String categoryId;
  final String title;
  final List<String> prompts;

  const DiscussionCategoryGroup({
    required this.categoryId,
    required this.title,
    required this.prompts,
  });
}
