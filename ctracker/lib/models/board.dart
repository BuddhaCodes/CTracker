import 'package:ctracker/models/sticky_notes.dart';

class Board {
  String? id;
  String title;
  List<StickyNotes>? notes;
  Board({this.id, required this.title, this.notes});
}
