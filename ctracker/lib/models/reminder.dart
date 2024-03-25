import 'package:ctracker/models/reminder_categories.dart';
import 'package:ctracker/models/repeat_types.dart';
import 'package:ctracker/utils/notification_service.dart';
import 'package:intl/intl.dart';

class Reminder {
  final int id;
  final String title;
  final DateTime duedate;
  final String description;
  String? note;
  final ReminderCategory categories;
  final List<String> images;

  Reminder({
    required this.id,
    required this.title,
    required this.duedate,
    required this.description,
    this.note,
    required this.categories,
    required this.images,
  });
}

class ReminderData {
  static final List<Reminder> _data = [
    Reminder(
      id: 1,
      title: 'Reminder A',
      duedate: DateTime.now().add(const Duration(days: 60)),
      description:
          'Tincidunt dolor no nostrud et. Dolore et ut elitr amet nonumy et esse nonumy dolore no rebum erat ipsum duo aliquip accumsan. Facilisis dolor sit amet sit clita amet et vulputate. Quis molestie wisi dolore velit accusam rebum invidunt sed takimata takimata lorem sea erat nulla elitr eirmod sadipscing.',
      note: 'Notes for Task 1',
      categories: ReminderCategoryData.getById(1),
      images: ['Image A'],
    ),
    Reminder(
      id: 2,
      title: 'Reminder B',
      duedate: DateTime.now(),
      description:
          'Tincidunt dolor no nostrud et. Dolore et ut elitr amet nonumy et esse nonumy dolore no rebum erat ipsum duo aliquip accumsan. Facilisis dolor sit amet sit clita amet et vulputate. Quis molestie wisi dolore velit accusam rebum invidunt sed takimata takimata lorem sea erat nulla elitr eirmod sadipscing.',
      note: 'Notes for Task 1',
      categories: ReminderCategoryData.getById(2),
      images: ['Image A'],
    ),
    Reminder(
      id: 3,
      title: 'Reminder C',
      duedate: DateTime.now().add(const Duration(days: 1)),
      description:
          'Tincidunt dolor no nostrud et. Dolore et ut elitr amet nonumy et esse nonumy dolore no rebum erat ipsum duo aliquip accumsan. Facilisis dolor sit amet sit clita amet et vulputate. Quis molestie wisi dolore velit accusam rebum invidunt sed takimata takimata lorem sea erat nulla elitr eirmod sadipscing.',
      note: 'Notes for Task 3',
      categories: ReminderCategoryData.getById(3),
      images: ['Image A'],
    ),
  ];

  static List<Reminder> getCompletedRemindersThisMonth() {
    DateTime now = DateTime.now();
    return _data.where((reminder) {
      return reminder.duedate.month == now.month &&
          reminder.duedate.year == now.year &&
          reminder.isCompleted();
    }).toList();
  }

  static List<Reminder> getRemainingRemindersThisMonth() {
    DateTime now = DateTime.now();
    return _data.where((reminder) {
      return reminder.duedate.month == now.month &&
          reminder.duedate.year == now.year &&
          !reminder.isCompleted();
    }).toList();
  }

  static List<Reminder> getAllOfWeek() {
    DateTime now = DateTime.now();
    DateTime startOfWeek =
        DateTime(now.year, now.month, now.day - now.weekday + 1);
    DateTime endOfWeek =
        DateTime(now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59);
    return _data
        .where((reminder) =>
            reminder.duedate.isAfter(startOfWeek) &&
            reminder.duedate.isBefore(endOfWeek))
        .toList();
  }

  static List<Reminder> getAllOfMonth() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _data
        .where((reminder) =>
            reminder.duedate.isAfter(startOfMonth) &&
            reminder.duedate.isBefore(endOfMonth))
        .toList();
  }

  static List<Reminder> allNeareast() {
    DateTime now = DateTime.now();

    return _data.where((reminder) {
      return reminder.duedate.isAfter(now);
    }).toList();
  }

  static List<Reminder> getAllOfToday([int? number]) {
    DateTime now = DateTime.now();
    if (number != null) {
      return _data
          .where((element) =>
              element.duedate.day == now.day &&
              element.duedate.month == now.month &&
              element.duedate.year == now.year)
          .take(number)
          .toList();
    } else {
      return _data
          .where((element) =>
              element.duedate.day == now.day &&
              element.duedate.month == now.month &&
              element.duedate.year == now.year)
          .toList();
    }
  }

  static List<Reminder> getAllReminders() {
    return _data;
  }

  static void updateReminder(Reminder reminder) {
    int index = _data.indexWhere((element) => element.id == reminder.id);

    if (index != -1) {
      _data[index] = reminder;
    } else {
      print('Reminder with ID ${reminder.id} not found');
    }
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }

  static Reminder getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }

  static void addReminder(Reminder reminder) {
    NotificationService.showScheduleNotification(
        title: "Periodic Notification",
        body: "This is a Periodic Notification",
        payload: "This is periodic data",
        date: reminder.duedate);

    _data.add(reminder);
  }
}

extension ReminderExtension on Reminder {
  bool isCompleted() {
    DateTime currentDate = DateTime.now();
    return duedate.isBefore(currentDate);
  }
}
