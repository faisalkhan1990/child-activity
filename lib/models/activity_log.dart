class ActivityLog {
  final String id;
  final String taskId;
  final String taskTitle;
  final String childId;
  final String childName;
  final String action; // 'completed', 'uncompleted', 'created', 'deleted'
  final String performedBy; // 'parent' or 'child'
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.childId,
    required this.childName,
    required this.action,
    required this.performedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'childId': childId,
      'childName': childName,
      'action': action,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      childId: json['childId'] as String,
      childName: json['childName'] as String,
      action: json['action'] as String,
      performedBy: json['performedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
