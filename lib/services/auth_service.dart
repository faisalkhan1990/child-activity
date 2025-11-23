import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parent.dart';
import '../models/child.dart';
import '../models/task.dart';
import '../models/activity_log.dart';

class AuthService extends ChangeNotifier {
  Parent? _currentParent;
  List<Child> _children = [];
  List<Task> _tasks = [];
  List<ActivityLog> _activityLogs = [];
  bool _isLoading = false;

  Parent? get currentParent => _currentParent;
  List<Child> get children => _children;
  List<Task> get tasks => _tasks;
  List<ActivityLog> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentParent != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final parentData = prefs.getString('currentParent');
    
    if (parentData != null) {
      _currentParent = Parent.fromJson(json.decode(parentData));
      await loadChildren();
      await loadTasks();
      await loadActivityLogs();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signup(String email, String name, String password) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    
    // Check if user already exists
    final existingUsers = prefs.getStringList('users') ?? [];
    for (var userData in existingUsers) {
      final user = Parent.fromJson(json.decode(userData));
      if (user.email == email) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }
    }

    // Create new parent
    final parent = Parent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      password: password,
    );

    existingUsers.add(json.encode(parent.toJson()));
    await prefs.setStringList('users', existingUsers);

    _currentParent = parent;
    await prefs.setString('currentParent', json.encode(parent.toJson()));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final existingUsers = prefs.getStringList('users') ?? [];

    for (var userData in existingUsers) {
      final user = Parent.fromJson(json.decode(userData));
      if (user.email == email && user.password == password) {
        _currentParent = user;
        await prefs.setString('currentParent', json.encode(user.toJson()));
        await loadChildren();
        await loadTasks();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false; // Invalid credentials
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentParent');
    _currentParent = null;
    _children = [];
    _tasks = [];
    _activityLogs = [];
    notifyListeners();
  }

  Future<void> addChild(String name, String age) async {
    if (_currentParent == null) return;

    final child = Child(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      parentId: _currentParent!.id,
      dateAdded: DateTime.now(),
    );

    _children.add(child);
    await saveChildren();
    notifyListeners();
  }

  Future<void> loadChildren() async {
    if (_currentParent == null) return;

    final prefs = await SharedPreferences.getInstance();
    final childrenData = prefs.getStringList('children_${_currentParent!.id}') ?? [];
    
    _children = childrenData
        .map((data) => Child.fromJson(json.decode(data)))
        .toList();
    
    notifyListeners();
  }

  Future<void> saveChildren() async {
    if (_currentParent == null) return;

    final prefs = await SharedPreferences.getInstance();
    final childrenData = _children.map((child) => json.encode(child.toJson())).toList();
    await prefs.setStringList('children_${_currentParent!.id}', childrenData);
  }

  Future<void> deleteChild(String childId) async {
    _children.removeWhere((child) => child.id == childId);
    // Also delete all tasks for this child
    _tasks.removeWhere((task) => task.childId == childId);
    await saveChildren();
    await saveTasks();
    notifyListeners();
  }

  // Task Management
  List<Task> getTasksForChild(String childId) {
    return _tasks.where((task) => task.childId == childId).toList();
  }

  List<Task> getTasksForDay(String childId, String day) {
    return _tasks
        .where((task) => task.childId == childId && task.days.contains(day))
        .toList();
  }

  Future<void> addTask(
    String title,
    String category,
    String childId,
    List<String> days, {
    String priority = 'medium',
    int points = 10,
  }) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      childId: childId,
      days: days,
      createdDate: DateTime.now(),
      priority: priority,
      points: points,
    );

    _tasks.add(task);
    await saveTasks();
    
    // Log task creation
    final child = _children.firstWhere((c) => c.id == childId, orElse: () => Child(id: '', name: 'Unknown', age: '', parentId: '', dateAdded: DateTime.now()));
    await addActivityLog(task.id, task.title, childId, child.name, 'created', 'parent');
    
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId, orElse: () => Task(id: '', title: 'Unknown', category: '', childId: '', days: [], createdDate: DateTime.now()));
    final child = _children.firstWhere((c) => c.id == task.childId, orElse: () => Child(id: '', name: 'Unknown', age: '', parentId: '', dateAdded: DateTime.now()));
    
    _tasks.removeWhere((task) => task.id == taskId);
    await saveTasks();
    
    // Log task deletion
    await addActivityLog(task.id, task.title, task.childId, child.name, 'deleted', 'parent');
    
    notifyListeners();
  }

  // Ledger to track points per child (in-memory, not persisted)
  final Map<String, int> _pointsLedger = {};

  Future<void> toggleTaskCompletion(String taskId, String performedBy, {String? specificDay}) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final childId = task.childId;
      final points = task.points;
      if (specificDay != null && task.days.contains(specificDay)) {
        // Toggle completion for specific day
        final newCompletionStatus = Map<String, bool>.from(task.completionStatus);
        final currentStatus = newCompletionStatus[specificDay] ?? false;
        newCompletionStatus[specificDay] = !currentStatus;

        // Update points ledger
        if (!currentStatus) {
          // Marking complete, add points
          _pointsLedger[childId] = (_pointsLedger[childId] ?? 0) + points;
        } else {
          // Marking pending, subtract points
          _pointsLedger[childId] = (_pointsLedger[childId] ?? 0) - points;
          if (_pointsLedger[childId]! < 0) _pointsLedger[childId] = 0;
        }

        _tasks[index] = task.copyWith(
          completionStatus: newCompletionStatus,
          isCompleted: newCompletionStatus.values.every((v) => v), // All days completed
        );

        // Log task status change with day info
        final child = _children.firstWhere((c) => c.id == childId, orElse: () => Child(id: '', name: 'Unknown', age: '', parentId: '', dateAdded: DateTime.now()));
        await addActivityLog(
          task.id, 
          '${task.title} ($specificDay)', 
          childId, 
          child.name, 
          !currentStatus ? 'completed' : 'uncompleted', 
          performedBy
        );
      } else {
        // Toggle all days (backward compatibility or for tasks without specific days)
        final newStatus = !task.isCompleted;
        final newCompletionStatus = Map<String, bool>.from(task.completionStatus);
        for (var day in task.days) {
          // Update points ledger for each day
          final currentStatus = newCompletionStatus[day] ?? false;
          newCompletionStatus[day] = newStatus;
          if (newStatus && !currentStatus) {
            _pointsLedger[childId] = (_pointsLedger[childId] ?? 0) + points;
          } else if (!newStatus && currentStatus) {
            _pointsLedger[childId] = (_pointsLedger[childId] ?? 0) - points;
            if (_pointsLedger[childId]! < 0) _pointsLedger[childId] = 0;
          }
        }

        _tasks[index] = task.copyWith(
          isCompleted: newStatus,
          completionStatus: newCompletionStatus,
        );

        // Log task status change
        final child = _children.firstWhere((c) => c.id == childId, orElse: () => Child(id: '', name: 'Unknown', age: '', parentId: '', dateAdded: DateTime.now()));
        await addActivityLog(
          task.id, 
          task.title, 
          childId, 
          child.name, 
          newStatus ? 'completed' : 'uncompleted', 
          performedBy
        );
      }

      await saveTasks();
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    if (_currentParent == null) return;

    final prefs = await SharedPreferences.getInstance();
    final tasksData = prefs.getStringList('tasks_${_currentParent!.id}') ?? [];
    
    _tasks = tasksData
        .map((data) => Task.fromJson(json.decode(data)))
        .toList();
    
    notifyListeners();
  }

  Future<void> saveTasks() async {
    if (_currentParent == null) return;

    final prefs = await SharedPreferences.getInstance();
    final tasksData = _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks_${_currentParent!.id}', tasksData);
  }

  // Activity Log Management
  Future<void> addActivityLog(
    String taskId,
    String taskTitle,
    String childId,
    String childName,
    String action,
    String performedBy,
  ) async {
    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      taskTitle: taskTitle,
      childId: childId,
      childName: childName,
      action: action,
      performedBy: performedBy,
      timestamp: DateTime.now(),
    );

    _activityLogs.add(log);
    await saveActivityLogs();
    notifyListeners();
  }

  Future<void> loadActivityLogs() async {
    if (_currentParent == null) return;

    final prefs = await SharedPreferences.getInstance();
    final logsData = prefs.getStringList('activity_logs_${_currentParent!.id}') ?? [];
    
    _activityLogs = logsData
        .map((data) => ActivityLog.fromJson(json.decode(data)))
        .toList();
    
    // Sort by timestamp (newest first)
    _activityLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    notifyListeners();
  }

  Future<void> saveActivityLogs() async {
    if (_currentParent == null) return;

    final prefs = await SharedPreferences.getInstance();
    final logsData = _activityLogs.map((log) => json.encode(log.toJson())).toList();
    await prefs.setStringList('activity_logs_${_currentParent!.id}', logsData);
  }

  List<ActivityLog> getActivityLogsForChild(String childId) {
    return _activityLogs.where((log) => log.childId == childId).toList();
  }

  // Points and Ranking System
  int getTotalPointsForChild(String childId) {
    int totalPoints = 0;
    for (var task in _tasks.where((t) => t.childId == childId)) {
      // Award points for each day completed
      totalPoints += task.completedDaysCount * task.points;
    }
    return totalPoints;
  }

  int getMonthlyPointsForChild(String childId, int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    // Get logs for completed tasks in this month
    final completedLogs = _activityLogs.where((log) =>
      log.childId == childId &&
      log.action == 'completed' &&
      log.timestamp.isAfter(startOfMonth) &&
      log.timestamp.isBefore(endOfMonth)
    );

    int totalPoints = 0;
    for (var log in completedLogs) {
      final task = _tasks.firstWhere(
        (t) => t.id == log.taskId,
        orElse: () => Task(
          id: '',
          title: '',
          category: '',
          childId: '',
          days: [],
          createdDate: DateTime.now(),
          points: 0,
        ),
      );
      totalPoints += task.points;
    }

    return totalPoints;
  }

  List<Map<String, dynamic>> getMonthlyRankings(int year, int month) {
    final rankings = <Map<String, dynamic>>[];

    for (var child in _children) {
      final points = getMonthlyPointsForChild(child.id, year, month);
      final completedTasks = _tasks.where((t) => 
        t.childId == child.id && 
        t.isCompleted
      ).length;
      
      rankings.add({
        'child': child,
        'points': points,
        'completedTasks': completedTasks,
      });
    }

    // Sort by points (descending)
    rankings.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

    // Add rank
    for (int i = 0; i < rankings.length; i++) {
      rankings[i]['rank'] = i + 1;
    }

    return rankings;
  }

  Map<String, dynamic> getChildStats(String childId) {
    final totalPoints = getTotalPointsForChild(childId);
    final now = DateTime.now();
    final monthlyPoints = getMonthlyPointsForChild(childId, now.year, now.month);
    final totalTasks = _tasks.where((t) => t.childId == childId).length;
    final completedTasks = _tasks.where((t) => t.childId == childId && t.isCompleted).length;
    
    return {
      'totalPoints': totalPoints,
      'monthlyPoints': monthlyPoints,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
    };
  }
}
