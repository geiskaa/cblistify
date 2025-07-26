class Category {
  final String id; 
  final DateTime createdAt;
  final String userId;
  final String category;

  Category({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.category,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'category': category,
    };
  }
}
