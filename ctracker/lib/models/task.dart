import 'package:ctracker/models/effort.dart';
import 'package:ctracker/models/inotable.dart';
import 'package:ctracker/models/note.dart';

class Task extends INotable {
  final int id;
  final String title;
  final String difficulty;
  final String priority;
  final Effort effort;
  final String category;
  final String project;
  final String description;
  final List<String> images;
  bool hasFinished;
  Duration timeSpend;

  Task(
    super.note, {
    required this.id,
    required this.title,
    required this.difficulty,
    required this.priority,
    required this.effort,
    required this.category,
    required this.project,
    required this.description,
    required this.images,
    required this.hasFinished,
    required this.timeSpend,
  });
}

class TaskData {
  static final List<Task> _data = [
    Task(
        [
          Note(
              id: 1,
              board: "Notes",
              content: "This is an important note",
              title: "Important",
              createdTime: DateTime.now())
        ],
        id: 1,
        title: 'This is Task 1',
        difficulty: 'Easy',
        priority: '10',
        effort: Effort.mucho,
        category: 'Category A',
        description: 'Description A',
        project: 'Projects A',
        images: ['Image A', 'Image B'],
        hasFinished: false,
        timeSpend: Duration.zero),
    Task(
        [
          Note(
              id: 2,
              board: "Notes",
              content: "This is another important note",
              title: "Another Important",
              createdTime: DateTime.now().add(const Duration(minutes: 10)))
        ],
        id: 2,
        title: 'This is Task 2',
        difficulty: 'Hard',
        priority: '8',
        effort: Effort.poco,
        category: 'Category B',
        description: 'Description B',
        project: 'Project A',
        images: ['Image A', 'Image B'],
        hasFinished: false,
        timeSpend: Duration.zero),
  ];

  static List<Task> getAllTasks() {
    return _data;
  }

  static int getTotalTasks() {
    return _data.length;
  }

  static int getCompletedTotal() {
    return getAllTasksCompleted().length;
  }

  static List<Task> getAllTByEffort(Effort effort) {
    return _data.where((element) => element.effort == effort).toList();
  }

  static List<Task> getAllTasksCompleted() {
    return _data.where((element) => element.hasFinished == true).toList();
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }

  static void updateTask(Task task) {
    int index = _data.indexWhere((element) => element.id == task.id);

    // If the reminder with the given ID is found, update its properties
    if (index != -1) {
      _data[index] = task;
    } else {
      print('Reminder with ID ${task.id} not found');
    }
  }

  static Task getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }

  static void addTask(Task task) {
    return _data.add(task);
  }
}
