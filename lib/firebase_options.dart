import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'ВСТАВЬ_API_KEY', // 
      appId: 'ВСТАВЬ_APP_ID',
      messagingSenderId: 'ВСТАВЬ_SENDER_ID',
      projectId: 'workoutlog-62209',
    );
  }
}