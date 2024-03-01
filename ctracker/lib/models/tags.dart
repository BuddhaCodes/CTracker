class Tag {
  final int id;
  final String name;

  Tag({
    required this.id,
    required this.name,
  });
}

class TagData {
  static final List<Tag> _data = [
    Tag(
      id: 1,
      name: 'Innovative',
    ),
    Tag(
      id: 2,
      name: 'House',
    ),
    Tag(
      id: 3,
      name: 'Project',
    )
  ];

  static List<Tag> getAllItemType() {
    return _data;
  }
}
