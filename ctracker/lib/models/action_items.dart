import 'package:ctracker/models/pomodoros.dart';
import 'package:ctracker/models/status.dart';

class ActionItem {
  String? id;
  String name;
  final String description;
  Status? status;
  Pomodoro? pomodoro;
  ActionItem(
      {this.status,
      this.pomodoro,
      this.id,
      required this.name,
      required this.description});
}
