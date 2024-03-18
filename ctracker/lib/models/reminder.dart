import 'package:ctracker/utils/local_notification_service.dart';

class Reminder {
  final int id;
  final String title;
  final DateTime duedate;
  final String description;
  String? note;
  final List<String> categories;
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
      title: 'Notes for Task 1',
      duedate: DateTime.now(),
      description: 'Description of Task 1',
      note: 'Notes for Task 1',
      categories: ['Category B'],
      images: ['Image A'],
    ),
    Reminder(
      id: 2,
      title: 'Notes for Task 1',
      duedate: DateTime.now(),
      description: 'Description of Task 1',
      note: 'Notes for Task 1',
      categories: ['Category A'],
      images: ['Image A'],
    ),
    Reminder(
      id: 3,
      title: 'Notes for Task 3',
      duedate: DateTime.now().add(const Duration(days: 1)),
      description: 'Description of Task 3',
      note: 'Notes for Task 3',
      categories: ['Category A'],
      images: ['Image A'],
    ),
  ];

  static List<Reminder> getAllReminders() {
    return _data;
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }

  static Reminder getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }

  static void addReminder(Reminder reminder) {
    ReminderService.scheduleNotification(reminder);
    _data.add(reminder);
  }
}
