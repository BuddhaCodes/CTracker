import 'dart:async';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ctracker/components/note_board.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PomodoroScreen();
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  late int workTime;
  late int shortRestTime;
  late int longRestTime;

  late Task _taskProject;
  late List<Task> _taskProjects;

  late int remainingWorkTime;
  late int remainingShortRestTime;
  late int remainingLongRestTime;

  late DateTime startTime;

  bool shouldUpdateElapsedTime = false;
  bool isWorkTimerRunning = false;
  bool isShortRestTimerRunning = false;
  bool isLongRestTimerRunning = false;

  Timer? workTimer;
  Timer? shortRestTimer;
  Timer? longRestTimer;

  bool _isInitialized = false;

  final AppFlowyBoardController controller = AppFlowyBoardController();

  late TabController _tabController;
  late AppFlowyBoardScrollController boardController;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    workTime = ValuesConst.workingMinutes;
    shortRestTime = ValuesConst.shortRestMinutes;
    longRestTime = ValuesConst.longRestMinutes;

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _taskProjects = TaskData.getAllTasks()
            .where((element) => element.hasFinished == false)
            .toList();
        ;
        if (_taskProjects.isNotEmpty) {
          _taskProject = _taskProjects.first;
          initializeAppFlowyBoard();
        }
        remainingWorkTime = workTime * 60;
        remainingShortRestTime = shortRestTime * 60;
        remainingLongRestTime = longRestTime * 60;
        startTime = DateTime.now();
        _tabController = TabController(
          length: 3,
          vsync: this,
          animationDuration: Duration.zero,
        );
        _isInitialized = true;
      });
    });
  }

  void initializeAppFlowyBoard() {
    Map<String, List<TextItem>> groupedNotes = {};

    for (var note in _taskProject.note) {
      groupedNotes.putIfAbsent(note.board, () => []);
      groupedNotes[note.board]!.add(TextItem(
        note.title,
        note.content,
        DateFormat('yyyy-MM-dd').format(note.createdTime),
      ));
    }

    List<AppFlowyGroupData> groups = groupedNotes.entries.map((entry) {
      return AppFlowyGroupData(
        id: entry.key,
        name: entry.key,
        items: entry.value,
      );
    }).toList();

    boardController = AppFlowyBoardScrollController();

    for (var board in groups) {
      controller.addGroup(board);
    }
  }

  bool isTimerRunning() {
    return isWorkTimerRunning ||
        isShortRestTimerRunning ||
        isLongRestTimerRunning;
  }

  void startWorkTimer() {
    setState(() {
      isWorkTimerRunning = true;
      shouldUpdateElapsedTime = true;
      startTime = DateTime.now();
    });
    workTimer = Timer.periodic(Duration(seconds: ValuesConst.second), (timer) {
      setState(() {
        if (remainingWorkTime > 0) {
          remainingWorkTime--;
        } else {
          stopWorkTimer();

          player.play(AssetSource("timer_end.wav"));

          _tabController.animateTo(1);
          workTime = ValuesConst.workingMinutes;
          remainingWorkTime = ValuesConst.workingMinutes * 60;
        }
      });
    });
  }

  void stopWorkTimer() {
    setState(() {
      if (shouldUpdateElapsedTime) {
        Duration elapsedTime = DateTime.now().difference(startTime);
        _taskProject.timeSpend += elapsedTime;
        shouldUpdateElapsedTime = false;
      }
      isWorkTimerRunning = false;
      workTimer?.cancel();
    });
  }

  void startShortRestTimer() {
    setState(() {
      isShortRestTimerRunning = true;
    });
    shortRestTimer =
        Timer.periodic(Duration(seconds: ValuesConst.second), (timer) {
      setState(() {
        if (remainingShortRestTime > 0) {
          remainingShortRestTime--;
        } else {
          stopShortRestTimer();
          player.play(AssetSource("timer_end.wav"));
          _tabController.animateTo(1);
          shortRestTime = ValuesConst.shortRestMinutes;
          remainingShortRestTime = ValuesConst.shortRestMinutes * 60;
        }
      });
    });
  }

  void stopShortRestTimer() {
    setState(() {
      isShortRestTimerRunning = false;
      shortRestTimer?.cancel();
    });
  }

  void startLongRestTimer() {
    setState(() {
      isLongRestTimerRunning = true;
    });
    longRestTimer =
        Timer.periodic(Duration(seconds: ValuesConst.second), (timer) {
      setState(() {
        if (remainingLongRestTime > 0) {
          remainingLongRestTime--;
        } else {
          stopLongRestTimer();
          player.play(AssetSource("timer_end.wav"));
          _tabController.animateTo(0);
          startWorkTimer();
        }
      });
    });
  }

  void stopLongRestTimer() {
    setState(() {
      isLongRestTimerRunning = false;
      longRestTimer?.cancel();
    });
  }

  void resetTimers() {
    setState(() {
      remainingWorkTime = workTime * 60;
      remainingShortRestTime = shortRestTime * 60;
      remainingLongRestTime = longRestTime * 60;
      stopWorkTimer();
      stopShortRestTimer();
      stopLongRestTimer();
    });
  }

  @override
  void dispose() {
    workTimer?.cancel();
    shortRestTimer?.cancel();
    longRestTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_taskProjects.isEmpty) {
      return Center(
        child: Text(
          localizations.translate("noTask"),
          style: const TextStyle(color: ColorConst.textColor, fontSize: 34),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: localizations.translate("work"),
              icon: SvgPicture.asset(
                IconlyC.work,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorConst.black, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: localizations.translate("shortRest"),
              icon: SvgPicture.asset(
                IconlyC.shortRest,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorConst.black, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: localizations.translate("longRest"),
              icon: SvgPicture.asset(
                IconlyC.longRest,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorConst.black, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return buildScrollableLayout();
        },
      ),
    );
  }

  Widget buildScrollableLayout() {
    final localizations = MyLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Wrap(
                  alignment: constraints.maxWidth < 500
                      ? WrapAlignment.center
                      : WrapAlignment.spaceEvenly,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    Text(
                      "${localizations.translate("timeDedicated")} ${_taskProject.timeSpend.toString().split('.').first.padLeft(8, "0")}",
                      style: const TextStyle(
                        fontSize: 24,
                        color: ColorConst.textColor,
                      ),
                    ),
                    Text(
                      _taskProject.effort,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildTimer(remainingWorkTime),
                      buildTimer(remainingShortRestTime),
                      buildTimer(remainingLongRestTime),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 400,
                  child: DropdownButtonFormField(
                    value: _taskProject,
                    onChanged: isTimerRunning()
                        ? null
                        : (newValue) {
                            setState(() {
                              _taskProject = newValue as Task;
                              controller.clear();
                              initializeAppFlowyBoard();
                              resetTimers();
                            });
                          },
                    items: _taskProjects.map<DropdownMenuItem<Task>>(
                      (Task value) {
                        return DropdownMenuItem<Task>(
                          value: value,
                          child: Text(
                            value.title,
                            style: const TextStyle(
                              color: ColorConst.textColor,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(
                      labelText: localizations.translate("taskHintTitle"),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _taskProject.hasFinished = true;
                      controller.clear();
                      _taskProjects = TaskData.getAllTasks()
                          .where((element) => element.hasFinished == false)
                          .toList();
                      if (_taskProjects.isNotEmpty) {
                        _taskProject = _taskProjects.first;
                      }
                      initializeAppFlowyBoard();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.buttonColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ValuesConst.buttonBorderRadius / 2),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    localizations.translate("ended"),
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConst.contrastedTextColor,
                    ),
                  ),
                ),
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 20 * 2),
          if (_taskProjects.isNotEmpty)
            Center(
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Card.filled(
                      elevation: 2,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: SizedBox(
                        height: ValuesConst.noteBoardContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: NoteBoard(
                            task: _taskProject,
                            controller: controller,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      onPressed: _taskProjects.isEmpty
                          ? null
                          : () {
                              String title = '';
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText: localizations
                                                  .translate("title")),
                                          onChanged: (value) {
                                            title = value;
                                          },
                                        ),
                                        const SizedBox(
                                            height:
                                                ValuesConst.boxSeparatorSize),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (title.isNotEmpty) {
                                              final group = AppFlowyGroupData(
                                                  id: title,
                                                  name: title,
                                                  items: []);
                                              setState(() {
                                                controller.addGroup(group);
                                                Navigator.pop(context);
                                              });
                                            }
                                          },
                                          child: Text(
                                              localizations.translate("add")),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                      shape: const CircleBorder(),
                      tooltip: localizations.translate("add"),
                      hoverColor: ColorConst.buttonColor,
                      backgroundColor: ColorConst.buttonHoverColor,
                      child: const Icon(
                        Icons.add,
                        color: ColorConst.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildTimer(int remainingTime) {
    final localizations = MyLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: ValuesConst.boxSeparatorSize,
            height: ValuesConst.boxSeparatorSize,
          ),
          Text(
            '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: ValuesConst.timerFontSize),
          ),
          const SizedBox(height: ValuesConst.boxSeparatorSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: (isWorkTimerRunning || !_taskProjects.isNotEmpty)
                      ? null
                      : startWorkTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.buttonColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: ValuesConst.pomodoroButtonPaddingH,
                        vertical: ValuesConst.pomodoroButtonPaddingV),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ValuesConst.buttonBorderRadius),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    localizations.translate("start"),
                    style: TextStyle(
                        fontSize: ValuesConst.buttonFontSize,
                        color: ColorConst.contrastedTextColor),
                  )),
              ElevatedButton(
                onPressed: (isWorkTimerRunning && _taskProjects.isNotEmpty)
                    ? stopWorkTimer
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConst.buttonColor,
                  padding: EdgeInsets.symmetric(
                      horizontal: ValuesConst.pomodoroButtonPaddingH,
                      vertical: ValuesConst.pomodoroButtonPaddingV),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ValuesConst.buttonBorderRadius),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  localizations.translate("stop"),
                  style: TextStyle(
                      fontSize: ValuesConst.buttonFontSize,
                      color: ColorConst.contrastedTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: _taskProjects.isNotEmpty ? resetTimers : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConst.buttonColor,
                  padding: EdgeInsets.symmetric(
                      horizontal: ValuesConst.pomodoroButtonPaddingH,
                      vertical: ValuesConst.pomodoroButtonPaddingV),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ValuesConst.buttonBorderRadius),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  localizations.translate("reset"),
                  style: TextStyle(
                      fontSize: ValuesConst.buttonFontSize,
                      color: ColorConst.contrastedTextColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
