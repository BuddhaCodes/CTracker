import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/enums/difficulty_enum.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/pomodoros.dart';
import 'package:ctracker/models/priorities.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/repeat_types.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/repository/task_repository.dart';
import 'package:ctracker/utils/notification_manager.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:workmanager/workmanager.dart';

class TaskRepositoryImplementation extends TaskRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');
  @override
  Future<void> addTask(Task task) async {
    try {
      final pomobody = <String, dynamic>{
        "updated_by": "l1t6jwj73151zc3",
        "created_by": "l1t6jwj73151zc3",
        "notes": "",
      };


      final pomoRecord =
          await _pocketBase.collection('pomodoros').create(body: pomobody);

      final bodyrem = <String, dynamic>{
        "reminder_time": task.reminder.duedate.toString(),
        "updated_by": "l1t6jwj73151zc3",
        "created_by": "l1t6jwj73151zc3",
        "frequency": task.reminder.type.id,
        "status": StatusEnum.notDone.id,
        "title": task.reminder.title
      };

      final rem =
          await _pocketBase.collection('reminder').create(body: bodyrem);
      var inputData = <String, dynamic>{
        'key': rem.id,
        'date': task.reminder.duedate.toString(),
        'rt': task.reminder.type.id,
        'title': task.reminder.title,
      };
      if (!kIsWeb) {
        NotificationManager.scheduleNextNotification(inputData);
      }
      final body = <String, dynamic>{
        "title": task.title,
        "description": task.description,
        "time_spend": task.timeSpend.toString(),
        "difficulty": task.difficulty.id,
        "priority": task.priority.id,
        "pomodoro": pomoRecord.id,
        "effort": task.effort.id,
        "project": task.project.id,
        "category": task.category.id,
        "status": task.status.id,
        "reminder": rem.id,
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3"
      };

      await _pocketBase.collection('tasks').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "add a task",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final record = await _pocketBase.collection('tasks').getOne(id,
          expand:
              'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category');
      if (!kIsWeb) {
        await Workmanager()
            .cancelByUniqueName(record.expand["reminder"]!.first.id);
      }
      await _pocketBase
          .collection('reminder')
          .delete(record.expand["reminder"]!.first.id);
      await _pocketBase
          .collection('pomodoros')
          .delete(record.expand["pomodoro"]!.first.id);
      await _pocketBase.collection('tasks').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "delete a task",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final records = await _pocketBase.collection('tasks').getFullList(
          sort: '-created',
          expand:
              'difficulty,status,priority,effort,project,category,reminder,reminder.status,reminder.frequency,pomodoro,project.tag,project.category');

      List<Task> tasks = records.map((e) {
        return Task(
          id: e.id,
          title: e.data["title"],
          timeSpend: Utils.parseDuration(e.data["time_spend"]),
          pomodoro: e.expand["pomodoro"] != null
              ? Pomodoro(
                  id: e.expand["pomodoro"]!.first.id,
                  started_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["start_time"]),
                  end_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["end_time"]),
                  note: e.expand["pomodoro"]!.first.data["notes"])
              : null,
          priority: Priorities(
              id: e.expand["priority"]!.first.id,
              name: e.expand["priority"]!.first.data["name"],
              level: e.expand["priority"]!.first.data["level"]),
          description: e.data["description"],
          effort: Effort.values
              .where((element) => element.id == e.expand["effort"]?.first.id)
              .first,
          difficulty: DifficultyEnum.values
              .where(
                  (element) => element.id == e.expand["difficulty"]?.first.id)
              .first,
          status: Status(
              id: e.expand["status"]!.first.id,
              name: e.expand["status"]!.first.data["name"]),
          category: Categories(
            id: e.expand["category"]!.first.id,
            name: e.expand["category"]!.first.data["name"],
            description: e.expand["category"]!.first.data["description"],
          ),
          reminder: Reminder(
            id: e.expand["reminder"]!.first.id,
            title: e.expand["reminder"]!.first.data["title"],
            duedate: DateTime.parse(
                e.expand["reminder"]!.first.data["reminder_time"]),
            type: RepeatType(
              id: e.expand["reminder"]!.first.expand["frequency"]!.first.id,
              name: e.expand["reminder"]!.first.expand["frequency"]!.first
                  .data["name"],
            ),
            status: Status(
              id: e.expand["reminder"]!.first.expand["status"]!.first.id,
              name: e.expand["reminder"]!.first.expand["status"]!.first
                  .data["name"],
            ),
          ),
          project: Idea(
            id: e.expand["project"]!.first.id,
            title: e.expand["project"]!.first.data["title"],
            description: e.expand["project"]!.first.data["description"],
            tags: e.expand["project"]!.first.expand["tag"]
                    ?.map((y) => Tag(
                          id: y.id,
                          title: y.data["title"],
                        ))
                    .toList() ??
                [],
            category: Categories(
              id: e.expand["project"]!.first.expand["category"]!.first.id,
              name: e.expand["project"]!.first.expand["category"]!.first
                  .data["name"],
              description: e.expand["project"]!.first.expand["category"]!.first
                  .data["description"],
            ),
          ),
        );
      }).toList();
      return tasks;
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all task",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<Task> getTaskById(String id) async {
    try {
      final record = await _pocketBase.collection('tasks').getOne(id,
          expand:
              'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category');
      Task task = Task(
        id: record.id,
        title: record.data["title"],
        timeSpend: Utils.parseDuration(record.data["time_spend"]),
        pomodoro: record.expand["pomodoro"] != null
            ? Pomodoro(
                id: record.expand["pomodoro"]!.first.id,
                started_time: DateTime.tryParse(
                    record.expand["pomodoro"]!.first.data["start_time"]),
                end_time: DateTime.tryParse(
                    record.expand["pomodoro"]!.first.data["end_time"]),
                note: record.expand["pomodoro"]!.first.data["notes"])
            : null,
        priority: Priorities(
            id: record.expand["priority"]!.first.id,
            name: record.expand["priority"]!.first.data["name"],
            level: record.expand["priority"]!.first.data["level"]),
        description: record.data["description"],
        effort: Effort.values
            .where((element) => element.id == record.expand["effort"]?.first.id)
            .first,
        difficulty: DifficultyEnum.values
            .where((element) =>
                element.id == record.expand["difficulty"]?.first.id)
            .first,
        status: Status(
            id: record.expand["status"]!.first.id,
            name: record.expand["status"]!.first.data["name"]),
        category: Categories(
          id: record.expand["category"]!.first.id,
          name: record.expand["category"]!.first.data["name"],
          description: record.expand["category"]!.first.data["description"],
        ),
        reminder: Reminder(
          id: record.expand["reminder"]!.first.id,
          title: record.expand["reminder"]!.first.data["title"],
          duedate: DateTime.parse(
              record.expand["reminder"]!.first.data["reminder_time"]),
          type: RepeatType(
            id: record.expand["reminder"]!.first.expand["frequency"]!.first.id,
            name: record.expand["reminder"]!.first.expand["frequency"]!.first
                .data["name"],
          ),
          status: Status(
            id: record.expand["reminder"]!.first.expand["status"]!.first.id,
            name: record
                .expand["reminder"]!.first.expand["status"]!.first.data["name"],
          ),
        ),
        project: Idea(
          id: record.expand["project"]!.first.id,
          title: record.expand["project"]!.first.data["title"],
          description: record.expand["project"]!.first.data["description"],
          tags: record.expand["project"]!.first.expand["tag"]
                  ?.map((y) => Tag(
                        id: y.id,
                        title: y.data["title"],
                      ))
                  .toList() ??
              [],
          category: Categories(
            id: record.expand["project"]!.first.expand["category"]!.first.id,
            name: record.expand["project"]!.first.expand["category"]!.first
                .data["name"],
            description: record.expand["project"]!.first.expand["category"]!
                .first.data["description"],
          ),
        ),
      );

      return task;
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read a task by id",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateTask(String id, Task task) async {
    try {
      final bodyrem = <String, dynamic>{
        "reminder_time": task.reminder.duedate.toString(),
        "updated_by": "l1t6jwj73151zc3",
        "created_by": "l1t6jwj73151zc3",
        "frequency": task.reminder.type.id,
        "status": StatusEnum.notDone.id,
        "title": task.reminder.title
      };
      final rem = await _pocketBase
          .collection('reminder')
          .update(task.reminder.id ?? "", body: bodyrem);

      if (!kIsWeb) {
        await Workmanager().cancelByUniqueName(rem.id);
      }

      var inputData = <String, dynamic>{
        'key': rem.id,
        'date': task.reminder.duedate.toString(),
        'rt': task.reminder.type.id,
        'title': task.reminder.title,
      };

      if (!kIsWeb) {
        NotificationManager.scheduleNextNotification(inputData);
      }

      final body = <String, dynamic>{
        "title": task.title,
        "description": task.description,
        "time_spend": task.timeSpend.toString(),
        "difficulty": task.difficulty.id,
        "priority": task.priority.id,
        "effort": task.effort.id,
        "project": task.project.id,
        "category": task.category.id,
        "status": task.status.id,
        "reminder": rem.id,
        "pomodoro": task.pomodoro?.id,
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3"
      };

      final record =
          await _pocketBase.collection('tasks').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "update a task",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<int> getAmountCompletedTasks() async {
    try {
      List<Task> fetch = await getAllTasks();
      return fetch
          .where((element) => element.status.id == StatusEnum.done.id)
          .length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getAmountOfTask() async {
    try {
      List<Task> fetch = await getAllTasks();
      return fetch.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<List<Task>> getCompletedTask() async {
    try {
      String searchCriteria = "";

      searchCriteria += "status='${StatusEnum.done.id}'";

      ResultList<RecordModel> records =
          await _pocketBase.collection('tasks').getList(
                expand:
                    'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category',
                filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "",
              );

      List<Task> tasks = records.items.map((e) {
        return Task(
          id: e.id,
          title: e.data["title"],
          timeSpend: Utils.parseDuration(e.data["time_spend"]),
          pomodoro: e.expand["pomodoro"] != null
              ? Pomodoro(
                  id: e.expand["pomodoro"]!.first.id,
                  started_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["start_time"]),
                  end_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["end_time"]),
                  note: e.expand["pomodoro"]!.first.data["notes"])
              : null,
          priority: Priorities(
              id: e.expand["priority"]!.first.id,
              name: e.expand["priority"]!.first.data["name"],
              level: e.expand["priority"]!.first.data["level"]),
          description: e.data["description"],
          effort: Effort.values
              .where((element) => element.id == e.expand["effort"]?.first.id)
              .first,
          difficulty: DifficultyEnum.values
              .where(
                  (element) => element.id == e.expand["difficulty"]?.first.id)
              .first,
          status: Status(
              id: e.expand["status"]!.first.id,
              name: e.expand["status"]!.first.data["name"]),
          category: Categories(
            id: e.expand["category"]!.first.id,
            name: e.expand["category"]!.first.data["name"],
            description: e.expand["category"]!.first.data["description"],
          ),
          reminder: Reminder(
            id: e.expand["reminder"]!.first.id,
            title: e.expand["reminder"]!.first.data["title"],
            duedate: DateTime.parse(
                e.expand["reminder"]!.first.data["reminder_time"]),
            type: RepeatType(
              id: e.expand["reminder"]!.first.expand["frequency"]!.first.id,
              name: e.expand["reminder"]!.first.expand["frequency"]!.first
                  .data["name"],
            ),
            status: Status(
              id: e.expand["reminder"]!.first.expand["status"]!.first.id,
              name: e.expand["reminder"]!.first.expand["status"]!.first
                  .data["name"],
            ),
          ),
          project: Idea(
            id: e.expand["project"]!.first.id,
            title: e.expand["project"]!.first.data["title"],
            description: e.expand["project"]!.first.data["description"],
            tags: e.expand["project"]!.first.expand["tag"]
                    ?.map((y) => Tag(
                          id: y.id,
                          title: y.data["title"],
                        ))
                    .toList() ??
                [],
            category: Categories(
              id: e.expand["project"]!.first.expand["category"]!.first.id,
              name: e.expand["project"]!.first.expand["category"]!.first
                  .data["name"],
              description: e.expand["project"]!.first.expand["category"]!.first
                  .data["description"],
            ),
          ),
        );
      }).toList();
      return tasks;
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all completed tasks",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Task>> getByEffort(Effort effort) async {
    try {
      String searchCriteria = "";

      searchCriteria += "effort='${effort.id}'";

      ResultList<RecordModel> records =
          await _pocketBase.collection('tasks').getList(
                expand:
                    'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category',
                filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "",
              );

      List<Task> tasks = records.items.map((e) {
        return Task(
          id: e.id,
          title: e.data["title"],
          timeSpend: Utils.parseDuration(e.data["time_spend"]),
          pomodoro: e.expand["pomodoro"] != null
              ? Pomodoro(
                  id: e.expand["pomodoro"]!.first.id,
                  started_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["start_time"]),
                  end_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["end_time"]),
                  note: e.expand["pomodoro"]!.first.data["notes"])
              : null,
          priority: Priorities(
              id: e.expand["priority"]!.first.id,
              name: e.expand["priority"]!.first.data["name"],
              level: e.expand["priority"]!.first.data["level"]),
          description: e.data["description"],
          effort: Effort.values
              .where((element) => element.id == e.expand["effort"]?.first.id)
              .first,
          difficulty: DifficultyEnum.values
              .where(
                  (element) => element.id == e.expand["difficulty"]?.first.id)
              .first,
          status: Status(
              id: e.expand["status"]!.first.id,
              name: e.expand["status"]!.first.data["name"]),
          category: Categories(
            id: e.expand["category"]!.first.id,
            name: e.expand["category"]!.first.data["name"],
            description: e.expand["category"]!.first.data["description"],
          ),
          reminder: Reminder(
            id: e.expand["reminder"]!.first.id,
            title: e.expand["reminder"]!.first.data["title"],
            duedate: DateTime.parse(
                e.expand["reminder"]!.first.data["reminder_time"]),
            type: RepeatType(
              id: e.expand["reminder"]!.first.expand["frequency"]!.first.id,
              name: e.expand["reminder"]!.first.expand["frequency"]!.first
                  .data["name"],
            ),
            status: Status(
              id: e.expand["reminder"]!.first.expand["status"]!.first.id,
              name: e.expand["reminder"]!.first.expand["status"]!.first
                  .data["name"],
            ),
          ),
          project: Idea(
            id: e.expand["project"]!.first.id,
            title: e.expand["project"]!.first.data["title"],
            description: e.expand["project"]!.first.data["description"],
            tags: e.expand["project"]!.first.expand["tag"]
                    ?.map((y) => Tag(
                          id: y.id,
                          title: y.data["title"],
                        ))
                    .toList() ??
                [],
            category: Categories(
              id: e.expand["project"]!.first.expand["category"]!.first.id,
              name: e.expand["project"]!.first.expand["category"]!.first
                  .data["name"],
              description: e.expand["project"]!.first.expand["category"]!.first
                  .data["description"],
            ),
          ),
        );
      }).toList();
      return tasks;
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all task by effort",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Task>> getNoCompletedTask() async {
    try {
      String searchCriteria = "";

      searchCriteria += "status='${StatusEnum.notDone.id}'";

      ResultList<RecordModel> records =
          await _pocketBase.collection('tasks').getList(
                expand:
                    'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category',
                filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "",
              );
      List<Task> tasks = records.items.map((e) {
        return Task(
          id: e.id,
          title: e.data["title"],
          timeSpend: Utils.parseDuration(e.data["time_spend"]),
          pomodoro: e.expand["pomodoro"] != null
              ? Pomodoro(
                  id: e.expand["pomodoro"]!.first.id,
                  started_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["start_time"]),
                  end_time: DateTime.tryParse(
                      e.expand["pomodoro"]!.first.data["end_time"]),
                  note: e.expand["pomodoro"]!.first.data["notes"])
              : null,
          priority: Priorities(
              id: e.expand["priority"]!.first.id,
              name: e.expand["priority"]!.first.data["name"],
              level: e.expand["priority"]!.first.data["level"]),
          description: e.data["description"],
          effort: Effort.values
              .where((element) => element.id == e.expand["effort"]?.first.id)
              .first,
          difficulty: DifficultyEnum.values
              .where(
                  (element) => element.id == e.expand["difficulty"]?.first.id)
              .first,
          status: Status(
              id: e.expand["status"]!.first.id,
              name: e.expand["status"]!.first.data["name"]),
          category: Categories(
            id: e.expand["category"]!.first.id,
            name: e.expand["category"]!.first.data["name"],
            description: e.expand["category"]!.first.data["description"],
          ),
          reminder: Reminder(
            id: e.expand["reminder"]!.first.id,
            title: e.expand["reminder"]!.first.data["title"],
            duedate: DateTime.parse(
                e.expand["reminder"]!.first.data["reminder_time"]),
            type: RepeatType(
              id: e.expand["reminder"]!.first.expand["frequency"]!.first.id,
              name: e.expand["reminder"]!.first.expand["frequency"]!.first
                  .data["name"],
            ),
            status: Status(
              id: e.expand["reminder"]!.first.expand["status"]!.first.id,
              name: e.expand["reminder"]!.first.expand["status"]!.first
                  .data["name"],
            ),
          ),
          project: Idea(
            id: e.expand["project"]!.first.id,
            title: e.expand["project"]!.first.data["title"],
            description: e.expand["project"]!.first.data["description"],
            tags: e.expand["project"]!.first.expand["tag"]
                    ?.map((y) => Tag(
                          id: y.id,
                          title: y.data["title"],
                        ))
                    .toList() ??
                [],
            category: Categories(
              id: e.expand["project"]!.first.expand["category"]!.first.id,
              name: e.expand["project"]!.first.expand["category"]!.first
                  .data["name"],
              description: e.expand["project"]!.first.expand["category"]!.first
                  .data["description"],
            ),
          ),
        );
      }).toList();

      return tasks;
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all task no completed",
        "entity_name": "tasks",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
