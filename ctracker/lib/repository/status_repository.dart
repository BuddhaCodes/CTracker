import 'package:ctracker/models/status.dart';

abstract class StatusRepository {
  Future<List<Status>> getAllStatus();
  Future<Status> getById(String id);
}
