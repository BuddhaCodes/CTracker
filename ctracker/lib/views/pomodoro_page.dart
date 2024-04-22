import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/repository/pomodoro_repository_implementation.dart';
import 'package:ctracker/repository/task_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  PomodoroScreenState createState() => PomodoroScreenState();
}

class PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  late TaskRepositoryImplementation taskRepo;
  late PomodoroRepositoryImplementation pomoRepo;
  late int workTime;
  late int shortRestTime;
  late int longRestTime;
  MyLocalizations? localizations;
  late Task _taskProject;
  late List<Task> _taskProjects;

  late int remainingWorkTime;
  late int remainingShortRestTime;
  late int remainingLongRestTime;

  late DateTime startTime;
  late QuillController _controller;
  bool shouldUpdateElapsedTime = false;
  bool isWorkTimerRunning = false;
  bool isShortRestTimerRunning = false;
  bool isLongRestTimerRunning = false;

  Timer? workTimer;
  Timer? shortRestTimer;
  Timer? longRestTimer;

  bool _isInitialized = false;

  late TabController _tabController;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  void initializeData() async {
    setState(() {
      _isInitialized = false;
    });
    workTime = ValuesConst.workingMinutes;
    shortRestTime = ValuesConst.shortRestMinutes;
    longRestTime = ValuesConst.longRestMinutes;
    _controller = QuillController.basic();
    taskRepo = TaskRepositoryImplementation();
    pomoRepo = PomodoroRepositoryImplementation();
    List<Task> fetch = [];
    fetch = await taskRepo.getNoCompletedTask();
    setState(() {
      _taskProjects = fetch;
      if (_taskProjects.isNotEmpty) {
        _taskProject = _taskProjects.first;

        if (_taskProject.pomodoro != null &&
            _taskProject.pomodoro!.note.isNotEmpty) {
          Document doc =
              Document.fromJson(jsonDecode(_taskProject.pomodoro!.note));
          _controller.document = doc;
        }
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
    });

    setState(() {
      _isInitialized = true;
    });
  }

  bool isTimerRunning() {
    return isWorkTimerRunning ||
        isShortRestTimerRunning ||
        isLongRestTimerRunning;
  }

  void startWorkTimer() async {
    setState(() {
      isWorkTimerRunning = true;
      shouldUpdateElapsedTime = true;
      startTime = DateTime.now();
    });

    if (_taskProject.pomodoro != null &&
        _taskProject.pomodoro?.started_time == null) {
      _taskProject.pomodoro?.started_time = DateTime.now();
      try {
        await pomoRepo.updatePomodoro(
            _taskProject.pomodoro?.id ?? "", _taskProject.pomodoro!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(localizations?.translate("error") ?? "",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255)))),
          );
        }
      }
    }

    workTimer =
        Timer.periodic(Duration(seconds: ValuesConst.second), (timer) async {
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

  void stopWorkTimer() async {
    if (_taskProject.pomodoro != null &&
        _taskProject.pomodoro?.end_time == null) {
      _taskProject.pomodoro?.end_time = DateTime.now();
      try {
        await pomoRepo.updatePomodoro(
            _taskProject.pomodoro?.id ?? "", _taskProject.pomodoro!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(localizations?.translate("error") ?? "",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255)))),
          );
        }
      }
    }
    setState(() {
      if (shouldUpdateElapsedTime) {
        Duration elapsedTime = DateTime.now().difference(startTime);
        _taskProject.timeSpend += elapsedTime;
        try {
          taskRepo.updateTask(_taskProject.id!, _taskProject);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(localizations?.translate("error") ?? "",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)))),
            );
          }
        }
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
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: ColorP.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_taskProjects.isEmpty) {
      return Scaffold(
        backgroundColor: ColorP.background,
        body: Center(
          child: Text(
            localizations?.translate("noTask") ?? "",
            style: const TextStyle(color: ColorP.textColor, fontSize: 34),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorP.background,
      appBar: AppBar(
        backgroundColor: ColorP.background,
        bottom: TabBar(
          labelColor: ColorP.textColor,
          indicatorColor: ColorP.ColorB,
          unselectedLabelColor: ColorP.textColor,
          controller: _tabController,
          tabs: [
            Tab(
              text: localizations?.translate("work") ?? "",
              icon: SvgPicture.asset(
                IconlyC.work,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorP.textColor, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: localizations?.translate("shortRest") ?? "",
              icon: SvgPicture.asset(
                IconlyC.shortRest,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorP.textColor, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: localizations?.translate("longRest") ?? "",
              icon: SvgPicture.asset(
                IconlyC.longRest,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorP.textColor, BlendMode.srcIn),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
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
                      "${localizations?.translate("timeDedicated") ?? ""} ${_taskProject.timeSpend.toString().split('.').first.padLeft(8, "0")}",
                      style: const TextStyle(
                        fontSize: 24,
                        color: ColorP.textColor,
                      ),
                    ),
                    Text(
                      _taskProject.effort.longname,
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
                  width: MediaQuery.of(context).size.width - 135,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: ColorP.cardBackground,
                    ),
                    child: DropdownButtonFormField(
                      value: _taskProject,
                      borderRadius: BorderRadius.circular(20.0),
                      iconEnabledColor: ColorP.textColor,
                      onChanged: isTimerRunning()
                          ? null
                          : (newValue) {
                              setState(() {
                                _taskProject = newValue as Task;
                                _controller.clear();
                                if (_taskProject.pomodoro?.note != null) {
                                  Document doc = Document.fromJson(jsonDecode(
                                      _taskProject.pomodoro?.note ?? ""));
                                  _controller.document = doc;
                                }
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
                                color: ColorP.textColor,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      decoration: InputDecoration(
                        labelText:
                            localizations?.translate("taskHintTitle") ?? "",
                        border: const OutlineInputBorder(),
                        iconColor: ColorP.textColor,
                        labelStyle: const TextStyle(color: ColorP.textColor),
                        filled: true,
                        fillColor: ColorP.cardBackground,
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      _taskProject.status = Status(
                          id: StatusEnum.done.id, name: StatusEnum.done.name);
                      try {
                        taskRepo
                            .updateTask(_taskProject.id ?? "", _taskProject)
                            .whenComplete(() => initializeData());
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    localizations?.translate("error") ?? "",
                                    style: const TextStyle(
                                        color: Color.fromARGB(
                                            255, 255, 255, 255)))),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorP.ColorD,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            ValuesConst.buttonBorderRadius / 2),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      localizations?.translate("ended") ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorP.textColor,
                      ),
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
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Stack(
                      children: [
                        Card.filled(
                          elevation: 2,
                          color: ColorP.cardBackground,
                          child: SizedBox(
                            height: 300,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: QuillToolbar.simple(
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
                                      controller: _controller,
                                      showLink: true,
                                      showSearchButton: false,
                                      showCodeBlock: false,
                                      showInlineCode: false,
                                      showAlignmentButtons: false,
                                      showIndent: false,
                                      showSubscript: false,
                                      showSuperscript: false,
                                      showQuote: false,
                                      showStrikeThrough: false,
                                      showUnderLineButton: true,
                                      showClearFormat: false,
                                      color: ColorP.textColor,
                                      sharedConfigurations:
                                          const QuillSharedConfigurations(
                                        locale: Locale('en'),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                                SizedBox(
                                  height: 200,
                                  child: QuillEditor.basic(
                                    configurations: QuillEditorConfigurations(
                                      controller: _controller,
                                      readOnly: false,
                                      minHeight: 200,
                                      padding: const EdgeInsets.all(20),
                                      sharedConfigurations:
                                          const QuillSharedConfigurations(
                                        locale: Locale('en'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                            onPressed: () {
                              String content = jsonEncode(
                                  _controller.document.toDelta().toJson());
                              _taskProject.pomodoro?.note = content;
                              try {
                                pomoRepo.updatePomodoro(
                                    _taskProject.pomodoro?.id ?? "",
                                    _taskProject.pomodoro!);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            localizations?.translate("error") ??
                                                "",
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                  );
                                }
                              }
                            },
                            shape: const CircleBorder(),
                            tooltip: localizations?.translate("add") ?? "",
                            hoverColor: ColorP.ColorD.withOpacity(0.8),
                            backgroundColor: ColorP.ColorD,
                            child: const Icon(
                              Icons.save_outlined,
                              color: ColorP.white,
                            ),
                          ),
                        ),
                      ],
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
                    backgroundColor: ColorP.ColorD,
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
                    localizations?.translate("start") ?? "",
                    style: TextStyle(
                        fontSize: ValuesConst.buttonFontSize,
                        color: ColorP.textColor),
                  )),
              ElevatedButton(
                onPressed: (isWorkTimerRunning && _taskProjects.isNotEmpty)
                    ? stopWorkTimer
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorP.ColorD,
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
                  localizations?.translate("stop") ?? "",
                  style: TextStyle(
                      fontSize: ValuesConst.buttonFontSize,
                      color: ColorP.textColor),
                ),
              ),
              ElevatedButton(
                onPressed: _taskProjects.isNotEmpty ? resetTimers : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorP.ColorD,
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
                  localizations?.translate("reset") ?? "",
                  style: TextStyle(
                      fontSize: ValuesConst.buttonFontSize,
                      color: ColorP.textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
