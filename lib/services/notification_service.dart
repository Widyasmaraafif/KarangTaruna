import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:karang_taruna/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _setupLocalNotifications();
    await _requestPermission();
    await _configureMessaging();
    await _syncFcmTokenWithProfile();
    await subscribeToDefaultTopics();
    await _updateAdminTopicSubscription();

    _initialized = true;
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _flutterLocalNotificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  Future<void> _configureMessaging() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = notification?.android;

      if (notification != null && android != null) {
        _showLocalNotification(notification);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'General',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }

  Future<void> _syncFcmTokenWithProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await SupabaseService().updateFcmToken(token);
  }

  Future<void> _updateAdminTopicSubscription() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await SupabaseService().getCurrentUserProfile();
    final role = (profile?['role'] as String?) ?? '';

    const adminRoles = [
      'Admin',
      'Ketua',
      'Wakil Ketua',
      'Sekretaris',
      'Bendahara',
      'Pubdekdok',
    ];

    if (adminRoles.contains(role)) {
      await FirebaseMessaging.instance.subscribeToTopic('admin');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('admin');
    }
  }

  Future<void> refreshFcmTokenForCurrentUser() async {
    await _syncFcmTokenWithProfile();
  }

  Future<void> subscribeToDefaultTopics() async {
    await FirebaseMessaging.instance.subscribeToTopic('news');
    await FirebaseMessaging.instance.subscribeToTopic('announcements');
    await FirebaseMessaging.instance.subscribeToTopic('events');
    await FirebaseMessaging.instance.subscribeToTopic('gallery');
    await FirebaseMessaging.instance.subscribeToTopic('pollings');
    await FirebaseMessaging.instance.subscribeToTopic('aspirations');
    await FirebaseMessaging.instance.subscribeToTopic('bills');
  }
}
