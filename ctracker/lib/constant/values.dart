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

  static const String baseEntry = '''
[
  {
    "insert":"Today's Message To Myself:",
    "attributes":{"color":"#FF2196F3"}
  },
  {
    "insert":"\\n",
    "attributes":{
      "header":1
    }
  },
  {
    "insert":"\\n"
  },
  {
    "insert":"...",
    "attributes":{
      "color":"#FF2196F3"
    }
  },
  {
    "insert":"\\n\\n\\n"
  },
  {
    "insert":"Today's top 3 goals/priorities:",
    "attributes":{
      "color":"#FF00C853"
    }
  },
  {
    "insert":"\\n",
    "attributes":{
      "header":1
    }
  },
  {
    "insert":"...",
    "attributes":{
      "color":"#FF00C853"
      }
    },
  {
    "insert":"\\n",
    "attributes":{
      "list":"ordered"
      }
    },
  {
    "insert":"...",
    "attributes":{
      "color":"#FF00C853"
      }
    },
  {
    "insert":"\\n",
    "attributes":{
      "list":"ordered"
      }
    },
  {
    "insert":"...",
    "attributes":{
      "color":"#FF00C853"
      }
    },
  {
    "insert":"\\n",
    "attributes":{
      "list":"ordered"
      }
    },
  {
    "insert":"\\n"
  },
  {
    "insert":"Tasks that absolutely must be done today",
    "attributes":{
      "color":"#FFF57F17"
      }
    },
  {
    "insert":"\\n",
    "attributes":{
      "header":1
      }
    },
  {
    "insert":"\\n"},
  {
    "insert":"?",
    "attributes":{
      "color":"#FFF57F17"
      }
    },
  {
    "insert":"\\n",
    "attributes":{
      "list":"unchecked"
      }
    },
  {
    "insert":"\\n"},
  {
    "insert":"Person(s) need to lead or connect with today (and how to do it well)",
    "attributes":{
      "color":"#FFD50000"
      }
    },
  {
    "insert":":",
    "attributes":{
      "color":"#FF880E4F"
      }
    },
  {
    "insert":"\\n",
    "attributes":{
      "header":1
      }
    },
  {
    "insert":"\\n"},
  {
    "insert":"?","attributes":{
      "color":"#FFD50000"
    }
  },
  {
    "insert":"\\n",
    "attributes":{
      "list":"bullet"
    }
  }
]
''';

  static int workingMinutes = 25;
  static int shortRestMinutes = 5;
  static int longRestMinutes = 10;
  static int second = 1;

  static double pomodoroButtonPaddingH = 42;
  static double pomodoroButtonPaddingV = 24;

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
