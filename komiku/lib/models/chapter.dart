import 'package:komiku/models/chapter_page.dart';

class Chapter {
  final int? id;
  final String? comicTitle;
  final int chapterNumber;
  final String title;
  final List<ChapterPage> pages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Chapter({
    this.id,
    this.comicTitle,
    required this.chapterNumber,
    required this.title,
    this.pages = const [],
    this.createdAt,
    this.updatedAt,
  });

  Chapter copyWith({
    int? id,
    String? comicTitle,
    int? chapterNumber,
    String? title,
    List<ChapterPage>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      comicTitle: comicTitle ?? this.comicTitle,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int?,
      comicTitle: json['comic_title'] as String?,
      chapterNumber: json['chapter_number'] as int,
      title: json['title'] as String,
      pages: json['pages'] != null
          ? (json['pages'] as List).map((e) => ChapterPage.fromJson(e)).toList()
          : const [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comic_title': comicTitle,
      'chapter_number': chapterNumber,
      'title': title,
      'pages': pages.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Chapter(id: $id, comicTitle: $comicTitle, chapterNumber: $chapterNumber, title: $title, pages: $pages, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
