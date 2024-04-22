import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/tags.dart';

class Idea {
  String? id;
  String title;
  String? description;
  List<Tag> tags;
  Categories category;

  Idea(
      {this.id,
      required this.title,
      this.description,
      required this.tags,
      required this.category});
}
