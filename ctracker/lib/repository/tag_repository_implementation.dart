import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/repository/tag_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class TagRepositoryImplementation implements TagRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');

  @override
  Future<List<Tag>> getAllTags() async {
    try {
      final records =
          await _pocketBase.collection('tags').getFullList(sort: '-created');

      return records
          .map((record) => Tag(id: record.id, title: record.data["title"]))
          .toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all tags",
        "entity_name": "tags",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
