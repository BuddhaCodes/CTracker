import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/enums/difficulty_enum.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/pomodoros.dart';
import 'package:ctracker/models/priorities.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/status.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  Duration timeSpend;
  final DifficultyEnum difficulty;
  final Priorities priority;
  final Effort effort;
  final Idea project;
  final Categories category;
  Status status;
  Reminder reminder;
  Pomodoro? pomodoro;
  String? created;
  String? created_by;
  String? updated_by;

  Task({
    this.id,
    this.pomodoro,
    this.created_by,
    this.updated_by,
    this.created,
    required this.title,
    required this.difficulty,
    required this.priority,
    required this.status,
    required this.effort,
    required this.category,
    required this.project,
    required this.reminder,
    required this.description,
    required this.timeSpend,
  });
}
