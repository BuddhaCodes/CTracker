class Task {
  final int id;
  final String title;
  final String difficulty;
  final String priority;
  final String effort;
  final List<String> categories;
  final String project;
  final String description;
  final List<String> images;
  final String note;

  Task({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.priority,
    required this.effort,
    required this.categories,
    required this.project,
    required this.description,
    required this.images,
    required this.note,
  });
}

class TaskData {
  static final List<Task> _data = [
    Task(
        id: 1,
        title: 'Notes for Task 1',
        difficulty: 'Task 1',
        priority: 'Priority A',
        effort: 'Description of Task 1',
        categories: ['Category 1'],
        description: 'Description A',
        project: 'Project A',
        images: ['Image A', 'Image B'],
        note: 'Note A'),
    Task(
        id: 2,
        title: 'Notes for Task 2',
        difficulty: 'Task 2',
        priority: 'Priority B',
        effort: 'Description of Task 2',
        categories: ['Category 2'],
        description: 'Description B',
        project: 'Project A',
        images: ['Image A', 'Image B'],
        note: 'Note A'),
    // Add more data as needed
  ];

  static List<Task> getAllTasks() {
    return _data;
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }
}
