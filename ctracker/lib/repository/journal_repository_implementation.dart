import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/enums/action_type_enum.dart';
import 'package:ctracker/models/graphs/jounralbymonth.dart';
import 'package:ctracker/models/graphs/journalbymood.dart';
import 'package:ctracker/models/journal.dart';
import 'package:ctracker/repository/jounral_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

class JournalRepositoryImplementation extends JournalRepository {
  final PocketBase _pocketBase = locator<PocketBase>();

  @override
  Future<void> addJournal(Journal journal) async {
    try {
      final body = {
        "mood": journal.moodIcon,
        "content": journal.content,
        "date": journal.date.toString(),
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": ""
      };

      await _pocketBase.collection('journal').create(body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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
        "user": _pocketBase.authStore.model.id,
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
      final records = await _pocketBase.collection('journal').getFullList(
          sort: '-created',
          filter: "created_by='${_pocketBase.authStore.model.id}'");

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
        "user": _pocketBase.authStore.model.id,
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
        "created_by": _pocketBase.authStore.model.id,
        "updated_by": _pocketBase.authStore.model.id
      };

      await _pocketBase.collection('journal').update(id, body: body);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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
        "user": _pocketBase.authStore.model.id,
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

  @override
  Future<JournalByMood> getAllJournalByMoodInMonth(int month) async {
    String searchCriteria =
        "date>='${DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, month, 1))}'";

    searchCriteria +=
        " && date <= '${DateFormat('yyyy-MM-dd').format(Utils.getLastDayOfMonth(DateTime(DateTime.now().year, month, 1)))}' && created_by='${_pocketBase.authStore.model.id}'";

    try {
      final records = await _pocketBase
          .collection('journal')
          .getFullList(sort: '-created', filter: searchCriteria);

      List<Journal> journals = records.map((record) {
        return Journal(
          id: record.id,
          content: record.data["content"],
          moodIcon: record.data["mood"],
          date: DateTime.parse(record.data["date"]),
        );
      }).toList();

      return JournalByMood(
          angry: journals
              .where((element) => element.moodIcon == IconlyC.angry)
              .length,
          calm: journals
              .where((element) => element.moodIcon == IconlyC.calm)
              .length,
          coughing: journals
              .where((element) => element.moodIcon == IconlyC.coughing)
              .length,
          crying: journals
              .where((element) => element.moodIcon == IconlyC.crying)
              .length,
          happy: journals
              .where((element) => element.moodIcon == IconlyC.happy)
              .length,
          sad: journals
              .where((element) => element.moodIcon == IconlyC.sad)
              .length);
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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
  Future<JournalByMonth> getAllByYear(int year) async {
    String searchCriteria =
        "date>='${DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1))}'";

    searchCriteria +=
        " && date <= '${DateFormat('yyyy-MM-dd').format(Utils.getLastDayOfMonth(DateTime(year, 12, 1)))}' && created_by='${_pocketBase.authStore.model.id}'";

    try {
      final records = await _pocketBase
          .collection('journal')
          .getFullList(sort: '-created', filter: searchCriteria);

      List<Journal> journals = records.map((record) {
        return Journal(
          id: record.id,
          content: record.data["content"],
          moodIcon: record.data["mood"],
          date: DateTime.parse(record.data["date"]),
        );
      }).toList();
      final byMonth = JournalByMonth(
          january: journals.where((element) => element.date.month == 1).length,
          feb: journals.where((element) => element.date.month == 2).length,
          march: journals.where((element) => element.date.month == 3).length,
          april: journals.where((element) => element.date.month == 4).length,
          may: journals.where((element) => element.date.month == 5).length,
          june: journals.where((element) => element.date.month == 6).length,
          july: journals.where((element) => element.date.month == 7).length,
          agust: journals.where((element) => element.date.month == 8).length,
          september:
              journals.where((element) => element.date.month == 9).length,
          october: journals.where((element) => element.date.month == 10).length,
          november:
              journals.where((element) => element.date.month == 11).length,
          december:
              journals.where((element) => element.date.month == 12).length);
      return byMonth;
    } catch (e) {
      final body = <String, dynamic>{
        "user": _pocketBase.authStore.model.id,
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
}
