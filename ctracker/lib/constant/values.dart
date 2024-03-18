import 'package:shared_preferences/shared_preferences.dart';

class ValuesConst {
  static const double borderRadius = 10.0;
  static const double boxSeparatorSize = 20.0;

  static const double tileSeparatorSize = 30.0;
  static const double tilePaddingHorizontal = 16.0;
  static const double tilePaddingVertical = 8.0;

  static const double tableRadius = 20;
  static const double tableBorderWidth = 1;
  static const double tablePadding = 16;
  static const double tableWidth = 0.85;

  static int workingMinutes = 25;
  static int shortRestMinutes = 5;
  static int longRestMinutes = 10;
  static int second = 1;

  static double pomodoroButtonPaddingH = 44;
  static double pomodoroButtonPaddingV = 26;

  static double timerFontSize = 140;
  static double buttonFontSize = 24;
  static double buttonBorderRadius = 20;

  static double noteBoardContainer = 400;

  static Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    workingMinutes = prefs.getInt('workingMinutes') ?? 25;
    shortRestMinutes = prefs.getInt('shortRestMinutes') ?? 5;
    longRestMinutes = prefs.getInt('longRestMinutes') ?? 15;
    second = prefs.getInt('second') ?? 1;
  }

  static Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workingMinutes', workingMinutes);
    await prefs.setInt('shortRestMinutes', shortRestMinutes);
    await prefs.setInt('longRestMinutes', longRestMinutes);
    await prefs.setInt('second', second);
  }
}
