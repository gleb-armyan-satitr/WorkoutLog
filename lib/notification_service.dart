import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _listenersAttached = false;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  void Function(String title, String body)? _onForegroundMessage;

  Future<void> initialize({
    void Function(String title, String body)? onForegroundMessage,
  }) async {
    _onForegroundMessage = onForegroundMessage;

    await _requestPermission();
    await _saveCurrentToken();
    await _messaging.subscribeToTopic('workoutlog_updates');

    if (_listenersAttached) {
      return;
    }

    _listenersAttached = true;

    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'WorkoutLog';
      final body = message.notification?.body ?? 'Новое уведомление';

      _onForegroundMessage?.call(title, body);
    });

    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final title = message.notification?.title ?? 'WorkoutLog';
      final body = message.notification?.body ?? 'Уведомление открыто';

      _onForegroundMessage?.call(title, body);
    });

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  Future<void> _saveCurrentToken() async {
    final token = await _messaging.getToken();
    await _saveToken(token);
  }

  Future<void> _saveToken(String? token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || token == null) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'fcmToken': token,
        'notificationsEnabled': true,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();

    _foregroundSubscription = null;
    _openedSubscription = null;
    _tokenRefreshSubscription = null;
    _listenersAttached = false;
  }
}