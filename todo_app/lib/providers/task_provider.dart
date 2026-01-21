import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final NotificationService _notificationService = NotificationService();

  List<Task> _tasks = [];
  String _filterCategory = 'All';
  int _sortOption = 0; // 0: None, 1: Priority, 2: Due Date
  bool _showCompleted = true;

  List<Task> get tasks {
    List<Task> filteredTasks = _tasks;

    // Filter by category
    if (_filterCategory != 'All') {
      filteredTasks =
          filteredTasks.where((task) => task.category == _filterCategory).toList();
    }

    // Filter completed tasks
    if (!_showCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.completed).toList();
    }

    // Sort tasks
    switch (_sortOption) {
      case 1: // By Priority
        filteredTasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 2: // By Due Date
        filteredTasks = filteredTasks.where((task) => task.dueDate != null).toList();
        filteredTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
        break;
      default:
        // No sorting
        break;
    }

    return filteredTasks;
  }

  List<Task> get allTasks => _tasks;
  String get filterCategory => _filterCategory;
  int get sortOption => _sortOption;
  bool get showCompleted => _showCompleted;

  // Load tasks from Hive
  Future<void> loadTasks() async {
    _tasks = _hiveService.getTasks();
    notifyListeners();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    await _hiveService.saveTask(task);
    _tasks.add(task);
    
    // Schedule notification if reminder time is set
    if (task.reminderTime != null) {
      await _notificationService.scheduleNotification(task: task);
    }
    
    notifyListeners();
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _hiveService.updateTask(task);
    
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    
    // Reschedule notification
    if (task.reminderTime != null) {
      await _notificationService.rescheduleNotification(task);
    } else {
      await _notificationService.cancelNotification(task.id);
    }
    
    notifyListeners();
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _hiveService.deleteTask(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    
    // Cancel notification
    await _notificationService.cancelNotification(taskId);
    
    notifyListeners();
  }

  // Toggle task completion
  Future<void> toggleComplete(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(completed: !task.completed);
    await updateTask(updatedTask);
  }

  // Delete all tasks
  Future<void> deleteAllTasks() async {
    await _hiveService.deleteAllTasks();
    await _notificationService.cancelAllNotifications();
    _tasks.clear();
    notifyListeners();
  }

  // Set filter category
  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  // Set sort option
  void setSortOption(int option) {
    _sortOption = option;
    notifyListeners();
  }

  // Toggle show completed
  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  // Get task by ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories
  List<String> getCategories() {
    final categories = _tasks
        .where((task) => task.category != null)
        .map((task) => task.category!)
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  // Get task count by status
  int get completedCount => _tasks.where((task) => task.completed).length;
  int get incompleteCount => _tasks.where((task) => !task.completed).length;
  int get totalCount => _tasks.length;

  // Get overdue tasks
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate != null &&
          task.dueDate!.isBefore(now) &&
          !task.completed;
    }).toList();
  }

  // Get today's tasks
  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _tasks.where((task) {
      return task.dueDate != null &&
          task.dueDate!.isAfter(today) &&
          task.dueDate!.isBefore(tomorrow);
    }).toList();
  }

  // Get upcoming tasks (next 7 days)
  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return _tasks.where((task) {
      return task.dueDate != null &&
          task.dueDate!.isAfter(now) &&
          task.dueDate!.isBefore(nextWeek) &&
          !task.completed;
    }).toList();
  }
}
