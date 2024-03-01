class ItemType {
  final int id;
  final String name;

  ItemType({
    required this.id,
    required this.name,
  });
}

class ItemTypeData {
  static final List<ItemType> _data = [
    ItemType(
      id: 1,
      name: 'Ideas',
    ),
    ItemType(
      id: 2,
      name: 'Reminders',
    ),
    ItemType(
      id: 3,
      name: 'Tasks',
    )
  ];

  static List<ItemType> getAllItemType() {
    return _data;
  }
}
