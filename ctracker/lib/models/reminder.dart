// ignore_for_file: non_constant_identifier_names

import 'package:ctracker/models/repeat_types.dart';
import 'package:ctracker/models/status.dart';
class Reminder {
  String? id;
  final String title;
  final DateTime duedate;
  RepeatType type;
  Status? status;
  String? updated_by;
  String? created_by;

  Reminder({
    this.id,
    required this.title,
    required this.duedate,
    required this.type,
    this.created_by,
    this.updated_by,
    this.status,
  });
}
