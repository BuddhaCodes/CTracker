import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/graphs/defficulty_resume.dart';
import 'package:ctracker/models/graphs/effort_resume.dart';
import 'package:ctracker/models/graphs/spend_time_task.dart';
import 'package:ctracker/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task> getTaskById(String id);
  Future<void> deleteTask(String id);
  Future<void> updateTask(String id, Task task);
  Future<void> addTask(Task task);
  Future<int> getAmountCompletedTasks();
  Future<int> getAmountOfTask();
  Future<List<Task>> getCompletedTask();
  Future<List<Task>> getNoCompletedTask();
  Future<List<DifficultyResume>> getAmountByMonthAndDifficulty(int year);
  Future<List<EffortResume>> getAmountByMonthAndEffort(int year);
  Future<SpendTimeTask> getAllDurationByMonth(int year);
  Future<List<Task>> getByEffort(Effort effort);
}
