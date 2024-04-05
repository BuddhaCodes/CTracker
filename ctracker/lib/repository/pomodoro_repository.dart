import 'package:ctracker/models/pomodoros.dart';

abstract class PomodoroRepository {
  Future<List<Pomodoro>> getAllPomodoros();
  Future<void> addPomodoro(Pomodoro pomodoro);
  Future<void> updatePomodoro(String id, Pomodoro pomodoro);
  Future<Pomodoro> getPomodoro(String id);
}
