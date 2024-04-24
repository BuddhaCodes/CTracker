// ignore_for_file: non_constant_identifier_names

import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/participants.dart';

class Meeting {
  String? id;
  final String title;
  List<Participant> participants;
  final String content;
  DateTime start_date;
  DateTime end_date;
  List<ActionItem> actions;

  Meeting({
    this.id,
    required this.title,
    required this.participants,
    required this.content,
    required this.start_date,
    required this.end_date,
    required this.actions,
  });
}
