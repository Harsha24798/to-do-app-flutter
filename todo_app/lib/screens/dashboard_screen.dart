import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'home_screen.dart';
import 'completed_tasks_screen.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<Task> _getTodayTasks(TaskProvider taskProvider) {
    final today = DateTime.now();
    return taskProvider.allTasks.where((task) {
      if (task.completed) return false;
      if (task.dueDate == null) return false;

      return task.dueDate!.year == today.year &&
          task.dueDate!.month == today.month &&
          task.dueDate!.day == today.day;
    }).toList();
  }

  List<Task> _getUpcomingTasks(TaskProvider taskProvider) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final weekLater = today.add(const Duration(days: 7));

    return taskProvider.allTasks.where((task) {
      if (task.completed) return false;
      if (task.dueDate == null) return false;

      return task.dueDate!.isAfter(tomorrow) &&
          task.dueDate!.isBefore(weekLater);
    }).toList();
  }

  List<Task> _getOverdueTasks(TaskProvider taskProvider) {
    final today = DateTime.now();
    return taskProvider.allTasks.where((task) {
      if (task.completed) return false;
      if (task.dueDate == null) return false;

      return task.dueDate!.isBefore(today);
    }).toList();
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
                  child: const Icon(Icons.dashboard, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
            ],
          ),
          body: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final todayTasks = _getTodayTasks(taskProvider);
              final upcomingTasks = _getUpcomingTasks(taskProvider);
              final overdueTasks = _getOverdueTasks(taskProvider);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 20),

                    // Quick Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Tasks',
                            taskProvider.totalCount.toString(),
                            Icons.task_alt,
                            Colors.blue,
                            0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            taskProvider.completedCount.toString(),
                            Icons.check_circle,
                            Colors.green,
                            1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            taskProvider.incompleteCount.toString(),
                            Icons.pending_actions,
                            Colors.orange,
                            2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Overdue',
                            overdueTasks.length.toString(),
                            Icons.warning,
                            Colors.red,
                            3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'All Tasks',
                            Icons.list,
                            colorScheme.primary,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            'Completed',
                            Icons.check_circle_outline,
                            Colors.green,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CompletedTasksScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's Tasks Section
                    _buildTaskSection(
                      'Today\'s Tasks',
                      todayTasks,
                      Icons.today,
                      colorScheme.primary,
                      taskProvider,
                    ),

                    const SizedBox(height: 24),

                    // Overdue Tasks Section
                    if (overdueTasks.isNotEmpty) ...[
                      _buildTaskSection(
                        'Overdue Tasks',
                        overdueTasks,
                        Icons.warning_amber,
                        Colors.red,
                        taskProvider,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Upcoming Tasks Section
                    if (upcomingTasks.isNotEmpty) ...[
                      _buildTaskSection(
                        'Upcoming This Week',
                        upcomingTasks.take(5).toList(),
                        Icons.upcoming,
                        Colors.blue,
                        taskProvider,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 100).ms)
        .slideY(begin: 0.2, duration: 300.ms);
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildTaskSection(
    String title,
    List<Task> tasks,
    IconData icon,
    Color color,
    TaskProvider taskProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),

        if (tasks.isEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tasks for this section',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms)
        else
          ...tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return _buildTaskCard(task, taskProvider, index);
          }),
      ],
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider taskProvider, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskColor = task.color != null
        ? Color(task.color!)
        : colorScheme.surfaceContainerHigh;
    final bool isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.completed;

    return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: taskColor.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: task.completed
                  ? Colors.lightGreen.shade300
                  : Colors.orange.shade300,
              width: 2,
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
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: GestureDetector(
                  onTap: () async {
                    if (!task.completed) {
                      _confettiController.play();
                      await Future.delayed(const Duration(milliseconds: 500));
                    }
                    taskProvider.toggleComplete(task.id);

                    // Show snackbar
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                task.completed
                                    ? Icons.refresh
                                    : Icons.celebration,
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
                          backgroundColor: task.completed
                              ? Colors.blue
                              : Colors.green,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                        task.emoji ?? '📝',
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
                        : Theme.of(context).colorScheme.onSurface,
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
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    Navigator.push(
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
        )
        .animate()
        .fadeIn(delay: (index * 50).ms, duration: 300.ms)
        .slideX(begin: -0.1, duration: 300.ms);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('MMM dd, HH:mm').format(date);
    }
  }
}
