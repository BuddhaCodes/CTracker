import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/pages/home_page.dart';
import 'package:ctracker/repository/reminder_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/notification_controller.dart';
import 'package:ctracker/utils/notification_manager.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/utils/work_keys.dart';
import 'package:ctracker/views/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == WorkKeys.sound) {
      ReminderRepositoryImplementation rm = ReminderRepositoryImplementation();
      Reminder reminder = await rm.getById(inputData?["key"] as String);
      reminder.status =
          Status(id: StatusEnum.done.id, name: StatusEnum.done.name);
      await rm.updateReminder(reminder.id ?? "", reminder);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          title: inputData?["title"],
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          autoDismissible: false,
        ),
      );
    } else if (task == WorkKeys.reschedule) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          title: inputData?["title"],
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          autoDismissible: false,
        ),
      );

      NotificationManager.scheduleNextNotification(inputData);
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  if (!kIsWeb) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelGroupKey: "basic_channel_group",
        channelKey: "basic_channel",
        channelName: "Basic Notification",
        channelDescription: "Basic notifications channel",
      )
    ], channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "basic_channel_group",
        channelGroupName: "Basic Group",
      )
    ]);
    bool isAllowedToSendNotification =
        await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowedToSendNotification) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
    super.initState();
  }

  Locale _locale = Locale('en', 'US');
  bool isAuth = false;
  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) Utils.checkNotificationPermission();
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        localizationsDelegates: const [
          MyLocalizationsDelegate(), // Add your custom delegate
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
        ],
        title: "CNote",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: ColorP.textColor,
          iconTheme: const IconThemeData(color: ColorP.textColor),
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: ColorP.textColor,
              displayColor: ColorP.textColor,
              fontFamily: 'Poppins'),
        ),
        home: isAuth
            ? HomePage(changeLanguage: _changeLanguage)
            : LoginPage(
                checkStatus: handle,
              ),
      ),
    );
  }

  void handle(bool isValid) {
    setState(() {
      isAuth = isValid;
    });
    // print(pb.authStore.isValid);
  }
}
