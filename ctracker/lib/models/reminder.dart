class Reminder {
  final int id;
  final String title;
  final DateTime duedate;
  final String description;
  final String note;
  final List<String> categories;
  final List<String> images;

  Reminder({
    required this.id,
    required this.title,
    required this.duedate,
    required this.description,
    required this.note,
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
      categories: ['Category A'],
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
    // Add more data as needed
  ];

  static List<Reminder> getAllReminders() {
    return _data;
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }
}
