import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/pomodoros.dart';
import 'package:ctracker/repository/pomodoro_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

class PomodoroRepositoryImplementation extends PomodoroRepository {
  final PocketBase _pocketBase = locator<PocketBase>();

  @override
  Future<void> addPomodoro(Pomodoro pomodoro) async {
    try {
      final body = {
        "updated_by": "",
        "created_by": _pocketBase.authStore.model.id,
        "notes": pomodoro.note,
        "start_time": pomodoro.started_time.toString(),
        "end_time": pomodoro.end_time.toString()
      };

      await _pocketBase.collection('pomodoros').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "add a pomodoro",
        "entity_name": "pomodoros",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Pomodoro>> getAllPomodoros() async {
    try {
      final records = await _pocketBase
          .collection('pomodoros')
          .getFullList(sort: '-created', filter: "created_by='${_pocketBase.authStore.model.id}'",);

      return records
          .map((record) => Pomodoro(
                id: record.id,
                note: record.data["note"],
                started_time: DateTime.parse(record.data["start_time"]),
                end_time: DateTime.parse(record.data["end_time"]),
              ))
          .toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all pomodoros",
        "entity_name": "pomodoros",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<Pomodoro> getPomodoro(String id) async {
    try {
      final record = await _pocketBase.collection('pomodoros').getOne(id);

      return Pomodoro(
        id: record.id,
        note: record.data["note"],
        started_time: DateTime.parse(record.data["start_time"]),
        end_time: DateTime.parse(record.data["end_time"]),
      );
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read a pomodoro",
        "entity_name": "pomodoros",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updatePomodoro(String id, Pomodoro pomodoro) async {
    try {
      final body = {
        "updated_by": _pocketBase.authStore.model.id,
        "created_by": _pocketBase.authStore.model.id,
        "notes": pomodoro.note,
      };

      if (pomodoro.started_time != null) {
        body["start_time"] = pomodoro.started_time.toString();
      }

      if (pomodoro.end_time != null) {
        body["end_time"] = pomodoro.end_time.toString();
      }

      await _pocketBase.collection('pomodoros').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "update a pomodoro",
        "entity_name": "pomodoros",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
