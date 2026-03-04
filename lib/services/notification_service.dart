import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:wealthwise/core/app_theme.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // default icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: AppTheme.primaryNavy,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'transaction_channel',
          channelName: 'Transactions',
          channelDescription: 'Notifications for income and expenses',
          defaultColor: AppTheme.accentEmerald,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'goal_channel',
          channelName: 'Goals',
          channelDescription: 'Notifications for goal progress',
          defaultColor: AppTheme.accentGold,
          importance: NotificationImportance.High,
        ),
      ],
      debug: true,
    );
  }

  static Future<void> showTransactionNotification({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'transaction_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        backgroundColor: AppTheme.accentEmerald,
      ),
    );
  }

  static Future<void> showGoalNotification({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'goal_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
        backgroundColor: AppTheme.accentGold,
      ),
    );
  }
}
