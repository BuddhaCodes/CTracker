import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/journal.dart';
import 'package:ctracker/repository/jounral_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class JournalRepositoryImplementation extends JournalRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');

  @override
  Future<void> addJournal(Journal journal) async {
    try {
      final body = {
        "mood": journal.moodIcon,
        "content": journal.content,
        "date": journal.date.toString(),
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3"
      };

      await _pocketBase.collection('journal').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "adding a journal",
        "entity_name": "journal",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.create.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> deleteJournal(String id) async {
    try {
      await _pocketBase.collection('journal').delete(id);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "deleting a journal",
        "entity_name": "journal",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.delete.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<List<Journal>> getAllJournal() async {
    try {
      final records =
          await _pocketBase.collection('journal').getFullList(sort: '-created');

      List<Journal> journals = records.map((record) {
        return Journal(
          id: record.id,
          content: record.data["content"],
          moodIcon: record.data["mood"],
          date: DateTime.parse(record.data["date"]),
        );
      }).toList();

      return journals;
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read all journal",
        "entity_name": "journal",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<void> updateJournal(String id, Journal journal) async {
    try {
      final body = {
        "mood": journal.moodIcon,
        "content": journal.content,
        "date": journal.date.toString(),
        "created_by": "l1t6jwj73151zc3",
        "updated_by": "l1t6jwj73151zc3"
      };

      await _pocketBase.collection('journal').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "update a journal",
        "entity_name": "journal",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.update.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }

  @override
  Future<Journal> getById(String id) async {
    try {
      final record = await _pocketBase.collection('journal').getOne(id);

      return Journal(
        id: record.id,
        moodIcon: record.data["mood"],
        date: DateTime.parse(record.data["date"]),
        content: record.data["content"],
      );
    } catch (e) {
      final body = <String, dynamic>{
        "user": "l1t6jwj73151zc3",
        "description": "read a journal",
        "entity_name": "journal",
        "timestamp": DateTime.now().toString(),
        "message": e as String,
        "action_type": ActionTypeEnum.read.id
      };

      await _pocketBase.collection('logs').create(body: body);
      rethrow;
    }
  }
}
