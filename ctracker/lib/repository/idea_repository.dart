// ignore: file_names
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/tags.dart';

abstract class IdeaRepository {
  Future<List<Idea>> getAllIdeas();
  Future<List<Idea>> getByTags(List<Tag> tags);
  Future<void> addIdea(Idea idea);
  Future<void> deleteIdea(String id);
  Future<void> updateIdea(String id, Idea idea);
}
