import 'package:ctracker/models/graphs/jounralbymonth.dart';
import 'package:ctracker/models/graphs/journalbymood.dart';
import 'package:ctracker/models/journal.dart';

abstract class JournalRepository {
  Future<List<Journal>> getAllJournal();
  Future<JournalByMood> getAllJournalByMoodInMonth(int month);
  Future<JournalByMonth> getAllByYear(int year);
  Future<Journal> getById(String id);
  Future<void> addJournal(Journal journal);
  Future<void> deleteJournal(String id);
  Future<void> updateJournal(String id, Journal journal);
}
