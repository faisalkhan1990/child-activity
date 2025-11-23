# Child Activity Application

A Flutter application for tracking child activities where parents can login and manage their children's profiles.

## Features

- **Splash Screen**: Animated splash screen with app branding
- **Parent Authentication**: Secure login and signup for parents
- **Bottom Navigation**: Easy access to all app sections
- **Animated Hero Headers**: Beautiful gradient headers with smooth animations on every page
  - Fade in/out animations
  - Scale transformations
  - Slide transitions
  - Color-coded per section
- **Children Tab**: View and manage all children in one place
  - **Drag & Drop Reordering**: Long press and drag to reorder children
  - **Swipe to Delete**: Swipe left to remove a child with confirmation
  - **Animated Transitions**: Smooth animations for all interactions
- **Reports Tab**: Track activities and view statistics
- **Tasks Tab**: Daily activity tasks for children
  - **Study Time**: Complete homework and study sessions
  - **Exercise**: Physical activities and sports
  - **Vocabulary**: Learn new words daily
  - **New Learning**: Discover something new every day
  - **Reading**: Daily reading practice
  - **Homework**: School assignments
  - **Creative Activity**: Art, music, and crafts
  - **Life Skills**: Practical daily skills
- **Settings Tab**: Profile management and app preferences
- **Child Management**: Add and manage child profiles with interactive gestures
- **Modern UI**: Clean Material Design interface with gradient effects

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

### Project Structure

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── parent.dart
│   └── child.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── dashboard_screen.dart (with bottom navigation)
│   ├── add_child_screen.dart
│   ├── reports_screen.dart
│   ├── tasks_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   └── auth_service.dart
└── widgets/                  # Reusable components
    ├── animated_hero_header.dart
    └── custom_text_field.dart
```

## Usage

1. Launch the app (splash screen displays)
2. Sign up as a new parent or login with existing credentials
3. Navigate using the bottom navigation bar:
   - **Children Tab**: Add, view, and manage your children
     - Long press and drag to reorder children
     - Swipe left to delete (with confirmation)
   - **Reports Tab**: View activity statistics and reports
   - **Tasks Tab**: Assign daily tasks to children (study, exercise, vocabulary, etc.)
   - **Settings Tab**: Manage profile and app preferences

## Development

This project uses Provider for state management and follows Flutter best practices.

To run the app in debug mode:
```bash
flutter run
```

To build for release:
```bash
flutter build apk  # For Android
flutter build ios  # For iOS
```

## License

This project is licensed under the MIT License.
