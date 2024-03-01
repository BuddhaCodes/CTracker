class Difficulty {
  final int id;
  final String name;

  Difficulty({
    required this.id,
    required this.name,
  });
}

class DifficultyData {
  static final List<Difficulty> _data = [
    Difficulty(
      id: 1,
      name: 'Easy',
    ),
    Difficulty(
      id: 2,
      name: 'Medium',
    ),
    Difficulty(
      id: 3,
      name: 'Hard',
    )
  ];

  static List<Difficulty> getAllItemType() {
    return _data;
  }
}
