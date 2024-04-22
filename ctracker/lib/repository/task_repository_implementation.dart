import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/enums/difficulty_enum.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/graphs/defficulty_resume.dart';
import 'package:ctracker/models/graphs/effort_resume.dart';
import 'package:ctracker/models/graphs/spend_time_task.dart';
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
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:workmanager/workmanager.dart';

class TaskRepositoryImplementation extends TaskRepository {
  final PocketBase _pocketBase = locator<PocketBase>();
  @override
  Future<void> addTask(Task task) async {
    try {
      final pomobody = <String, dynamic>{
        "updated_by": "",
        "created_by": _pocketBase.authStore.model.id,
        "notes": "",
      };

      final pomoRecord =
          await _pocketBase.collection('pomodoros').create(body: pomobody);

      final bodyrem = <String, dynamic>{
        "reminder_time": task.reminder.duedate.toString(),
        "updated_by": "",
        "created_by": _pocketBase.authStore.model.id,
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
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": ""
      };

      await _pocketBase.collection('tasks').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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
        "user": _pocketBase.authStore.model.id,
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
          filter: "created_by='${_pocketBase.authStore.model.id}'",
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
        "user": _pocketBase.authStore.model.id,
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
        "user": _pocketBase.authStore.model.id,
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
        "updated_by": _pocketBase.authStore.model.id,
        "created_by": _pocketBase.authStore.model.id,
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
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": _pocketBase.authStore.model.id
      };

      final record =
          await _pocketBase.collection('tasks').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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
      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' && status='${StatusEnum.done.id}'";

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
        "user": _pocketBase.authStore.model.id,
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
      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' && effort='${effort.id}'";

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
        "user": _pocketBase.authStore.model.id,
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
      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' && status='${StatusEnum.notDone.id}'";

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
        "user": _pocketBase.authStore.model.id,
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

  @override
  Future<List<DifficultyResume>> getAmountByMonthAndDifficulty(year) async {
    try {
      List<DifficultyResume> resume = [];

      for (var i = 0; i < 12; i++) {
        resume.add(DifficultyResume(month: i, easy: 0, medium: 0, hard: 0));
      }

      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' && created>='${DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1))}'";

      searchCriteria +=
          " && created <= '${DateFormat('yyyy-MM-dd').format(Utils.getLastDayOfMonth(DateTime(year, 12, 1)))}'";

      ResultList<RecordModel> records =
          await _pocketBase.collection('tasks').getList(
                expand:
                    'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category',
                filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "",
              );
      List<Task> tasks = records.items.map((e) {
        return Task(
          id: e.id,
          created: e.created,
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

      for (var i = 0; i < resume.length; i++) {
        resume[i].easy = tasks
            .where((element) =>
                DateTime.parse(element.created!).month == i + 1 &&
                element.difficulty == DifficultyEnum.easy)
            .length;
        resume[i].medium = tasks
            .where((element) =>
                DateTime.parse(element.created!).month == i + 1 &&
                element.difficulty == DifficultyEnum.mid)
            .length;
        resume[i].hard = tasks
            .where((element) =>
                DateTime.parse(element.created!).month == i + 1 &&
                element.difficulty == DifficultyEnum.hard)
            .length;
      }

      return resume;
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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

  @override
  Future<List<EffortResume>> getAmountByMonthAndEffort(int year) async {
    try {
      List<EffortResume> resume = [];

      for (var i = 0; i < 12; i++) {
        resume.add(EffortResume(month: i, poco: 0, medio: 0, mucho: 0));
      }

      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' &&  created>='${DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1))}'";

      searchCriteria +=
          " && created <= '${DateFormat('yyyy-MM-dd').format(Utils.getLastDayOfMonth(DateTime(year, 12, 1)))}'";

      ResultList<RecordModel> records =
          await _pocketBase.collection('tasks').getList(
                expand:
                    'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category',
                filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "",
              );
      List<Task> tasks = records.items.map((e) {
        return Task(
          id: e.id,
          created: e.created,
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

      for (var i = 0; i < resume.length; i++) {
        resume[i].poco = tasks
            .where((element) =>
                DateTime.parse(element.created!).month == i + 1 &&
                element.effort == Effort.poco)
            .length;
        resume[i].medio = tasks
            .where((element) =>
                DateTime.parse(element.created!).month == i + 1 &&
                element.effort == Effort.medio)
            .length;
        resume[i].mucho = tasks
            .where((element) =>
                DateTime.parse(element.created!).month == i + 1 &&
                element.effort == Effort.mucho)
            .length;
      }

      return resume;
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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

  @override
  Future<SpendTimeTask> getAllDurationByMonth(int year) async {
    try {
      SpendTimeTask timeTask = SpendTimeTask(
          january: 0,
          feb: 0,
          march: 0,
          april: 0,
          may: 0,
          june: 0,
          july: 0,
          august: 0,
          september: 0,
          october: 0,
          november: 0,
          december: 0);

      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' &&  created>='${DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1))}'";

      searchCriteria +=
          " && created <= '${DateFormat('yyyy-MM-dd').format(Utils.getLastDayOfMonth(DateTime(year, 12, 1)))}'";

      ResultList<RecordModel> records =
          await _pocketBase.collection('tasks').getList(
                expand:
                    'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category',
                filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "",
              );

      List<Task> tasks = records.items.map((e) {
        return Task(
          id: e.id,
          created: e.created,
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

      timeTask = calculateTimeSpendByMonth(tasks);

      return timeTask;
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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

  SpendTimeTask calculateTimeSpendByMonth(List<Task> tasks) {
    int january = 0;
    int february = 0;
    int march = 0;
    int april = 0;
    int may = 0;
    int june = 0;
    int july = 0;
    int august = 0;
    int september = 0;
    int october = 0;
    int november = 0;
    int december = 0;

    for (Task task in tasks) {
      if (task.created != null) {
        DateTime createdDate = DateFormat("yyyy-MM-dd").parse(task.created!);
        int month = createdDate.month;

        int timeInMinutes = task.timeSpend.inMinutes;

        switch (month) {
          case DateTime.january:
            january += timeInMinutes;
            break;
          case DateTime.february:
            february += timeInMinutes;
            break;
          case DateTime.march:
            march += timeInMinutes;
            break;
          case DateTime.april:
            april += timeInMinutes;
            break;
          case DateTime.may:
            may += timeInMinutes;
            break;
          case DateTime.june:
            june += timeInMinutes;
            break;
          case DateTime.july:
            july += timeInMinutes;
            break;
          case DateTime.august:
            august += timeInMinutes;
            break;
          case DateTime.september:
            september += timeInMinutes;
            break;
          case DateTime.october:
            october += timeInMinutes;
            break;
          case DateTime.november:
            november += timeInMinutes;
            break;
          case DateTime.december:
            december += timeInMinutes;
            break;
        }
      }
    }

    // Return instance of SpendTimeTask
    return SpendTimeTask(
      january: january,
      feb: february,
      march: march,
      april: april,
      may: may,
      june: june,
      july: july,
      august: august,
      september: september,
      october: october,
      november: november,
      december: december,
    );
  }
}
