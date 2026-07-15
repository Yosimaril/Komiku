class Reply {
  final int? id;
  final int? comicId;
  final int parentCommentId;
  final int? userId;
  final String? username;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Reply({
    this.id,
    this.comicId,
    required this.parentCommentId,
    this.userId,
    this.username,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  Reply copyWith({
    int? id,
    int? comicId,
    int? parentCommentId,
    int? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reply(
      id: id ?? this.id,
      comicId: comicId ?? this.comicId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] as int?,
      comicId: json['comic_id'] as int?,
      parentCommentId: json['parent_comment_id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      username: json['username'] as String?,
      content: json['content'] as String,
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
      'comic_id': comicId,
      'parent_comment_id': parentCommentId,
      'user_id': userId,
      'username': username,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Reply(id: $id, comicId: $comicId, parentCommentId: $parentCommentId, userId: $userId, username: $username, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
