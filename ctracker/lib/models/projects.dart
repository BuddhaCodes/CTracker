class Projects {
  final int id;
  final String name;

  Projects({
    required this.id,
    required this.name,
  });
}

class ProjectsData {
  static final List<Projects> _data = [
    Projects(
      id: 1,
      name: 'Projects A',
    ),
    Projects(
      id: 2,
      name: 'Projects B',
    ),
    Projects(
      id: 3,
      name: 'Projects C',
    )
  ];

  static List<Projects> getAllItemType() {
    return _data;
  }
}
