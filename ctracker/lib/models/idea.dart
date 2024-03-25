import 'package:ctracker/models/idea_categories.dart';
import 'package:ctracker/models/tags.dart';

class Idea {
  final int id;
  final String title;
  List<Tag> tags;
  final String description;
  final String image;
  final IdeaCategory category;

  Idea({
    required this.id,
    required this.title,
    required this.tags,
    required this.description,
    required this.image,
    required this.category,
  });
}

class IdeaData {
  static final List<Idea> _data = [
    Idea(
      id: 1,
      title: 'Task 1',
      tags: TagData.getAllItemType().take(2).toList(),
      description: '',
      image: 'feedbackImage.png',
      category: IdeaCategoryData.getAllItemType().take(1).first,
    ),
    Idea(
      id: 2,
      title: 'Task 2',
      tags: TagData.getAllItemType().take(1).toList(),
      description: '',
      image: 'helpImage.jpg',
      category: IdeaCategoryData.getAllItemType().take(1).first,
    ),
  ];

  static List<Idea> getByTags(List<Tag> tags) {
    List<Idea> filteredIdeas = [];
    for (var idea in _data) {
      // Check if all tags of the idea are contained in the provided list
      if (tags.every((tag) => idea.tags.contains(tag))) {
        filteredIdeas.add(idea);
      }
    }
    return filteredIdeas;
  }

  static void upadateIdea(Idea idea) {
    int index = _data.indexWhere((element) => element.id == idea.id);

    if (index != -1) {
      _data[index] = idea;
    } else {
      print('Reminder with ID ${idea.id} not found');
    }
  }

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
