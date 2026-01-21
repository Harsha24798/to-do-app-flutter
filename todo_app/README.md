# Flutter To-Do App

A fully-featured To-Do application built with Flutter, featuring local storage, notifications, and a modern Material Design 3 UI.

## Features

✅ **Task Management**

- Create, read, update, and delete tasks
- Mark tasks as complete/incomplete
- Swipe to delete with undo option
- Tap to edit tasks

✅ **Task Organization**

- Categorize tasks (Work, Personal, Shopping, etc.)
- Set priority levels (Low, Medium, High)
- Assign custom colors to tasks
- Filter tasks by category
- Sort by priority or due date
- Toggle visibility of completed tasks

✅ **Reminders & Notifications**

- Set due dates with time
- Schedule reminder notifications
- Local notifications support
- Notification permissions handling

✅ **Settings & Preferences**

- Light/Dark theme support
- Enable/disable notifications
- Configure default reminder time
- View task statistics
- Clear all tasks

✅ **Data Persistence**

- Local storage using Hive
- Fast and efficient data access
- Settings persistence

## Technology Stack

- **Flutter SDK**: Cross-platform UI framework
- **Provider**: State management
- **Hive**: Fast, lightweight local database
- **Flutter Local Notifications**: Push notifications
- **Material Design 3**: Modern UI components

## Project Structure

```
lib/
├── models/
│   └── task.dart               # Task data model with Hive adapter
├── services/
│   ├── hive_service.dart       # Local storage service
│   └── notification_service.dart # Notification management
├── providers/
│   └── task_provider.dart      # State management
├── screens/
│   ├── home_screen.dart        # Main task list screen
│   ├── add_task_screen.dart    # Add/Edit task screen
│   └── settings_screen.dart    # Settings screen
└── main.dart                   # App entry point
```

## Installation & Setup

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK
- For Windows: **Developer Mode must be enabled**

### Steps to Run

1. **Get dependencies**

   ```bash
   flutter pub get
   ```

2. **For Windows users: Enable Developer Mode (REQUIRED)**
   - Run: `start ms-settings:developers`
   - Toggle "Developer Mode" to ON
   - This is required for symlink support with plugins

3. **Check available devices**

   ```bash
   flutter devices
   ```

4. **Run the app**

   ```bash
   # For Windows
   flutter run -d windows

   # For Web
   flutter run -d chrome

   # For Android (requires device/emulator)
   flutter run -d android
   ```

## Usage Guide

### Creating a Task

1. Tap the **+** button on the home screen
2. Enter task title (required)
3. Optionally add:
   - Category
   - Priority level (Low/Medium/High)
   - Due date and time
   - Reminder time
   - Task color
4. Tap **Add Task**

### Managing Tasks

- **Complete**: Tap the checkbox
- **Edit**: Tap on the task card
- **Delete**: Swipe left on the task
- **Undo Delete**: Tap "Undo" in the snackbar

### Organizing Tasks

- **Filter by Category**: Tap the filter icon (top right)
- **Sort Tasks**: Tap the sort icon and choose:
  - Default order
  - By Priority
  - By Due Date

### Settings

Access settings via the settings icon:

- Toggle dark mode (requires app restart)
- Enable/disable notifications
- Set default reminder time (5min to 1 day)
- View statistics (total, completed, pending, overdue)
- Delete all tasks

## Testing Checklist

Per [.agent/10_final_check.md](.agent/10_final_check.md):

✅ Tasks save locally (Hive storage)
✅ Notifications work (scheduled reminders)
✅ Settings save (theme, notification preferences)
✅ UI smooth (Material Design 3, responsive)

## Troubleshooting

**Issue**: "Building with plugins requires symlink support"

- **Solution**: Enable Developer Mode on Windows (`start ms-settings:developers`)

**Issue**: Notifications not appearing

- **Solution**: Check notification permissions in device settings

**Issue**: Tasks not saving

- **Solution**: Ensure Hive is initialized properly in main.dart

**Issue**: Build errors

- **Solution**: Run `flutter clean` then `flutter pub get`

## Dependencies

All dependencies are managed in `pubspec.yaml`:

- hive & hive_flutter (local storage)
- provider (state management)
- flutter_local_notifications (reminders)
- path_provider (file paths)
- timezone (notification scheduling)

## Version

**v1.0.0** (2026-01-21)

- Initial release with full CRUD functionality
- Local notifications and reminders
- Settings management with theme support
- Task filtering and sorting

---

**Built with Flutter**
