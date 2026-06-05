# Task Management App

A simple Flutter mobile app for managing daily tasks. Users sign in with email validation, view their task list on a home screen, and manage tasks with add, complete, and delete actions. All tasks are stored locally on the device and remain available after the app is closed and reopened.

Built as a Flutter Development Internship project by **Muhammad Fahad**.

## About the App

This app follows a straightforward flow:

1. **Splash screen** — Shows the app branding for 2 seconds while saved tasks load in the background.
2. **Login screen** — User enters email and password. The form validates input before allowing access.
3. **Home screen** — User sees their task list, can add new tasks, mark tasks complete, and delete tasks.

Login is used for UI practice only. There is no real backend authentication — any valid email format and non-empty password will work (for example, `user@example.com`).

Task data is saved on the device using **SharedPreferences**, so no internet connection or cloud account is required.

## Features

- Splash screen on app launch
- Login form with email format and password validation
- Screen navigation using Flutter `Navigator`
- Task list with add, complete, and delete actions
- Swipe-to-delete and delete confirmation dialog
- Local data persistence with SharedPreferences
- Material Design 3 UI with icons and responsive layout

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| SharedPreferences | Local storage for tasks |
| Material 3 | App theme and components |

## Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or newer
- Dart SDK (included with Flutter)
- Android Studio or VS Code with the Flutter extension
- An Android emulator, iOS simulator, or physical device

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/Fahad-2005/task_management_app.git
   cd task_management_app
   ```

2. Install project dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:

   ```bash
   flutter run
   ```

### Running Tests

```bash
flutter test
flutter analyze
```

## How to Use

| Screen | What you can do |
|--------|-----------------|
| Splash | Wait briefly while the app loads |
| Login | Enter a valid email and password, then tap **Login** |
| Home | Tap **+** to add a task, tap the circle to mark complete, tap delete or swipe left to remove |

After adding tasks, fully close the app and open it again. Log in once more — your tasks should still appear on the home screen.

## Project Structure

```text
lib/
├── main.dart                 # App entry point and theme
├── models/
│   └── task.dart             # Task model (title, completed status)
├── screens/
│   ├── splash_screen.dart    # Launch screen
│   ├── login_screen.dart     # Login form and validation
│   └── home_screen.dart      # Task list and management
└── services/
    └── task_storage.dart     # Save and load tasks from SharedPreferences
```

## How Data Is Stored

Each task is saved as a string in SharedPreferences using this format:

```text
0|Buy groceries    → pending task
1|Finish homework  → completed task
```

The first character (`0` or `1`) represents completion status. The task title comes after the `|` separator.

## App Flow

```text
Splash Screen  →  Login Screen  →  Home Screen
     (2s)           (validate)        (tasks)
```

## Dependencies

- [shared_preferences](https://pub.dev/packages/shared_preferences) — persists task data locally on the device

## Author

**Muhammad Fahad**  
Flutter Development Internship Project

## License

This project was created for educational purposes as part of a Flutter internship assignment.
