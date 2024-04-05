import 'package:ctracker/models/journal.dart';

abstract class JournalRepository {
  Future<List<Journal>> getAllJournal();
  Future<Journal> getById(String id);
  Future<void> addJournal(Journal journal);
  Future<void> deleteJournal(String id);
  Future<void> updateJournal(String id, Journal journal);
}
