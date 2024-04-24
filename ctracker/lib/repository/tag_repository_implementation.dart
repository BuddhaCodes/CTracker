import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/repository/tag_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

class TagRepositoryImplementation implements TagRepository {
  final PocketBase _pocketBase = locator<PocketBase>();

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
        "user": _pocketBase.authStore.model.id,
        "description": "read all tags",
        "entity_name": "tags",
        "timestamp": DateTime.now().toString(),
        "message": e.toString(),
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
