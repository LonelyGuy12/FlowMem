# FlowMem 🧠⚡

FlowMem is an intelligent, voice-first personal companion and dashboard. Built with a sleek, minimalist dark-mode aesthetic, FlowMem allows you to seamlessly track your daily life—from expenses and tasks to your health, mood, and personal journal.

## ✨ Key Features

- **🎙️ Voice-First Interaction**: Quickly dump your thoughts, tasks, and feelings using the built-in audio recorder.
- **✅ Intelligent Task Management**: View tasks grouped by priority with due times.
- **⏰ Aggressive Alarm Clock**: Never miss a deadline. FlowMem uses custom background Android channels to ring loud, insistent alarms that bypass silent mode.
- **💰 Expense Tracking**: Keep an eye on your daily spending with auto-calculated totals.
- **❤️ Health & Mood Logs**: Track how you're feeling with intelligent emoji mapping (😊 for good, 😔 for bad).
- **📓 Journaling**: Keep a running log of your thoughts with transcribed audio summaries.

## 🛠️ Tech Stack

- **Frontend**: Flutter & Dart (Android)
- **Backend**: Python (Hosted on Render)
- **Database**: Firebase Firestore
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Local Alarms**: `flutter_local_notifications` (with Android core library desugaring)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.19+)
- Android Studio / Android SDK (Java 17+)
- A valid `google-services.json` file in `android/app/` for Firebase integration.

### Running the App

1. Clone the repository:
```bash
git clone https://github.com/LonelyGuy12/FlowMem.git
```
2. Install Flutter dependencies:
```bash
flutter pub get
```
3. Run the app on an Android device or emulator:
```bash
flutter run
```

### Building for Production
To build the optimized production APK:
```bash
flutter build apk --release
```
The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
