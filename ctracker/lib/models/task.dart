import 'package:ctracker/models/inotable.dart';
import 'package:ctracker/models/note.dart';

class Task extends INotable {
  final int id;
  final String title;
  final String difficulty;
  final String priority;
  final String effort;
  final List<String> categories;
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
    required this.categories,
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
        effort: '\u{1F4AA} I can handle it with a bit of effort \u{1F4AA}',
        categories: ['Category A'],
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
        effort: '\u{26A1} I will have to summon the powers of Odin \u{26A1}',
        categories: ['Category B'],
        description: 'Description B',
        project: 'Project A',
        images: ['Image A', 'Image B'],
        hasFinished: false,
        timeSpend: Duration.zero),
  ];

  static List<Task> getAllTasks() {
    return _data;
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }

  static Task getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }

  static void addTask(Task task) {
    return _data.add(task);
  }
}
