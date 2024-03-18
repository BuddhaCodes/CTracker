import 'package:calendar_view/calendar_view.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/utils/local_notification_service.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ReminderService.initNotifications();
    if (!kIsWeb) Utils.checkNotificationPermission();
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        localizationsDelegates: const [
          MyLocalizationsDelegate(), // Add your custom delegate
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
        ],
        title: "CNote",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: ColorConst.textColor,
              displayColor: ColorConst.textColor,
              fontFamily: 'Poppins'),
        ),
        home: const HomePage(),
      ),
    );
  }
}
