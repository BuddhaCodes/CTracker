class ReminderCategory {
  final int id;
  final String name;

  ReminderCategory({
    required this.id,
    required this.name,
  });
}

class ReminderCategoryData {
  static final List<ReminderCategory> _data = [
    ReminderCategory(
      id: 1,
      name: 'Category A',
    ),
    ReminderCategory(
      id: 2,
      name: 'Category B',
    ),
    ReminderCategory(
      id: 3,
      name: 'Category C',
    )
  ];

  static List<ReminderCategory> getAllItemType() {
    return _data;
  }
}
