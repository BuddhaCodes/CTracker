class TaskCategory {
  final int id;
  final String name;

  TaskCategory({
    required this.id,
    required this.name,
  });
}

class TaskCategoryData {
  static final List<TaskCategory> _data = [
    TaskCategory(
      id: 1,
      name: 'Category A',
    ),
    TaskCategory(
      id: 2,
      name: 'Category B',
    ),
    TaskCategory(
      id: 3,
      name: 'Category C',
    )
  ];

  static List<TaskCategory> getAllItemType() {
    return _data;
  }
}
