import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  late ConfettiController _confettiController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _filterMode = 'all'; // 'all', 'today', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    final allCompleted = taskProvider.allTasks
        .where((t) => t.completed)
        .toList();

    switch (_filterMode) {
      case 'today':
        final today = DateTime.now();
        return allCompleted.where((task) {
          // Filter tasks completed today
          return task.dueDate != null &&
              task.dueDate!.year == today.year &&
              task.dueDate!.month == today.month &&
              task.dueDate!.day == today.day;
        }).toList();

      case 'week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return allCompleted.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              task.dueDate!.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();

      case 'month':
        final now = DateTime.now();
        return allCompleted.where((task) {
          return task.dueDate != null &&
              task.dueDate!.year == now.year &&
              task.dueDate!.month == now.month;
        }).toList();

      case 'selected':
        if (_selectedDay == null) return allCompleted;
        return allCompleted.where((task) {
          return task.dueDate != null &&
              task.dueDate!.year == _selectedDay!.year &&
              task.dueDate!.month == _selectedDay!.month &&
              task.dueDate!.day == _selectedDay!.day;
        }).toList();

      default:
        return allCompleted;
    }
  }

  Map<String, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<String, List<Task>> grouped = {};

    for (var task in tasks) {
      final dateKey = task.dueDate != null
          ? DateFormat('EEEE, MMM dd, yyyy').format(task.dueDate!)
          : 'No Due Date';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(task);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = _getFilteredTasks(taskProvider);
    final groupedTasks = _groupTasksByDate(filteredTasks);
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Completed Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      _filterMode = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All Completed'),
                    ),
                    const PopupMenuItem(value: 'today', child: Text('Today')),
                    const PopupMenuItem(
                      value: 'week',
                      child: Text('This Week'),
                    ),
                    const PopupMenuItem(
                      value: 'month',
                      child: Text('This Month'),
                    ),
                    const PopupMenuItem(
                      value: 'selected',
                      child: Text('Selected Date'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Calendar Widget
              Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _filterMode = 'selected';
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: colorScheme.error),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).scale(delay: 100.ms),

              // Filter Chip Display
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getFilterTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text('${filteredTasks.length} tasks'),
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              // Task List
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 100,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No completed tasks',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete tasks to see them here',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ).animate().fadeIn(duration: 500.ms),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: groupedTasks.length,
                        itemBuilder: (context, index) {
                          final dateKey = groupedTasks.keys.elementAt(index);
                          final tasksForDate = groupedTasks[dateKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Header
                              Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          dateKey,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${tasksForDate.length}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: (index * 100).ms)
                                  .slideX(begin: -0.2, duration: 300.ms),

                              // Tasks for this date
                              ...tasksForDate.asMap().entries.map((entry) {
                                final taskIndex = entry.key;
                                final task = entry.value;
                                return _buildTaskCard(
                                  task,
                                  taskProvider,
                                  taskIndex,
                                );
                              }),

                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
              Colors.red,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider taskProvider, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskColor = task.color != null
        ? Color(task.color!)
        : colorScheme.surfaceContainerHigh;

    return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          color: taskColor.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.lightGreen.shade300, width: 3),
          ),
          child: Stack(
            children: [
              // Status Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade700, width: 1),
                  ),
                  child: Text(
                    'Complete',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      task.emoji ?? '\ud83d\udcdd',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                title: Text(
                  task.title,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: task.category != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Chip(
                          label: Text(task.category!),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: taskColor.withOpacity(0.5),
                          labelStyle: const TextStyle(fontSize: 11),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideX(begin: 0.2, duration: 300.ms);
  }

  String _getFilterTitle() {
    switch (_filterMode) {
      case 'today':
        return 'Today\'s Completed Tasks';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'selected':
        return _selectedDay != null
            ? DateFormat('MMM dd, yyyy').format(_selectedDay!)
            : 'Selected Date';
      default:
        return 'All Completed Tasks';
    }
  }
}
