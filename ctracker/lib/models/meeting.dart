import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/note.dart';

class Meeting {
  final int id;
  final String title;
  List<String> participants;
  final String content;
  List<ActionItem> actions;

  Meeting({
    required this.id,
    required this.title,
    required this.participants,
    required this.content,
    required this.actions,
  });
}

class MeetingData {
  static final List<Meeting> _data = [
    Meeting(
        id: 1,
        title: 'Meeting one',
        participants: ['Julio', 'Miguel'],
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
        ]),
    Meeting(
        id: 2,
        title: 'Meeting two',
        participants: ['Julio'],
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
        ]),
  ];

  static List<Meeting> getAllMeetings() {
    return _data;
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
