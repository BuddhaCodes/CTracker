import 'package:ctracker/models/enums/effort_enum.dart';
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
  Future<List<Task>> getByEffort(Effort effort);
}
