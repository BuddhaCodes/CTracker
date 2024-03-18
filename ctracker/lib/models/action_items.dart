import 'package:ctracker/models/inotable.dart';

class ActionItem extends INotable {
  final int id;
  final String title;
  bool hasFinished;
  ActionItem(super.note,
      {this.hasFinished = false, required this.id, required this.title});
}
