import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/repository/status_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

class StatusRepositoryImplementation implements StatusRepository {
  final PocketBase _pocketBase = locator<PocketBase>();

  @override
  Future<List<Status>> getAllStatus() async {
    try {
      final records =
          await _pocketBase.collection('status').getFullList(sort: '-created');

      return records
          .map((record) => Status(id: record.id, name: record.data["name"]))
          .toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read all status",
        "entity_name": "status",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<Status> getById(String id) async {
    try {
      final record =
          await _pocketBase.collection('status').getFirstListItem('id="$id"');

      return Status(id: record.id, name: record.data["name"]);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "read a status by id",
        "entity_name": "status",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
