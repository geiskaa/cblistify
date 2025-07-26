class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final int priority; 
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String categoryId;
  final bool isCompleted; 

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    required this.categoryId,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      categoryId: json['category_id'],
      isCompleted: json['is_completed'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category_id': categoryId,
      'is_completed': isCompleted, 
    };
  }
}