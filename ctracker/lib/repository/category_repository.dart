import 'package:ctracker/models/category.dart';

abstract class CategoryRepository {
  Future<List<Categories>> getAllCategories();
}
