import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/discussion_category_group.dart';

void main() {
  group('CardDeck.capDiscussionGroupsRandomSample', () {
    test('returns original groups when totalCap >= prompt count', () {
      final groups = [
        const DiscussionCategoryGroup(
          categoryId: 'a',
          title: 'A',
          prompts: ['p1', 'p2'],
        ),
        const DiscussionCategoryGroup(
          categoryId: 'b',
          title: 'B',
          prompts: ['p3'],
        ),
      ];
      final out = CardDeck.capDiscussionGroupsRandomSample(
        groups: groups,
        totalCap: 10,
        random: Random(1),
      );
      expect(out.length, 2);
      expect(out[0].prompts, ['p1', 'p2']);
      expect(out[1].prompts, ['p3']);
    });

    test('reduces total prompts and drops empty categories', () {
      final groups = [
        const DiscussionCategoryGroup(
          categoryId: 'a',
          title: 'A',
          prompts: ['p1', 'p2'],
        ),
        const DiscussionCategoryGroup(
          categoryId: 'b',
          title: 'B',
          prompts: ['p3', 'p4'],
        ),
      ];
      final out = CardDeck.capDiscussionGroupsRandomSample(
        groups: groups,
        totalCap: 2,
        random: Random(42),
      );
      final flat = out.expand((g) => g.prompts).toList();
      expect(flat.length, 2);
      expect(out.every((g) => g.prompts.isNotEmpty), isTrue);
      expect(out.fold<int>(0, (s, g) => s + g.prompts.length), 2);
    });
  });
}
