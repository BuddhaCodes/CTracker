import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/repository/action_item_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class ActionItemRepositoryImplementation extends ActionItemRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');

  @override
  Future<void> updateActionItem(ActionItem actionItem) async {
    try {
      final body = {
        "name": actionItem.id,
        "updated_by": "l1t6jwj73151zc3",
        "created_by": "l1t6jwj73151zc3",
        "description": actionItem.description,
        "status": actionItem.status?.id,
        "pomodoro": actionItem.pomodoro?.id
      };

      final itemId = actionItem.id ?? "";
      await _pocketBase.collection('action_item').update(itemId, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "updating an action",
        "entity_name": "action_item",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow; // Rethrow the exception to propagate it further if needed
    }
  }
}
