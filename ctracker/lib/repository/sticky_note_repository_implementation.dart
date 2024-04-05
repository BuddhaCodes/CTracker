import 'package:ctracker/models/board.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/sticky_notes.dart';
import 'package:ctracker/repository/sticky_note_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class StickyNoteRepositoryImplementation extends StickyNoteRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');

  @override
  Future<StickyNotes> addStickyNote(StickyNotes note) async {
    try {
      final body = {
        "title": note.title,
        "content": note.content,
        "created_time": DateTime.now().toString(),
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3",
        "board": note.board?.id
      };
      final createdNote =
          await _pocketBase.collection('sticky_notes').create(body: body);

      final boardRecord = await _pocketBase
          .collection('boards')
          .getOne(createdNote.data["board"]);
      final notes = List<String>.from(boardRecord.data["notes"] ?? []);
      notes.add(createdNote.id);

      final boardBody = {
        "title": boardRecord.data["title"],
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3",
        "notes": notes
      };
      await _pocketBase
          .collection("boards")
          .update(createdNote.data["board"], body: boardBody);

      return StickyNotes(
        id: createdNote.id,
        content: createdNote.data["content"],
        title: createdNote.data["title"],
        createdTime: DateTime.parse(createdNote.data["created_time"]),
        board: Board(id: createdNote.data["board"], title: ""),
      );
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "add a sticky_notes",
        "entity_name": "sticky_notes",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteStickyNote(String id) async {
    try {
      await _pocketBase.collection('sticky_notes').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "delete a sticky_notes",
        "entity_name": "sticky_notes",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<StickyNotes>> getAllStickyNotes() async {
    try {
      final records = await _pocketBase
          .collection('sticky_notes')
          .getFullList(sort: '-created', expand: 'board');

      return records.map((record) => _mapToStickyNotes(record)).toList();
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all sticky_notes",
        "entity_name": "sticky_notes",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateStickyNote(String id, StickyNotes note) async {
    try {
      final body = {
        "title": note.title,
        "content": note.content,
        "created_time": note.createdTime.toString(),
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3",
        "board": note.board?.id
      };
      await _pocketBase.collection('sticky_notes').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "update a sticky_notes",
        "entity_name": "sticky_notes",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  StickyNotes _mapToStickyNotes(RecordModel record) {
    return StickyNotes(
      id: record.id,
      title: record.data["title"],
      content: record.data["content"],
      createdTime: DateTime.parse(record.data["created_time"]),
      board: Board(id: record.data["board"], title: ""),
    );
  }
}
