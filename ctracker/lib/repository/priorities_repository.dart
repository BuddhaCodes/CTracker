import 'package:ctracker/models/priorities.dart';

abstract class PrioritiesRepository {
  Future<List<Priorities>> getAllPriorities();
}
