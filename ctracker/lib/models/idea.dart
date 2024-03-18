class Idea {
  final int id;
  final String title;
  List<String> tags;
  final String description;
  final List<String> images;
  final String category;

  Idea({
    required this.id,
    required this.title,
    required this.tags,
    required this.description,
    required this.images,
    required this.category,
  });
}

class IdeaData {
  static final List<Idea> _data = [
    Idea(
      id: 1,
      title: 'Task 1',
      tags: ['Tag A', 'Tag C'],
      description: 'Description of Task 1',
      images: ['feedbackImage.png', 'helpImage.jpg'],
      category: 'Category A',
    ),
    Idea(
      id: 2,
      title: 'Task 2',
      tags: ['Tag B'],
      description: 'Description of Task 2',
      images: ['feedbackImage.png', 'helpImage.jpg'],
      category: 'Category B',
    ),
  ];

  static List<Idea> getAllIdeas() {
    return _data;
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }

  static Idea getById(int id) {
    return _data.firstWhere((element) => element.id == id);
  }

  static void addIdea(Idea idea) {
    _data.add(idea);
  }
}
