import 'package:ctracker/repository/action_item_repository_implementation.dart';
import 'package:ctracker/repository/board_repository_implementation.dart';
import 'package:ctracker/repository/category_repository_implementation.dart';
import 'package:ctracker/repository/idea_repository_implementation.dart';
import 'package:ctracker/repository/journal_repository_implementation.dart';
import 'package:ctracker/repository/meeting_repository_implementation.dart';
import 'package:ctracker/repository/pomodoro_repository_implementation.dart';
import 'package:ctracker/repository/priorities_repository_implementation.dart';
import 'package:ctracker/repository/reminder_repository_implementation.dart';
import 'package:ctracker/repository/sticky_note_repository.dart';
import 'package:ctracker/repository/sticky_note_repository_implementation.dart';
import 'package:ctracker/repository/tag_repository_implementation.dart';
import 'package:ctracker/repository/task_repository_implementation.dart';
import 'package:ctracker/utils/auth_service.dart';
import 'package:ctracker/utils/storage_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt locator = GetIt.instance;

void setupLocator() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton<PocketBase>(
      () => PocketBase('http://127.0.0.1:8090'));
  locator.registerSingleton<StorageService>(StorageService(prefs));

  // Ensure AuthService is registered after its dependencies
  locator.registerSingleton<AuthService>(
      AuthService(locator<StorageService>(), locator<PocketBase>()));

  locator.registerSingleton<ReminderRepositoryImplementation>(
      ReminderRepositoryImplementation());
  locator.registerSingleton<TaskRepositoryImplementation>(
      TaskRepositoryImplementation());
  locator.registerSingleton<TagRepositoryImplementation>(
      TagRepositoryImplementation());
  locator.registerSingleton<PrioritiesRepositoryImplementation>(
      PrioritiesRepositoryImplementation());
  locator.registerSingleton<CategoryRepositoryImplementation>(
      CategoryRepositoryImplementation());
  locator.registerSingleton<IdeaRepositoryImplementation>(
      IdeaRepositoryImplementation());
  locator.registerSingleton<StickyNoteRepositoryImplementation>(
      StickyNoteRepositoryImplementation());
  locator.registerSingleton<BoardRepositoryImplementation>(
      BoardRepositoryImplementation());
  locator.registerSingleton<PomodoroRepositoryImplementation>(
      PomodoroRepositoryImplementation());
  locator.registerSingleton<ActionItemRepositoryImplementation>(
      ActionItemRepositoryImplementation());
  locator.registerSingleton<MeetingRepositoryImplementation>(
      MeetingRepositoryImplementation());
  locator.registerSingleton<JournalRepositoryImplementation>(
      JournalRepositoryImplementation());
}
