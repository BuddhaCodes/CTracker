class Journal {
  final int id;
  String moodIcon;
  final DateTime date;
  String content;

  Journal(
      {required this.id,
      required this.moodIcon,
      required this.date,
      required this.content});
}

int counter = 1;

class JournalData {
  static final List<Journal> _data = [];

  static List<Journal> getAllJournals() {
    return _data;
  }

  static Journal? getById(int id) {
    return _data.where((element) => element.id == id).first;
  }

  static void UpdateEntry(int id, String mood, DateTime date, String content) {
    var toUpdate = _data.where((element) => element.id == id).first;
    toUpdate.content = content;
    toUpdate.moodIcon = mood;
  }

  static void AddEntry(String mood, DateTime date, String content) {
    _data.add(
        Journal(id: counter, moodIcon: mood, date: date, content: content));
    counter++;
  }

  static String getTextOfDay(DateTime date) {
    var values = _data.where((element) =>
        element.date.year == date.year &&
        element.date.month == date.month &&
        element.date.day == date.day);

    if (values.isNotEmpty) {
      return values.first.content;
    } else {
      return "";
    }
  }
}
