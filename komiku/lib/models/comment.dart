class Comment {
  final int id;
  final int comicId;
  final int? userId;
  final int? parentCommentId;
  final String content;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.comicId,
    this.userId,
    this.parentCommentId,
    required this.content,
    this.createdAt,
  });
}

