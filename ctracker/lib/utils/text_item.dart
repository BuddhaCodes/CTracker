import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/models/action_items.dart';

class TextItem extends AppFlowyGroupItem {
  final String title;
  final String note;
  final String subTitle;

  TextItem(this.title, this.note, this.subTitle);

  @override
  String get id => title;
}

class IdeaTextItem extends AppFlowyGroupItem {
  final int uid;
  final String title;
  final List<String> tags;
  final String description;

  IdeaTextItem(this.uid, this.title, this.tags, this.description);

  @override
  String get id => uid.toString();
}

class MeetingTextItem extends AppFlowyGroupItem {
  final int uid;
  final String title;
  final List<String> participants;
  final List<ActionItem> actionItems;

  MeetingTextItem(this.uid, this.title, this.participants, this.actionItems);

  @override
  String get id => uid.toString();
}
