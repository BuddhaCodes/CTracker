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
      name: 'Reminders',
    ),
    ItemType(
      id: 2,
      name: 'Tasks',
    ),
    ItemType(id: 3, name: 'All')
  ];

  static List<ItemType> getAllItemType() {
    return _data;
  }

  static ItemType getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }
}
