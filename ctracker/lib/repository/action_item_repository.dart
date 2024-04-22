import 'package:ctracker/models/action_items.dart';

abstract class ActionItemRepository {
  Future<void> updateActionItem(ActionItem actionItem);
}
