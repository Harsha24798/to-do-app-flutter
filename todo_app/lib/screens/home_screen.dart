import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.check_circle),
                  tooltip: 'Completed Tasks',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompletedTasksScreen(),
                      ),
                    );
                  },
                ),
              ),
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
                  // Task list
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskItem(
                          context,
                          task,
                          taskProvider,
                          index,
                        );
                      },
                    ),
                  ),
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
              // Right swipe - complete
              if (!task.completed) {
                // Task was just marked complete, show confetti
                _confettiController.play();

                // Wait for confetti animation
                await Future.delayed(const Duration(milliseconds: 500));
              }

              taskProvider.toggleComplete(task.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        task.completed ? Icons.refresh : Icons.celebration,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.completed
                            ? 'Task marked as incomplete'
                            : 'Task completed! 🎉',
                      ),
                    ],
                  ),
                  backgroundColor: task.completed ? Colors.blue : Colors.green,
                  duration: const Duration(seconds: 2),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            transform: task.completed
                ? (Matrix4.identity()
                    ..scale(0.95)
                    ..rotateZ(-0.02))
                : Matrix4.identity(),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: task.completed ? 1 : 3,
              color: task.completed
                  ? Colors.green.withOpacity(0.1)
                  : taskColor.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: task.completed
                      ? Colors.green.withOpacity(0.5)
                      : taskColor.withOpacity(0.6),
                  width: task.completed ? 3 : 2,
                ),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: task.completed ? 0.6 : 1.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: task.completed
                          ? Colors.green.withOpacity(0.3)
                          : taskColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Checkbox(
                      value: task.completed,
                      onChanged: (value) async {
                        if (value == true) {
                          _confettiController.play();
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        }
                        taskProvider.toggleComplete(task.id);
                      },
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.green;
                        }
                        return null;
                      }),
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
                            backgroundColor: taskColor.withOpacity(0.3),
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
                                ? Colors.red.withOpacity(0.2)
                                : taskColor.withOpacity(0.3),
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
