import 'package:exitkompass_app/content/models.dart';
import 'package:exitkompass_app/content/ratgeber_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ratgeber content integrity', () {
    test('there is content in every category', () {
      for (final category in ArticleCategory.values) {
        expect(ratgeberArticles.any((a) => a.category == category), isTrue,
            reason: 'no article in ${category.label}');
      }
    });

    test('article ids are unique', () {
      final ids = ratgeberArticles.map((a) => a.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('every article has a title, teaser, sections and at least one source', () {
      for (final a in ratgeberArticles) {
        expect(a.title.trim(), isNotEmpty);
        expect(a.teaser.trim(), isNotEmpty);
        expect(a.sections, isNotEmpty, reason: '${a.id} has no sections');
        expect(a.sources, isNotEmpty, reason: '${a.id} has no legal sources');
        for (final s in a.sections) {
          expect(s.heading.trim(), isNotEmpty);
          expect(s.body.trim(), isNotEmpty);
        }
      }
    });

    test('a review date is set', () {
      expect(contentReviewedOn.trim(), isNotEmpty);
    });
  });
}
