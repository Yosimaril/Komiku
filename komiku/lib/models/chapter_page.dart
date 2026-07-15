class ChapterPage {
  final int? id;
  final String? chapterTitle;
  final int pageNumber;
  final String image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChapterPage({
    this.id,
    this.chapterTitle,
    required this.pageNumber,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  ChapterPage copyWith({
    int? id,
    String? chapterTitle,
    int? pageNumber,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChapterPage(
      id: id ?? this.id,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      pageNumber: pageNumber ?? this.pageNumber,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChapterPage.fromJson(Map<String, dynamic> json) {
    return ChapterPage(
      id: json['id'] as int?,
      chapterTitle: json['chapter_title'] as String?,
      pageNumber: json['page_number'] as int,
      image: json['image'] as String,
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
      'chapter_title': chapterTitle,
      'page_number': pageNumber,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChapterPage(id: $id, chapterTitle: $chapterTitle, pageNumber: $pageNumber, image: $image, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
