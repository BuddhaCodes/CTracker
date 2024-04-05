import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/priorities.dart';
import 'package:ctracker/repository/priorities_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class PrioritiesRepositoryImplementation extends PrioritiesRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');

  @override
  Future<List<Priorities>> getAllPriorities() async {
    try {
      final records = await _pocketBase
          .collection('priorities')
          .getFullList(sort: '-created');

      return records
          .map((record) => Priorities(
              id: record.id,
              name: record.data["name"],
              level: record.data["level"]))
          .toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all priorities",
        "entity_name": "priorities",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
