/// Editorial content model for the Ratgeber (knowledge base).
///
/// Articles are **general legal information**, not individual legal advice
/// (RDG/StBerG line, see ASSUMPTIONS in the repo root): every article
/// carries its legal sources and a review date so the content stays
/// auditable and maintainable, mirroring the versioned parameter file of
/// the engine.
library;

/// Thematic category of a Ratgeber article.
enum ArticleCategory { verhandlung, rechtsgrundlagen, arbeitsagentur }

extension ArticleCategoryLabel on ArticleCategory {
  String get label => switch (this) {
        ArticleCategory.verhandlung => 'Verhandlung',
        ArticleCategory.rechtsgrundlagen => 'Rechtsgrundlagen',
        ArticleCategory.arbeitsagentur => 'Arbeitsagentur & Leistungen',
      };
}

/// One section of an article (heading + body paragraph).
class ArticleSection {
  const ArticleSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// A single Ratgeber article.
class Article {
  const Article({
    required this.id,
    required this.category,
    required this.title,
    required this.teaser,
    required this.sections,
    required this.sources,
  });

  final String id;
  final ArticleCategory category;
  final String title;

  /// One-line summary for the list view.
  final String teaser;

  final List<ArticleSection> sections;

  /// Legal sources (e.g. `§ 4 KSchG`) shown at the end of the article.
  final List<String> sources;
}
