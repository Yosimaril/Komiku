class User {
  final int? id;
  final String username;
  final String? password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.username,
    this.password,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String,
      password: json['password'] as String?,
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
      'username': username,
      if (password != null) 'password': password,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
