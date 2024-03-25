import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/note.dart';
import 'package:ctracker/models/participants.dart';

class Meeting {
  final int id;
  final String title;
  List<Participant> participants;
  final String content;
  DateTime duedate;
  Duration meetingDuration;
  List<ActionItem> actions;

  Meeting({
    required this.id,
    required this.title,
    required this.participants,
    required this.content,
    required this.duedate,
    required this.meetingDuration,
    required this.actions,
  });
}

class MeetingData {
  static final List<Meeting> _data = [
    Meeting(
        id: 1,
        title: 'Meeting one',
        participants: ParticipantsData.getAllItemType().take(2).toList(),
        content: 'Description of Meeting 1',
        actions: [
          ActionItem(id: 1, title: "Do shit", [
            Note(
                id: 10,
                board: "Notes",
                content: "This is a note",
                title: "Title",
                createdTime: DateTime.now())
          ]),
          ActionItem(id: 2, title: "Do more shit", [
            Note(
                id: 11,
                board: "Notes",
                content: "This is a note",
                title: "Title",
                createdTime: DateTime.now())
          ])
        ],
        meetingDuration: const Duration(hours: 1),
        duedate: DateTime.now()),
    Meeting(
        id: 2,
        title: 'Meeting two',
        participants: ParticipantsData.getAllItemType().take(1).toList(),
        content: 'Description of Meeting 2',
        actions: [
          ActionItem(id: 1, title: "Do shit part II", [
            Note(
                id: 13,
                board: "Notes",
                content: "This is a another note",
                title: "Title",
                createdTime: DateTime.now())
          ]),
          ActionItem(id: 2, title: "Do more shit part II", [
            Note(
                id: 14,
                board: "Notes",
                content: "This is another another note",
                title: "Title",
                createdTime: DateTime.now())
          ])
        ],
        meetingDuration: const Duration(hours: 2),
        duedate: DateTime.now().add(Duration(hours: 1))),
  ];

  static List<Meeting> getAllMeetings() {
    return _data;
  }

  static List<Meeting> getAllMeetingsByMonthAndYear(int month, int year) {
    return _data
        .where((element) =>
            element.duedate.month == month && element.duedate.year == year)
        .toList();
  }

  static void update(Meeting meeting) {
    int index = _data.indexWhere((element) => element.id == meeting.id);

    // If the reminder with the given ID is found, update its properties
    if (index != -1) {
      _data[index] = meeting;
    } else {
      print('Reminder with ID ${meeting.id} not found');
    }
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }

  static Meeting getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }

  static void add(Meeting data) {
    return _data.add(data);
  }
}
