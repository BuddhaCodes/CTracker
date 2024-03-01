class IdeaCategory {
  final int id;
  final String name;

  IdeaCategory({
    required this.id,
    required this.name,
  });
}

class IdeaCategoryData {
  static final List<IdeaCategory> _data = [
    IdeaCategory(
      id: 1,
      name: 'Category A',
    ),
    IdeaCategory(
      id: 2,
      name: 'Category B',
    ),
    IdeaCategory(
      id: 3,
      name: 'Category C',
    )
  ];

  static List<IdeaCategory> getAllItemType() {
    return _data;
  }
}
