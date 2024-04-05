// ignore_for_file: non_constant_identifier_names

import 'package:ctracker/models/board.dart';

class StickyNotes {
  String? id;
  String title;
  String content;
  Board? board;
  String? created_by;
  String? updated_by;
  final DateTime? createdTime;

  StickyNotes(
      {this.id,
      required this.title,
      required this.content,
      this.board,
      this.createdTime,
      this.created_by,
      this.updated_by});
}
