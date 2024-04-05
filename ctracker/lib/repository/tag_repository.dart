import 'package:ctracker/models/tags.dart';

abstract class TagRepository {
  Future<List<Tag>> getAllTags();
}
