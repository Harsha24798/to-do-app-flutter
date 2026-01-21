import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class HiveService {
  static const String _taskBoxName = 'tasks';
  static const String _settingsBoxName = 'settings';

  // Initialize Hive
  static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Task>(_taskBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // Get task box
  static Box<Task> getTaskBox() {
    return Hive.box<Task>(_taskBoxName);
  }

  // Get settings box
  static Box getSettingsBox() {
    return Hive.box(_settingsBoxName);
  }

  // Save a task
  Future<void> saveTask(Task task) async {
    final box = getTaskBox();
    await box.put(task.id, task);
  }

  // Get all tasks
  List<Task> getTasks() {
    final box = getTaskBox();
    return box.values.toList();
  }

  // Get a specific task by ID
  Task? getTask(String id) {
    final box = getTaskBox();
    return box.get(id);
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    final box = getTaskBox();
    await box.put(task.id, task);
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    final box = getTaskBox();
    await box.delete(id);
  }

  // Delete all tasks
  Future<void> deleteAllTasks() async {
    final box = getTaskBox();
    await box.clear();
  }

  // Get tasks by category
  List<Task> getTasksByCategory(String category) {
    final box = getTaskBox();
    return box.values.where((task) => task.category == category).toList();
  }

  // Get completed tasks
  List<Task> getCompletedTasks() {
    final box = getTaskBox();
    return box.values.where((task) => task.completed).toList();
  }

  // Get incomplete tasks
  List<Task> getIncompleteTasks() {
    final box = getTaskBox();
    return box.values.where((task) => !task.completed).toList();
  }

  // Get tasks sorted by priority
  List<Task> getTasksByPriority() {
    final box = getTaskBox();
    final tasks = box.values.toList();
    tasks.sort((a, b) => b.priority.compareTo(a.priority));
    return tasks;
  }

  // Get tasks sorted by due date
  List<Task> getTasksByDueDate() {
    final box = getTaskBox();
    final tasks = box.values.where((task) => task.dueDate != null).toList();
    tasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return tasks;
  }

  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async {
    final box = getSettingsBox();
    await box.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = getSettingsBox();
    return box.get(key, defaultValue: defaultValue);
  }

  // Close all boxes
  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
