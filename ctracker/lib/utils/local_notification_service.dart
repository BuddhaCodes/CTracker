import 'package:ctracker/models/reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleNotification(Reminder reminder) async {
    // Calculate the time for the notification (one day before due date)
    final dueDate = reminder.duedate;
    final notificationTime =
        tz.TZDateTime.from(dueDate, tz.local).subtract(const Duration(days: 1));

    // Define the notification details
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Reminder', // channel id
      '${reminder.duedate}', // channel name
      channelDescription: reminder.description, // channel description
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: null);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id,
      'Reminder: ${reminder.title}',
      'Your task "${reminder.description}" is due tomorrow!',
      notificationTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'payload',
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }
}
