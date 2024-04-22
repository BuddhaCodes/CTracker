import 'package:ctracker/models/enums/action_type_enum.dart';

class Log {
  String? id;
  String userId;
  String description;
  String entity_name;
  DateTime timestamp;
  String message;
  ActionTypeEnum actiontype;

  Log(
      {this.id,
      required this.userId,
      required this.description,
      required this.entity_name,
      required this.timestamp,
      required this.message,
      required this.actiontype});
}
