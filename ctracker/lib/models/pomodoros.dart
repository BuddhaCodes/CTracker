// ignore_for_file: non_constant_identifier_names

class Pomodoro {
  String? id;
  DateTime? started_time;
  DateTime? end_time;
  String note;
  String? created_by;
  String? updated_by;

  Pomodoro(
      {this.id,
      this.started_time,
      this.end_time,
      required this.note,
      this.created_by,
      this.updated_by});
}
