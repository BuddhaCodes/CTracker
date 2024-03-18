class Participant {
  int id;
  String name;

  Participant({required this.id, required this.name});
}

class ParticipantsData {
  static final List<Participant> _data = [
    Participant(
      id: 1,
      name: 'Julio',
    ),
    Participant(
      id: 2,
      name: 'Miguel',
    ),
    Participant(
      id: 3,
      name: 'Manuel',
    )
  ];

  static List<Participant> getAllItemType() {
    return _data;
  }
}
