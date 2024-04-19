import 'package:ctracker/repository/reminder_repository_implementation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<PocketBase>(
      () => PocketBase('http://127.0.0.1:8090'));
  locator.registerSingleton<ReminderRepositoryImplementation>(
      ReminderRepositoryImplementation());
}
