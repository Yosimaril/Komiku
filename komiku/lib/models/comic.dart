import 'package:komiku/models/category.dart';
import 'package:komiku/models/chapter.dart';
import 'package:komiku/models/comment.dart';
import 'package:komiku/models/user.dart';

class Comic {
  final int? id;
  final int? creatorId;
  final User? creator;
  final String? creatorName;
  final String title;
  final String? poster;
  final String? description;
  final double? averageRating;
  final int? ratingCount;
  final List<Category> categories;
  final List<Comment> comments;
  final List<Chapter> chapters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Comic({
    this.id,
    this.creatorId,
    this.creator,
    this.creatorName,
    required this.title,
    this.poster,
    this.description,
    this.averageRating,
    this.ratingCount,
    this.categories = const [],
    this.comments = const [],
    this.chapters = const [],
    this.createdAt,
    this.updatedAt,
  });

  Comic copyWith({
    int? id,
    int? creatorId,
    User? creator,
    String? creatorName,
    String? title,
    String? poster,
    String? description,
    double? averageRating,
    int? ratingCount,
    List<Category>? categories,
    List<Comment>? comments,
    List<Chapter>? chapters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comic(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      creatorName: creatorName ?? this.creatorName,
      title: title ?? this.title,
      poster: poster ?? this.poster,
      description: description ?? this.description,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      categories: categories ?? this.categories,
      comments: comments ?? this.comments,
      chapters: chapters ?? this.chapters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'] as int?,
      creatorId: json['creator_id'] as int?,
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      creatorName: json['creator_name'] as String?,
      title: json['title'] as String,
      poster:
          json['poster'] == null ||
              json['poster'].toString().toLowerCase() == 'null'
          ? null
          : json['poster'] as String,
      description:
          json['description'] == null ||
              json['description'].toString().toLowerCase() == 'null'
          ? null
          : json['description'] as String,
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      ratingCount: json['rating_count'] as int?,
      categories: json['categories'] != null
          ? (json['categories'] as List)
                .map((e) => Category.fromJson(e))
                .toList()
          : const [],
      comments: json['comments'] != null
          ? (json['comments'] as List).map((e) => Comment.fromJson(e)).toList()
          : const [],
      chapters: json['chapters'] != null
          ? (json['chapters'] as List)
                .map(
                  (e) => Chapter.fromJson({...e, 'pages': e['chapter_pages']}),
                )
                .toList()
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
      'creator_id': creatorId,
      'creator': creator?.toJson(),
      'creator_name': creatorName,
      'title': title,
      'poster': poster,
      'description': description,
      'average_rating': averageRating,
      'rating_count': ratingCount,
      'categories': categories.map((e) => e.toJson()).toList(),
      'comments': comments.map((e) => e.toJson()).toList(),
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Comic(id: $id, title: $title, creatorName: $creatorName)';
  }
}
