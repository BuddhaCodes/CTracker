import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/participant_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

class ParticipantRepositoryImplementation extends ParticipantRepository {
  final PocketBase _pocketBase = locator<PocketBase>();
  @override
  Future<List<Participant>> getAllParticipants() async {
    try {
      final records = await _pocketBase.collection('participants').getFullList(
            sort: '-created',
            filter: "created_by='${_pocketBase.authStore.model.id}'",
          );

      return records
          .map((e) => Participant(
              id: e.id,
              name: e.data["name"],
              email: e.data["email"],
              number: e.data["number"]))
          .toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "get all participants",
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
  Future<void> addParticipant(Participant participant) async {
    try {
      final body = <String, dynamic>{
        "name": participant.name,
        "created_by": _pocketBase.authStore.model.id,
        "email": participant.email,
        "number": participant.number,
        "updated_by": ""
      };

      await _pocketBase.collection('participants').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "add a participants",
        "entity_name": "participants",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteParticipant(String id) async {
    try {
      await _pocketBase.collection('participants').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "delete a participants",
        "entity_name": "participants",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateParticipant(String id, Participant participant) async {
    try {
      final body = <String, dynamic>{
        "name": participant.name,
        "created_by": _pocketBase.authStore.model.id,
        "email": participant.email,
        "number": participant.number,
        "updated_by": _pocketBase.authStore.model.id,
      };
      await _pocketBase.collection('participants').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "update a participant",
        "entity_name": "participant",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
