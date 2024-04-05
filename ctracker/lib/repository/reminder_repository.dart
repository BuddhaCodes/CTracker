import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/status.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminder();
  Future<List<Reminder>> getByStatus(Status status);
  Future<void> addReminder(Reminder idea);
  Future<void> deleteReminder(String id);
  Future<Reminder> getById(String id);
  Future<void> updateReminder(String id, Reminder idea);
  Future<List<Reminder>> getAllRemindersOfDateToDate(DateTime fromDate,
      {DateTime? toDate, StatusEnum? status, int? take});
}
