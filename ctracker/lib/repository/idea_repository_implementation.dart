import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/enums/tags_enum.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/repository/idea_repository.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:pocketbase/pocketbase.dart';

class IdeaRepositoryImplementation implements IdeaRepository {
  final PocketBase _pocketBase = locator<PocketBase>();
  @override
  Future<List<Idea>> getAllIdeas() async {
    final records = await _pocketBase.collection('ideas').getFullList(
        sort: '-created',
        filter: "created_by='${_pocketBase.authStore.model.id}'",
        expand: 'tag,category');

    List<Idea> ideas = records
        .map((e) => Idea(
              id: e.id,
              title: e.data["title"],
              description: e.data["description"],
              tags: e.expand["tag"]
                      ?.map((t) => Tag(
                            id: t.id,
                            title: t.data["title"],
                          ))
                      .toList() ??
                  [],
              category: e.expand["category"]!
                  .map((t) => Categories(
                        id: t.id,
                        name: t.data["name"],
                        description: t.data["description"],
                      ))
                  .toList()
                  .first,
            ))
        .toList();
    return ideas;
  }

  @override
  Future<List<Idea>> getByTags(List<Tag> tags) async {
    String searchCriteria = "created_by='${_pocketBase.authStore.model.id}'";

    for (int i = 0; i < tags.length; i++) {
      searchCriteria += "&& tag~'${tags[i].id}'";
    }

    final records = await _pocketBase.collection('ideas').getFullList(
        sort: '-created',
        expand: 'tag,category',
        filter: searchCriteria.isNotEmpty ? "($searchCriteria)" : "");

    List<Idea> ideas = records
        .map((e) => Idea(
              id: e.id,
              title: e.data["title"],
              description: e.data["description"],
              tags: e.expand["tag"]
                      ?.map((t) => Tag(
                            id: t.id,
                            title: t.data["title"],
                          ))
                      .toList() ??
                  [],
              category: e.expand["category"]!
                  .map((t) => Categories(
                        id: t.id,
                        name: t.data["name"],
                        description: t.data["description"],
                      ))
                  .toList()
                  .first,
            ))
        .toList();
    return ideas;
  }

  @override
  Future<void> addIdea(Idea idea) async {
    final body = <String, dynamic>{
      "title": idea.title,
      "description": idea.description,
      "tag": idea.tags.map((e) => e.id).toList(),
      "category": idea.category.id,
      "created_by": _pocketBase.authStore.model.id,
      "updated_by": ""
    };

    await _pocketBase.collection('ideas').create(body: body);
  }

  @override
  Future<void> deleteIdea(String id) async {
    final records = await _pocketBase
        .collection('tasks')
        .getFullList(sort: '-created', filter: "project='$id'");
    for (var record in records) {
      // await taskRepo.deleteTask(record.id);
      final recordss = await _pocketBase.collection('tasks').getOne(record.id,
          expand:
              'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category');
      await _pocketBase
          .collection('reminder')
          .delete(recordss.expand["reminder"]!.first.id);

      await _pocketBase
          .collection('pomodoros')
          .delete(recordss.expand["pomodoro"]!.first.id);

      // await _pocketBase.collection('tasks').delete(id);
    }

    await _pocketBase.collection('ideas').delete(id);
  }

  @override
  Future<void> updateIdea(String id, Idea idea) async {
    final body = <String, dynamic>{
      "title": idea.title,
      "description": idea.description,
      "tag": idea.tags.map((e) => e.id).toList(),
      "category": idea.category.id,
      "created_by": _pocketBase.authStore.model.id,
      "updated_by": _pocketBase.authStore.model.id
    };
    if (idea.tags
        .where((element) => element.id == TagsEnum.project.id)
        .isEmpty) {
      final records = await _pocketBase
          .collection('tasks')
          .getFullList(sort: '-created', filter: "project='$id'");
      for (var record in records) {
        // await taskRepo.deleteTask(record.id);
        final recordss = await _pocketBase.collection('tasks').getOne(record.id,
            expand:
                'difficulty,status,priority,effort,project,category,reminder,pomodoro,reminder.status,reminder.frequency,project.tag,project.category');
        await _pocketBase
            .collection('reminder')
            .delete(recordss.expand["reminder"]!.first.id);

        await _pocketBase
            .collection('pomodoros')
            .delete(recordss.expand["pomodoro"]!.first.id);
      }
    }
    await _pocketBase.collection('ideas').update(id, body: body);
  }
}
