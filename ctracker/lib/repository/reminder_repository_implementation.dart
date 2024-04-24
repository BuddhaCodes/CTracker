import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/repeat_types.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/repository/reminder_repository.dart';
import 'package:ctracker/utils/notification_manager.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:workmanager/workmanager.dart';

class ReminderRepositoryImplementation implements ReminderRepository {
  final PocketBase _pocketBase = locator<PocketBase>();
  @override
  Future<List<Reminder>> getAllReminder() async {
    try {
      final records = await _pocketBase.collection('reminder').getFullList(
            sort: '-created',
            expand: 'frequency,status',
            filter: "created_by='${_pocketBase.authStore.model.id}'",
          );

      return records.map((record) => _mapToReminder(record)).toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all reminder",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Reminder>> getByStatus(Status status) async {
    try {
      String searchCriteria =
          "status='${status.id}' && created_by='${_pocketBase.authStore.model.id}'";

      final records = await _pocketBase.collection('reminder').getFullList(
          sort: '-created', expand: 'frequency,status', filter: searchCriteria);

      return records.map((record) => _mapToReminder(record)).toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all reminder by status",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    try {
      final body = {
        "title": reminder.title,
        "reminder_time": reminder.duedate.toString(),
        "updated_by": "",
        "of_task": reminder.of_task,
        "created_by": _pocketBase.authStore.model.id,
        "frequency": reminder.type.id,
        "status": reminder.status?.id
      };

      final createdReminder =
          await _pocketBase.collection('reminder').create(body: body);

      var inputData = {
        'key': createdReminder.id,
        'date': reminder.duedate.toString(),
        'rt': reminder.type.id,
        'title': reminder.title,
      };
      if (!kIsWeb) {
        NotificationManager.scheduleNextNotification(inputData);
      }
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "create a reminder",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    try {
      if (!kIsWeb) {
        await Workmanager().cancelByUniqueName(id);
      }

      await _pocketBase.collection('reminder').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "delete a reminder",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateReminder(String id, Reminder reminder) async {
    try {
      final body = {
        "title": reminder.title,
        "reminder_time": reminder.duedate.toString(),
        "updated_by": _pocketBase.authStore.model.id,
        "created_by": _pocketBase.authStore.model.id,
        "of_task": reminder.of_task,
        "frequency": reminder.type.id,
        "status": reminder.status?.id
      };

      await _pocketBase.collection('reminder').update(id, body: body);
      await Workmanager().cancelByUniqueName(id);
      var inputData = {
        'key': reminder.id,
        'date': reminder.duedate.toString(),
        'rt': reminder.type,
        'title': reminder.title,
      };
      await Workmanager().cancelByUniqueName(id);
      NotificationManager.scheduleNextNotification(inputData);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "update a reminder",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Reminder>> getAllRemindersOfDateToDate(DateTime fromDate,
      {DateTime? toDate, StatusEnum? status, int? take}) async {
    try {
      String searchCriteria =
          "created_by='${_pocketBase.authStore.model.id}' && reminder_time>='${DateFormat('yyyy-MM-dd').format(fromDate)}'";

      if (toDate != null) {
        searchCriteria +=
            " && reminder_time <= '${DateFormat('yyyy-MM-dd').format(toDate)}'";
      }

      if (status != null) {
        searchCriteria += " && status='${status.id}'";
      }

      final records = await _pocketBase.collection('reminder').getFullList(
          sort: '-created', expand: 'frequency,status', filter: searchCriteria);

      return records.map((record) => _mapToReminder(record)).toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all reminder from date range",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<Reminder> getById(String id) async {
    try {
      final record = await _pocketBase.collection('reminder').getOne(
            id,
            expand: 'frequency,status',
          );
      return _mapToReminder(record);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read a reminder by id",
        "entity_name": "reminder",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  Reminder _mapToReminder(RecordModel record) {
    return Reminder(
      id: record.id,
      title: record.data["title"],
      of_task: record.data["of_task"],
      duedate: DateTime.parse(record.data["reminder_time"]),
      status: record.expand["status"] != null
          ? Status(
              id: record.expand["status"]!.first.id,
              name: record.expand["status"]!.first.data["name"],
            )
          : null,
      type: RepeatType(
        id: record.expand["frequency"]!.first.id,
        name: record.expand["frequency"]!.first.data["name"],
      ),
    );
  }
}
