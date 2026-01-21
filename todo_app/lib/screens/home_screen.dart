import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'completed_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Icons.task_alt, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'My Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
            elevation: 0,
            actions: [
              // Completed tasks button
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: IconButton(
              //     icon: const Icon(Icons.check_circle),
              //     tooltip: 'Completed Tasks',
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const CompletedTasksScreen(),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              // Filter menu
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    context.read<TaskProvider>().setFilterCategory(value);
                  },
                  itemBuilder: (context) {
                    final categories = context
                        .read<TaskProvider>()
                        .getCategories();
                    return categories.map((category) {
                      return PopupMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList();
                  },
                ),
              ),
              // Sort menu
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<int>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    context.read<TaskProvider>().setSortOption(value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 0, child: Text('Default')),
                    const PopupMenuItem(value: 1, child: Text('By Priority')),
                    const PopupMenuItem(value: 2, child: Text('By Due Date')),
                  ],
                ),
              ),
              // Settings
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final tasks = taskProvider.tasks;

              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add a new task',
                        style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                );
              }

              return Column(
                children: [
                  // Task statistics
                  _buildStatistics(taskProvider),
                  // Task list grouped by date
                  Expanded(child: _buildGroupedTaskList(tasks)),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            child: const Icon(Icons.add),
          ).animate().scale(delay: 300.ms, duration: 300.ms),
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

  Map<String, Map<String, List<Task>>> _groupTasksByMonthAndDate(
    List<Task> tasks,
  ) {
    final Map<String, Map<String, List<Task>>> grouped = {};

    for (var task in tasks) {
      final date = task.dueDate ?? DateTime.now();
      final monthKey = DateFormat(
        'MMMM yyyy',
      ).format(date); // e.g., "January 2026"
      final dateKey = DateFormat(
        'EEEE, MMM dd',
      ).format(date); // e.g., "Tuesday, Jan 21"

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = {};
      }

      if (!grouped[monthKey]!.containsKey(dateKey)) {
        grouped[monthKey]![dateKey] = [];
      }

      grouped[monthKey]![dateKey]!.add(task);
    }

    return grouped;
  }

  Widget _buildGroupedTaskList(List<Task> tasks) {
    final groupedTasks = _groupTasksByMonthAndDate(tasks);
    final colorScheme = Theme.of(context).colorScheme;

    if (groupedTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: groupedTasks.length,
      itemBuilder: (context, monthIndex) {
        final monthKey = groupedTasks.keys.elementAt(monthIndex);
        final datesInMonth = groupedTasks[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        monthKey,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${datesInMonth.values.fold(0, (sum, list) => sum + list.length)} tasks',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (monthIndex * 100).ms)
                .slideX(begin: -0.2, duration: 300.ms),

            // Dates and Tasks
            ...datesInMonth.entries.map((dateEntry) {
              final dateKey = dateEntry.key;
              final tasksForDate = dateEntry.value;
              final dateIndex = datesInMonth.keys.toList().indexOf(dateKey);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.today,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
                                color: colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${tasksForDate.length}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (dateIndex * 80).ms)
                      .slideX(begin: -0.1, duration: 250.ms),

                  // Tasks for this date
                  ...tasksForDate.asMap().entries.map((taskEntry) {
                    final taskIndex = taskEntry.key;
                    final task = taskEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildTaskItem(
                        context,
                        task,
                        context.read<TaskProvider>(),
                        taskIndex,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                ],
              );
            }),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildStatistics(TaskProvider taskProvider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            taskProvider.totalCount.toString(),
            Icons.task,
            Colors.blue,
            0,
          ),
          _buildStatItem(
            'Completed',
            taskProvider.completedCount.toString(),
            Icons.check_circle,
            Colors.green,
            1,
          ),
          _buildStatItem(
            'Pending',
            taskProvider.incompleteCount.toString(),
            Icons.pending_actions,
            Colors.orange,
            2,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, duration: 400.ms);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: color),
        ).animate().scale(delay: (100 * index).ms, duration: 300.ms),
        const SizedBox(height: 8),
        Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )
            .animate()
            .fadeIn(delay: (150 * index).ms)
            .scale(delay: (150 * index).ms),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ).animate().fadeIn(delay: (200 * index).ms),
      ],
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskColor = task.color != null
        ? Color(task.color!)
        : colorScheme.surfaceContainerHigh;
    final bool isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.completed;

    return Dismissible(
          key: Key(task.id),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Left swipe - delete
              return true;
            } else if (direction == DismissDirection.startToEnd) {
              // Right swipe - complete/incomplete toggle
              final wasCompleted = task.completed;

              if (!wasCompleted) {
                // Task will be marked complete, show confetti
                _confettiController.play();
              }

              taskProvider.toggleComplete(task.id);

              // Wait a moment for confetti
              if (!wasCompleted) {
                await Future.delayed(const Duration(milliseconds: 300));
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          wasCompleted ? Icons.refresh : Icons.celebration,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          wasCompleted
                              ? 'Task marked as incomplete'
                              : 'Task completed! 🎉',
                        ),
                      ],
                    ),
                    backgroundColor: wasCompleted ? Colors.blue : Colors.green,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: Colors.white,
                      onPressed: () {
                        taskProvider.toggleComplete(task.id);
                      },
                    ),
                  ),
                );
              }
              return false; // Don't remove from list
            }
            return false;
          },
          background: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text(
                  'Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              // Delete action
              taskProvider.deleteTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${task.title} deleted'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      taskProvider.addTask(task);
                    },
                  ),
                ),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: task.completed ? 1 : 3,
            color: task.completed
                ? Colors.green.withOpacity(0.1)
                : taskColor.withOpacity(0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: task.completed
                    ? Colors.lightGreen.shade300
                    : Colors.orange.shade300,
                width: task.completed ? 3 : 2,
              ),
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
                      color: task.completed
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: task.completed
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      task.completed ? 'Complete' : 'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: task.completed
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: task.completed ? 0.6 : 1.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: GestureDetector(
                      onTap: () async {
                        final wasCompleted = task.completed;

                        if (!wasCompleted) {
                          _confettiController.play();
                        }

                        taskProvider.toggleComplete(task.id);

                        // Wait a moment for confetti
                        if (!wasCompleted) {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: task.completed
                              ? Colors.green.withOpacity(0.3)
                              : taskColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            task.emoji ?? '\ud83d\udcdd',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                    title: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 500),
                      style: TextStyle(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: task.completed
                            ? Colors.green.shade700
                            : colorScheme.onSurface,
                        decorationColor: Colors.green,
                        decorationThickness: 2,
                      ),
                      child: Text(task.title),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (task.category != null)
                            Chip(
                              label: Text(task.category!),
                              avatar: const Icon(Icons.label, size: 14),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: taskColor.withOpacity(0.5),
                              labelStyle: const TextStyle(fontSize: 11),
                              padding: EdgeInsets.zero,
                            ),
                          if (task.dueDate != null)
                            Chip(
                              label: Text(_formatDate(task.dueDate!)),
                              avatar: Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isOverdue ? Colors.red : null,
                              ),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: isOverdue
                                  ? Colors.red.withOpacity(0.3)
                                  : taskColor.withOpacity(0.5),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: isOverdue ? Colors.red : null,
                                fontWeight: isOverdue ? FontWeight.bold : null,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          Chip(
                            label: Text(_getPriorityLabel(task.priority)),
                            avatar: Icon(
                              Icons.flag,
                              size: 14,
                              color: _getPriorityColor(task.priority),
                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: _getPriorityColor(
                              task.priority,
                            ).withOpacity(0.2),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.bold,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskScreen(task: task),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideX(begin: -0.1, duration: 300.ms, delay: (index * 50).ms);
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      case 1:
        return 'Low';
      default:
        return 'None';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
