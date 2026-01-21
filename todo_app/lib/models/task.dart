import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  String? category;

  @HiveField(4)
  int priority; // 1: Low, 2: Medium, 3: High

  @HiveField(5)
  int? color;

  @HiveField(6)
  DateTime? dueDate;

  @HiveField(7)
  DateTime? reminderTime;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    this.category,
    this.priority = 2,
    this.color,
    this.dueDate,
    this.reminderTime,
  });

  // Copy with method for updates
  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    String? category,
    int? priority,
    int? color,
    DateTime? dueDate,
    DateTime? reminderTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'category': category,
      'priority': priority,
      'color': color,
      'dueDate': dueDate?.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      category: json['category'],
      priority: json['priority'] ?? 2,
      color: json['color'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
    );
  }
}
