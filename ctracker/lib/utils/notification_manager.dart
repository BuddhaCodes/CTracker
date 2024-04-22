import 'package:ctracker/models/enums/repeat_type_enum.dart';
import 'package:ctracker/utils/work_keys.dart';
import 'package:workmanager/workmanager.dart';

class NotificationManager {
  static void scheduleNextNotification(Map<String, dynamic>? inputData) {
    if (inputData == null) return;

    DateTime date = DateTime.parse(inputData["date"] as String);
    Duration delayDuration = _getDelayDuration(inputData);

    String key = inputData["key"];

    if (DateTime.now().add(delayDuration).isBefore(date)) {
      String taskKey =
          delayDuration == Duration.zero ? WorkKeys.sound : WorkKeys.reschedule;
      Workmanager().registerOneOffTask(
        key,
        taskKey,
        initialDelay: delayDuration,
        inputData: inputData,
      );
    } else if (DateTime.now().isBefore(date)) {
      Workmanager().registerOneOffTask(
        key,
        WorkKeys.sound,
        initialDelay: DateTime.now().difference(date),
        inputData: inputData,
      );
    }
  }

  static Duration _getDelayDuration(Map<String, dynamic> inputData) {
    RepeatTypeEnum repeatType = RepeatTypeEnum.values.firstWhere(
        (element) => element.id == inputData["rt"],
        orElse: () => RepeatTypeEnum.never);

    switch (repeatType) {
      case RepeatTypeEnum.hourly:
        return const Duration(hours: 1);
      case RepeatTypeEnum.daily:
        return const Duration(days: 1);
      case RepeatTypeEnum.weekly:
        return const Duration(days: 7);
      case RepeatTypeEnum.monthly:
        return _calculateMonthDuration(
            DateTime.parse(inputData["date"] as String));
      case RepeatTypeEnum.never:
        return Duration.zero;
    }
  }

  static Duration _calculateMonthDuration(DateTime date) {
    int nextMonth = date.month + 1;
    int nextYear = date.year + (nextMonth > 12 ? 1 : 0);
    int nextDay = date.day;
    if (nextMonth == 2 && nextDay > 28) {
      nextDay = 28;
    } else if ([4, 6, 9, 11].contains(nextMonth) && nextDay > 30) {
      nextDay = 30;
    }
    return DateTime(nextYear, nextMonth % 12, nextDay, date.hour, date.minute,
            date.second, date.millisecond, date.microsecond)
        .difference(date);
  }
}
