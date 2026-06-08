/// ONYX Notification Service — FCM Push Notifications.
///
/// Handles permission requests, token management, foreground/background
/// message routing, and notification display.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Top-level handler for background messages (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // ── Initialization ──────────────────────────────────────────────

  /// Call once at app startup after Firebase.initializeApp().
  Future<void> initialize() async {
    // Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      criticalAlert: false,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupToken();
      _listenForTokenRefresh();
      _setupForegroundHandler();
    }
  }

  // ── Token Management ────────────────────────────────────────────

  Future<void> _setupToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('[FCM] Token: $_fcmToken');

      if (_fcmToken != null) {
        await _saveTokenToFirestore(_fcmToken!);
      }
    } catch (e) {
      debugPrint('[FCM] Token error: $e');
    }
  }

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _saveTokenToFirestore(newToken);
      debugPrint('[FCM] Token refreshed');
    });
  }

  /// Persist FCM token to user's Firestore document for server-side targeting.
  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    });
  }

  /// Remove FCM token on logout to stop receiving push notifications.
  Future<void> removeToken() async {
    final user = _auth.currentUser;
    if (user == null || _fcmToken == null) return;

    await _db.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayRemove([_fcmToken!]),
    });
  }

  // ── Foreground Message Handler ──────────────────────────────────

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Opened from background: ${message.data}');
      _handleNotificationTap(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    // The notification is automatically shown by the system.
    // Store it in Firestore for the in-app notification feed.
    final user = _auth.currentUser;
    if (user == null) return;

    final data = message.data;
    final notification = message.notification;

    if (notification != null) {
      _db.collection('notifications').add({
        'userId': user.uid,
        'type': data['type'] ?? 'general',
        'title': notification.title ?? '',
        'body': notification.body ?? '',
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Route to the appropriate screen based on notification type.
    // The app's navigation context should handle this.
    final type = message.data['type'];
    final targetId = message.data['targetId'];
    debugPrint('[FCM] Navigate: type=$type, targetId=$targetId');
  }

  // ── Topic Subscriptions ─────────────────────────────────────────

  /// Subscribe to a topic for broadcast notifications.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a notification topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }

  /// Subscribe to default topics based on user role.
  Future<void> subscribeToRoleTopics(String role) async {
    // Everyone gets general announcements
    await subscribeToTopic('all_users');

    switch (role) {
      case 'guest':
        await subscribeToTopic('guests');
        await subscribeToTopic('promotions');
        break;
      case 'coachingMember':
        await subscribeToTopic('coaching_members');
        await subscribeToTopic('promotions');
        break;
      case 'coach':
        await subscribeToTopic('coaches');
        await subscribeToTopic('staff');
        break;
      case 'receptionist':
      case 'facilityManager':
        await subscribeToTopic('staff');
        await subscribeToTopic('front_desk');
        break;
      case 'admin':
        await subscribeToTopic('staff');
        await subscribeToTopic('admins');
        break;
      case 'housekeeping':
        await subscribeToTopic('staff');
        await subscribeToTopic('housekeeping');
        break;
    }
  }

  // ── Check for initial notification (cold start) ─────────────────

  /// Check if the app was opened from a terminated state via notification.
  Future<void> checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('[FCM] App opened from terminated state');
      _handleNotificationTap(message);
    }
  }
}
