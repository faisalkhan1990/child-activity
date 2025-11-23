class Task {
  final String id;
  final String title;
  final String category;
  final String childId;
  final List<String> days; // Monday, Tuesday, etc.
  final bool isCompleted; // Deprecated - kept for backward compatibility
  final Map<String, bool> completionStatus; // Track completion per day
  final DateTime createdDate;
  final String priority; // 'low', 'medium', 'high'
  final int points; // Points earned when task is completed

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.childId,
    required this.days,
    this.isCompleted = false,
    Map<String, bool>? completionStatus,
    required this.createdDate,
    this.priority = 'medium',
    this.points = 10,
  }) : completionStatus = completionStatus ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'childId': childId,
      'days': days,
      'isCompleted': isCompleted,
      'completionStatus': completionStatus,
      'createdDate': createdDate.toIso8601String(),
      'priority': priority,
      'points': points,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final completionMap = json['completionStatus'] as Map<dynamic, dynamic>?;
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      childId: json['childId'] as String,
      days: List<String>.from(json['days'] as List),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionStatus: completionMap != null
          ? Map<String, bool>.from(completionMap)
          : {},
      createdDate: DateTime.parse(json['createdDate'] as String),
      priority: json['priority'] as String? ?? 'medium',
      points: json['points'] as int? ?? 10,
    );
  }

  // Check if task is completed for a specific day
  bool isCompletedForDay(String day) {
    return completionStatus[day] ?? false;
  }

  // Check if task is fully completed (all days)
  bool get isFullyCompleted {
    if (days.isEmpty) return isCompleted;
    return days.every((day) => completionStatus[day] ?? false);
  }

  // Get completion count
  int get completedDaysCount {
    return completionStatus.values.where((completed) => completed).length;
  }

  Task copyWith({
    String? id,
    String? title,
    String? category,
    String? childId,
    List<String>? days,
    bool? isCompleted,
    Map<String, bool>? completionStatus,
    DateTime? createdDate,
    String? priority,
    int? points,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      childId: childId ?? this.childId,
      days: days ?? this.days,
      isCompleted: isCompleted ?? this.isCompleted,
      completionStatus: completionStatus ?? this.completionStatus,
      createdDate: createdDate ?? this.createdDate,
      priority: priority ?? this.priority,
      points: points ?? this.points,
    );
  }
}
