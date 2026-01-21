import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HiveService _hiveService = HiveService();
  
  late bool _notificationsEnabled;
  late bool _darkMode;
  late int _defaultReminderMinutes;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _notificationsEnabled = _hiveService.getSetting('notifications_enabled', defaultValue: true);
    _darkMode = _hiveService.getSetting('dark_mode', defaultValue: false);
    _defaultReminderMinutes = _hiveService.getSetting('default_reminder_minutes', defaultValue: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Dark mode toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkMode,
            secondary: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                _hiveService.saveSetting('dark_mode', value);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restart app to apply theme changes'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Notifications toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders for tasks'),
            value: _notificationsEnabled,
            secondary: const Icon(Icons.notifications),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                _hiveService.saveSetting('notifications_enabled', value);
              });
            },
          ),

          // Default reminder time
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Default Reminder Time'),
            subtitle: Text('$_defaultReminderMinutes minutes before due date'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderTimePicker(),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Show completed tasks toggle
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return SwitchListTile(
                title: const Text('Show Completed Tasks'),
                subtitle: const Text('Display completed tasks in the list'),
                value: taskProvider.showCompleted,
                secondary: const Icon(Icons.check_circle_outline),
                onChanged: (value) {
                  taskProvider.toggleShowCompleted();
                },
              );
            },
          ),

          // Delete all tasks
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text(
              'Delete All Tasks',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Remove all tasks from the app'),
            onTap: () => _showDeleteAllConfirmation(),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Statistics
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return Column(
                children: [
                  _buildStatTile(
                    'Total Tasks',
                    taskProvider.totalCount.toString(),
                    Icons.task,
                  ),
                  _buildStatTile(
                    'Completed Tasks',
                    taskProvider.completedCount.toString(),
                    Icons.check_circle,
                  ),
                  _buildStatTile(
                    'Pending Tasks',
                    taskProvider.incompleteCount.toString(),
                    Icons.pending,
                  ),
                  _buildStatTile(
                    'Overdue Tasks',
                    taskProvider.overdueTasks.length.toString(),
                    Icons.warning,
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // About section
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('To-Do App v1.0.0\nBuilt with Flutter'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showReminderTimePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('5 minutes'),
              value: 5,
              groupValue: _defaultReminderMinutes,
              onChanged: (value) {
                setState(() {
                  _defaultReminderMinutes = value!;
                  _hiveService.saveSetting('default_reminder_minutes', value);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('15 minutes'),
              value: 15,
              groupValue: _defaultReminderMinutes,
              onChanged: (value) {
                setState(() {
                  _defaultReminderMinutes = value!;
                  _hiveService.saveSetting('default_reminder_minutes', value);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('30 minutes'),
              value: 30,
              groupValue: _defaultReminderMinutes,
              onChanged: (value) {
                setState(() {
                  _defaultReminderMinutes = value!;
                  _hiveService.saveSetting('default_reminder_minutes', value);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('1 hour'),
              value: 60,
              groupValue: _defaultReminderMinutes,
              onChanged: (value) {
                setState(() {
                  _defaultReminderMinutes = value!;
                  _hiveService.saveSetting('default_reminder_minutes', value);
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('1 day'),
              value: 1440,
              groupValue: _defaultReminderMinutes,
              onChanged: (value) {
                setState(() {
                  _defaultReminderMinutes = value!;
                  _hiveService.saveSetting('default_reminder_minutes', value);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Tasks'),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteAllTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All tasks deleted')),
              );
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
