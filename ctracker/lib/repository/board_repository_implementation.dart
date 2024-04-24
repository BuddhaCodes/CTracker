import 'package:ctracker/models/board.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/sticky_notes.dart';
import 'package:ctracker/repository/board_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

class BoardRepositoryImplementation extends BoardRepository {
  final PocketBase _pocketBase = locator<PocketBase>();

  @override
  Future<Board> addBoards(Board board) async {
    try {
      final body = {
        "title": board.title,
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": ""
      };
      final response =
          await _pocketBase.collection('boards').create(body: body);
      return Board(id: response.id, title: response.data["title"]);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "adding a board",
        "entity_name": "boards",
        "timestamp": DateTime.now().toString(),
        "message": e.toString(),
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteBoard(String id) async {
    try {
      await _pocketBase.collection('boards').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "delete a board",
        "entity_name": "boards",
        "timestamp": DateTime.now().toString(),
        "message": e.toString(),
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Board>> getAllBoards() async {
    try {
      final records = await _pocketBase.collection('boards').getFullList(
          sort: '-created',
          filter: "created_by='${_pocketBase.authStore.model.id}'",
          expand: 'notes');

      List<Board> boards = records.map((record) {
        List<StickyNotes> notes =
            (record.expand["notes"] as List<dynamic>?)?.map((noteData) {
                  return StickyNotes(
                    id: noteData.id,
                    createdTime: DateTime.parse(noteData.data["created_time"]),
                    content: noteData.data["content"],
                    title: noteData.data["title"],
                  );
                }).toList() ??
                [];

        return Board(
          id: record.id,
          title: record.data["title"],
          notes: notes,
        );
      }).toList();

      return boards;
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "get all boards",
        "entity_name": "boards",
        "timestamp": DateTime.now().toString(),
        "message": e.toString(),
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateBoard(String id, Board board) async {
    try {
      final body = {
        "title": board.title,
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": _pocketBase.authStore.model.id
      };

      await _pocketBase.collection('boards').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
        "description": "update a board",
        "entity_name": "boards",
        "timestamp": DateTime.now().toString(),
        "message": e.toString(),
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
