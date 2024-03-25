import 'package:calendar_view/calendar_view.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/notification_service.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
        ],
        title: "CNote",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: ColorP.textColor,
          iconTheme: IconThemeData(color: ColorP.textColor),
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: ColorP.textColor,
              displayColor: ColorP.textColor,
              fontFamily: 'Poppins'),
        ),
        home: const HomePage(),
      ),
    );
  }
}
