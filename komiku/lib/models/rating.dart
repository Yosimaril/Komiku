class Rating {
  final int comicId;
  final int? userId;
  final int rating;

  const Rating({required this.comicId, this.userId, required this.rating});

  Rating copyWith({int? comicId, int? userId, int? rating}) {
    return Rating(
      comicId: comicId ?? this.comicId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
    );
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      comicId: json['comic_id'] as int,
      userId: json['user_id'] as int?,
      rating: json['rating'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comic_id': comicId,
      if (userId != null) 'user_id': userId,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'Rating(comicId: $comicId, userId: $userId, rating: $rating)';
  }
}
