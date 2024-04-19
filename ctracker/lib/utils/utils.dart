import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/repository/reminder_repository_implementation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static GestureDetector renderGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: ColorP.background,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_arrow_left, color: ColorP.white),
          ],
        ),
      ),
    );
  }

  static Widget buildListTile({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ValuesConst.tilePaddingHorizontal,
          vertical: ValuesConst.tilePaddingVertical),
      child: ListTile(
        selectedColor: ColorP.ColorC,
        title: Text(
          title,
          selectionColor: ColorP.ColorC,
        ),
        leading: SizedBox(
          height: ValuesConst.tileSeparatorSize,
          width: ValuesConst.tileSeparatorSize,
          child: Image.asset(icon),
        ),
        selected: selected,
        onTap: onTap,
      ),
    );
  }

  static Color lerpGradient(List<Color> colors, List<double> stops, double t) {
    if (colors.isEmpty) {
      throw ArgumentError('"colors" is empty.');
    } else if (colors.length == 1) {
      return colors[0];
    }

    if (stops.length != colors.length) {
      stops = [];

      colors.asMap().forEach((index, color) {
        final percent = 1.0 / (colors.length - 1);
        stops.add(percent * index);
      });
    }

    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s];
      final rightStop = stops[s + 1];
      final leftColor = colors[s];
      final rightColor = colors[s + 1];
      if (t <= leftStop) {
        return leftColor;
      } else if (t < rightStop) {
        final sectionT = (t - leftStop) / (rightStop - leftStop);
        return Color.lerp(leftColor, rightColor, sectionT)!;
      }
    }
    return colors.last;
  }

  static Color getColorFromIcon(String icon) {
    switch (icon) {
      case IconlyC.sad:
        return ColorP.sadColor;
      case IconlyC.crying:
        return ColorP.cryingColor;
      case IconlyC.coughing:
        return ColorP.coughingColor;
      case IconlyC.calm:
        return ColorP.calmColor;
      case IconlyC.happy:
        return ColorP.happyColor;
      case IconlyC.angry:
        return ColorP.angryColor;
      default:
        return ColorP.white;
    }
  }

  static bool isToday(DateTime dateToCheck) {
    DateTime today = DateTime.now();
    return dateToCheck.year == today.year &&
        dateToCheck.month == today.month &&
        dateToCheck.day == today.day;
  }

  static bool isInCurrentMonth(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year && date.month == today.month;
  }

  static DataCell buildCell(String item, [Color? color, bool bold = false]) {
    return DataCell(Container(
      padding: bold
          ? const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6)
          : null,
      decoration: bold
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: color ?? ColorP.textColor,
                width: 2.0,
              ),
            )
          : null,
      child: Text(item,
          style: TextStyle(
            color: color ?? ColorP.textColor,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 24 : 16,
          )),
    ));
  }

  static DataColumn buildColumn(String item, {Function(int, bool)? onSort}) {
    return DataColumn(
        label: Text(item,
            style: const TextStyle(
                color: ColorP.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        onSort: onSort);
  }

  static IconButton deleteIcon({Function()? onPressed}) {
    return IconButton(
      icon: const Icon(Icons.delete, color: ColorP.ColorD),
      onPressed: onPressed,
    );
  }

  static IconButton updateIcon({Function()? onPressed}) {
    return IconButton(
      icon: const Icon(Icons.edit, color: ColorP.ColorB),
      onPressed: onPressed,
    );
  }

  static List<NeatCleanCalendarEvent> getObjectsInRange(
      DateTime date, List<NeatCleanCalendarEvent> objects) {
    return objects.where((object) {
      return date.isAfter(object.startTime.subtract(const Duration(days: 1))) &&
          date.isBefore(object.endTime.add(const Duration(days: 1)));
    }).toList();
  }

  static IconButton checkNotes({Function()? onPressed}) {
    return IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.note_outlined,
          color: ColorP.buttonColor,
        ));
  }

  static IconButton detailsIcon({Function()? onPressed}) {
    return IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.visibility,
          color: ColorP.buttonColor,
        ));
  }

  static IconButton workIcon({Function()? onPressed}) {
    return IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.work_outline_outlined,
          color: ColorP.buttonColor,
        ));
  }

  static Future<int> getDueRemindersCount() async {
    ReminderRepositoryImplementation rd = ReminderRepositoryImplementation();
    DateTime present =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    List<Reminder> reminders = await rd.getAllRemindersOfDateToDate(present,
        toDate: present.add(const Duration(days: 1)));
    return reminders.length;
  }

  static Duration parseDuration(String durationString) {
    List<String> parts = durationString.split(":");

    List<String> secondsAndMilliseconds = parts[2].split(".");
    int seconds = int.parse(secondsAndMilliseconds[0]);
    int milliseconds = secondsAndMilliseconds.length > 1
        ? int.parse(secondsAndMilliseconds[1].padRight(3, '0'))
        : 0;

    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    Duration duration = Duration(
        hours: hours, minutes: minutes, seconds: seconds, milliseconds: 0);
    return duration;
  }

  static List<DropdownMenuItem<int>> buildYearDropdownItems() {
    List<DropdownMenuItem<int>> items = [];
    int currentYear = DateTime.now().year;
    for (int year = 2000; year <= currentYear + 10; year++) {
      items.add(
        DropdownMenuItem<int>(
          value: year,
          child: Text(
            year.toString(),
            style: const TextStyle(
              color: ColorP.textColor,
            ),
          ),
        ),
      );
    }
    return items;
  }

  static DateTime getLastDayOfMonth(DateTime anyDayInMonth) {
    int year = anyDayInMonth.year;
    int month = anyDayInMonth.month;

    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }

    DateTime firstDayOfNextMonth = DateTime(year, month, 1);

    DateTime lastDayOfMonth =
        firstDayOfNextMonth.subtract(const Duration(days: 1));

    return lastDayOfMonth;
  }

  static List<DateTime> getWeekRange(DateTime date) {
    int weekday = date.weekday;

    int daysSinceMonday = (weekday + 7 - DateTime.monday) % 7;

    DateTime startOfWeek = date.subtract(Duration(days: daysSinceMonday));

    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    return [startOfWeek, endOfWeek];
  }

  static Future<void> checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
