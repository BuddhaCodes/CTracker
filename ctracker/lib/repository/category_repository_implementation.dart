import 'package:ctracker/models/category.dart';
import 'package:ctracker/repository/category_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class CategoryRepositoryImplementation implements CategoryRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');

  @override
  Future<List<Categories>> getAllCategories() async {
    final records = await _pocketBase.collection('categories').getFullList(
          sort: '-created',
        );
    return records
        .map((e) => Categories(
            id: e.id, name: e.data["name"], description: e.data["description"]))
        .toList();
  }
}
