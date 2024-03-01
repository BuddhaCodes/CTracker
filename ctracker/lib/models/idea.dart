class Idea {
  final int id;
  final String title;
  final List<String> tags;
  final String description;
  final List<String> images;
  final String notes;
  final String category;

  Idea({
    required this.id,
    required this.title,
    required this.tags,
    required this.description,
    required this.images,
    required this.notes,
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
      images: ['image1.jpg', 'image2.jpg'],
      notes: 'Notes for Task 1',
      category: 'Category A',
    ),
    Idea(
      id: 2,
      title: 'Task 2',
      tags: ['Tag B'],
      description: 'Description of Task 2',
      images: ['image3.jpg'],
      notes: 'Notes for Task 2',
      category: 'Category B',
    ),
    // Add more data as needed
  ];

  static List<Idea> getAllIdeas() {
    return _data;
  }

  static void delete(int id) {
    _data.removeWhere((element) => element.id == id);
  }
}
