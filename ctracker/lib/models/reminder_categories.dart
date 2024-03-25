import 'dart:ui';

class ReminderCategory {
  final int id;
  final String name;
  final Color color;

  ReminderCategory({
    required this.id,
    required this.name,
    required this.color,
  });
}

class ReminderCategoryData {
  static final List<ReminderCategory> _data = [
    ReminderCategory(id: 1, name: 'Category A', color: Color.fromARGB(255, 89, 135, 244)),
    ReminderCategory(
        id: 2, name: 'Category B', color: Color.fromARGB(255, 81, 233, 99)),
    ReminderCategory(id: 3, name: 'Category C', color: Color.fromARGB(255, 248, 143, 86))
  ];

  static List<ReminderCategory> getAllItemType() {
    return _data;
  }

  static ReminderCategory getById(int id) {
    return _data.where((element) => element.id == id).first;
  }
}
