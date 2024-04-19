import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/models/pomodoros.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/repository/meeting_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

class MeetingRepositoryImplementation extends MeetingRepository {
  final PocketBase _pocketBase = locator<PocketBase>();

  @override
  Future<void> addMeeting(Meeting meeting) async {
    try {
      List<String> actionItemIds = [];
      for (var actionItem in meeting.actions) {
        final pomodoroBody = {
          "updated_by": "",
          "created_by": _pocketBase.authStore.model.id,
          "notes": "",
        };

        final pomodoroRecord = await _pocketBase
            .collection('pomodoros')
            .create(body: pomodoroBody);

        final actionItemBody = {
          "name": actionItem.name,
          "status": StatusEnum.notDone.id,
          "updated_by": "",
          "created_by": _pocketBase.authStore.model.id,
          "pomodoro": pomodoroRecord.id,
          "description": actionItem.description
        };

        final actionItemRecord = await _pocketBase
            .collection('action_item')
            .create(body: actionItemBody);

        actionItemIds.add(actionItemRecord.id);
      }

      final body = {
        "title": meeting.title,
        "content": meeting.content,
        "start_date": meeting.start_date.toString(),
        "end_date": meeting.end_date.toString(),
        "participants":
            meeting.participants.map((participant) => participant.id).toList(),
        "action_items": actionItemIds,
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": ""
      };

      await _pocketBase.collection('meeting').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "adding a meeting",
        "entity_name": "meeting",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteMeeting(String id) async {
    try {
      final record = await _pocketBase
          .collection('meeting')
          .getOne(id, expand: 'action_items');
      List<String> actionItemIds = record.expand["action_items"]!
          .map((actionItem) => actionItem.id)
          .toList();

      for (var actionItemId in actionItemIds) {
        final pomodoroId = record.expand["action_items"]!
            .firstWhere((actionItem) => actionItem.id == actionItemId)
            .data["pomodoro"];
        await _pocketBase.collection('pomodoros').delete(pomodoroId);
        await _pocketBase.collection('action_item').delete(actionItemId);
      }

      await _pocketBase.collection('meeting').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "deleting a meeting",
        "entity_name": "meeting",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Meeting>> getAllMeetings() async {
    try {
      final records = await _pocketBase
          .collection('meeting')
          .getFullList(sort: '-created', filter: "created_by='${_pocketBase.authStore.model.id}'", expand: 'participants,action_items');

      return records.map((record) {
        List<Participant> participants = record.expand["participants"]!
            .map((participantData) => Participant(
                id: participantData.id, name: participantData.data["name"]))
            .toList();

        List<ActionItem> actionItems =
            record.expand["action_items"]!.map((actionItemData) {
          return ActionItem(
            id: actionItemData.id,
            name: actionItemData.data["name"],
            description: actionItemData.data["description"],
            status: Status(
                id: actionItemData.data["status"],
                name: StatusEnum.values
                    .firstWhere(
                        (status) => status.id == actionItemData.data["status"])
                    .name),
            pomodoro: actionItemData.expand["pomodoro"] != null
                ? Pomodoro(
                    id: actionItemData.expand["pomodoro"]!.first.id,
                    started_time: DateTime.tryParse(actionItemData
                        .expand["pomodoro"]!.first.data["start_time"]),
                    end_time: DateTime.tryParse(actionItemData
                        .expand["pomodoro"]!.first.data["end_time"]),
                    note:
                        actionItemData.expand["pomodoro"]!.first.data["notes"],
                  )
                : null,
          );
        }).toList();

        return Meeting(
          id: record.id,
          title: record.data["title"],
          participants: participants,
          content: record.data["content"],
          start_date: DateTime.parse(record.data["start_date"]),
          end_date: DateTime.parse(record.data["end_date"]),
          actions: actionItems,
        );
      }).toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all meeting",
        "entity_name": "meeting",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateMeeting(String id, Meeting meeting) async {
    try {
      final record = await _pocketBase
          .collection('meeting')
          .getOne(id, expand: 'action_items,action_items.pomodoro');
      List<String> oldActionItemIds = record.expand["action_items"]!
          .map((actionItem) => actionItem.id)
          .toList();
      List<String> newActionItemIds =
          meeting.actions.map((actionItem) => actionItem.id ?? "").toList();

      List<String> toDelete =
          findRemovedStrings(oldActionItemIds, newActionItemIds);
      if (toDelete.isNotEmpty) {
        for (var actionItemId in toDelete) {
          final pomodoroId = record.expand["action_items"]!
              .firstWhere((actionItem) => actionItem.id == actionItemId)
              .data["pomodoro"];
          await _pocketBase.collection('action_item').delete(actionItemId);
          await _pocketBase.collection('pomodoros').delete(pomodoroId);
        }
      }

      List<String> actionItemIds = [];
      for (var actionItem
          in meeting.actions.where((actionItem) => actionItem.id == null)) {
        final pomodoroBody = {
          "updated_by": _pocketBase.authStore.model.id,
          "created_by": _pocketBase.authStore.model.id,
          "notes": "",
        };

        final pomodoroRecord = await _pocketBase
            .collection('pomodoros')
            .create(body: pomodoroBody);

        final actionItemBody = {
          "name": actionItem.name,
          "status": StatusEnum.notDone.id,
          "updated_by": _pocketBase.authStore.model.id,
          "created_by": _pocketBase.authStore.model.id,
          "pomodoro": pomodoroRecord.id,
          "description": "",
        };

        final actionItemRecord = await _pocketBase
            .collection('action_item')
            .create(body: actionItemBody);

        actionItemIds.add(actionItemRecord.id);
      }

      for (var actionItem
          in meeting.actions.where((actionItem) => actionItem.id != null)) {
        final actionItemBody = {
          "name": actionItem.name,
          "status": StatusEnum.notDone.id,
          "updated_by": _pocketBase.authStore.model.id,
          "created_by": _pocketBase.authStore.model.id,
          "description": "",
          "pomodoro": actionItem.pomodoro?.id
        };

        await _pocketBase
            .collection('action_item')
            .update(actionItem.id!, body: actionItemBody);
        actionItemIds.add(actionItem.id!);
      }

      final body = {
        "title": meeting.title,
        "content": meeting.content,
        "start_date": meeting.start_date.toString(),
        "end_date": meeting.end_date.toString(),
        "participants":
            meeting.participants.map((participant) => participant.id).toList(),
        "action_items": actionItemIds,
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": _pocketBase.authStore.model.id
      };

      await _pocketBase.collection('meeting').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "update a meeting",
        "entity_name": "meeting",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  List<String> findRemovedStrings(List<String> oldList, List<String> newList) {
    return oldList.where((string) => !newList.contains(string)).toList();
  }

  @override
  Future<List<Meeting>> getByYearAndMonth(int year, int month) async {
    try {
      String startDate =
          DateFormat('yyyy-MM-dd').format(DateTime(year, month, 1));
      String endDate = DateFormat('yyyy-MM-dd')
          .format(Utils.getLastDayOfMonth(DateTime(year, month, 1)));

      String searchCriteria =
          "start_date>='$startDate' && start_date <= '$endDate' && created_by='${_pocketBase.authStore.model.id}'";
      ResultList<RecordModel> records = await _pocketBase
          .collection('meeting')
          .getList(
              expand: 'participants,action_items',
              filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "");

      return records.items.map((record) {
        List<Participant> participants = record.expand["participants"]!
            .map((participantData) => Participant(
                id: participantData.id, name: participantData.data["name"]))
            .toList();

        List<ActionItem> actionItems =
            record.expand["action_items"]!.map((actionItemData) {
          return ActionItem(
            id: actionItemData.id,
            name: actionItemData.data["name"],
            description: actionItemData.data["description"],
            status: Status(
                id: actionItemData.data["status"],
                name: StatusEnum.values
                    .firstWhere(
                        (status) => status.id == actionItemData.data["status"])
                    .name),
            pomodoro: actionItemData.expand["pomodoro"] != null
                ? Pomodoro(
                    id: actionItemData.expand["pomodoro"]!.first.id,
                    started_time: DateTime.tryParse(actionItemData
                        .expand["pomodoro"]!.first.data["start_time"]),
                    end_time: DateTime.tryParse(actionItemData
                        .expand["pomodoro"]!.first.data["end_time"]),
                    note:
                        actionItemData.expand["pomodoro"]!.first.data["notes"],
                  )
                : null,
          );
        }).toList();

        return Meeting(
          id: record.id,
          title: record.data["title"],
          participants: participants,
          content: record.data["content"],
          start_date: DateTime.parse(record.data["start_date"]),
          end_date: DateTime.parse(record.data["end_date"]),
          actions: actionItems,
        );
      }).toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all meeting by year and month",
        "entity_name": "meeting",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<Meeting> getById(String id) async {
    try {
      final record = await _pocketBase.collection('meeting').getOne(id,
          expand: 'participants,action_items,action_items.pomodoro');

      List<Participant> participants = record.expand["participants"]!
          .map((participantData) => Participant(
              id: participantData.id, name: participantData.data["name"]))
          .toList();

      List<ActionItem> actionItems =
          record.expand["action_items"]!.map((actionItemData) {
        return ActionItem(
          id: actionItemData.id,
          name: actionItemData.data["name"],
          description: actionItemData.data["description"],
          status: Status(
              id: actionItemData.data["status"],
              name: StatusEnum.values
                  .firstWhere(
                      (status) => status.id == actionItemData.data["status"])
                  .name),
          pomodoro: actionItemData.expand["pomodoro"] != null
              ? Pomodoro(
                  id: actionItemData.expand["pomodoro"]!.first.id,
                  started_time: DateTime.tryParse(actionItemData
                      .expand["pomodoro"]!.first.data["start_time"]),
                  end_time: DateTime.tryParse(actionItemData
                      .expand["pomodoro"]!.first.data["end_time"]),
                  note: actionItemData.expand["pomodoro"]!.first.data["notes"],
                )
              : null,
        );
      }).toList();

      return Meeting(
        id: record.id,
        title: record.data["title"],
        participants: participants,
        content: record.data["content"],
        start_date: DateTime.parse(record.data["start_date"]),
        end_date: DateTime.parse(record.data["end_date"]),
        actions: actionItems,
      );
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read a meeting",
        "entity_name": "meeting",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
