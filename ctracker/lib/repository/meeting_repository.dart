import 'package:ctracker/models/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getAllMeetings();
  Future<void> addMeeting(Meeting meeting);
  Future<void> deleteMeeting(String id);
  Future<Meeting> getById(String id);
  Future<void> updateMeeting(String id, Meeting meeting);
  Future<List<Meeting>> getByYearAndMonth(int year, int month);
}
