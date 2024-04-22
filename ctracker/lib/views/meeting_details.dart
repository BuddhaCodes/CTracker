import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/repository/action_item_repository_implementation.dart';
import 'package:ctracker/repository/meeting_repository_implementation.dart';
import 'package:ctracker/repository/pomodoro_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';

class MeetingDetailsPage extends StatefulWidget {
  final String meetingId;

  const MeetingDetailsPage({super.key, required this.meetingId});

  @override
  MeetingDetailsPageState createState() => MeetingDetailsPageState();
}

class MeetingDetailsPageState extends State<MeetingDetailsPage>
    with SingleTickerProviderStateMixin {
  late MeetingRepositoryImplementation meetingRepo;
  late PomodoroRepositoryImplementation pomoRepo;
  late ActionItemRepositoryImplementation actionRepo;
  late int workTime;
  late int shortRestTime;
  late int longRestTime;
  late QuillController _controller;
  late ActionItem _actionItem;
  late List<ActionItem> _actionItems;
  MyLocalizations? localizations;
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

  late TabController _tabController;

  final player = AudioPlayer();

  late Meeting _meeting;
  bool isInitialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    meetingRepo = MeetingRepositoryImplementation();
    pomoRepo = PomodoroRepositoryImplementation();
    actionRepo = ActionItemRepositoryImplementation();
    workTime = ValuesConst.workingMinutes;
    shortRestTime = ValuesConst.shortRestMinutes;
    longRestTime = ValuesConst.longRestMinutes;
    _controller = QuillController.basic();
    Meeting? fetch;
    try {
      fetch = await meetingRepo.getById(widget.meetingId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
        Navigator.pop(context);
      }
    }

    setState(() {
      remainingWorkTime = workTime * 60;
      remainingShortRestTime = shortRestTime * 60;
      remainingLongRestTime = longRestTime * 60;
      startTime = DateTime.now();

      _tabController = TabController(
        length: 3,
        vsync: this,
        animationDuration: Duration.zero,
      );
      if (fetch != null) {
        _meeting = fetch;
      } else {
        Navigator.pop(context);
      }
      _actionItems = _meeting.actions;
      if (_actionItems.isNotEmpty) {
        _actionItem = _actionItems.first;
        if (_actionItem.pomodoro?.note != null &&
            _actionItem.pomodoro!.note.isNotEmpty) {
          Document doc =
              Document.fromJson(jsonDecode(_actionItem.pomodoro?.note ?? ""));
          _controller.document = doc;
        }
      }
      isInitialized = true;
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

    if (_actionItem.pomodoro != null &&
        _actionItem.pomodoro?.started_time == null) {
      _actionItem.pomodoro?.started_time = DateTime.now();
      try {
        await pomoRepo.updatePomodoro(
            _actionItem.pomodoro?.id ?? "", _actionItem.pomodoro!);
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

  void stopWorkTimer() async {
    if (_actionItem.pomodoro != null &&
        _actionItem.pomodoro?.end_time == null) {
      _actionItem.pomodoro?.end_time = DateTime.now();
      try {
        await pomoRepo.updatePomodoro(
            _actionItem.pomodoro?.id ?? "", _actionItem.pomodoro!);
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
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: ColorP.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorP.background,
      appBar: AppBar(
        backgroundColor: ColorP.background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ColorP.textColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
      body: _actionItems.isEmpty
          ? buildNoTaskContent(context)
          : buildTripleColumnLayout(context),
    );
  }

  Widget buildNoTaskContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _meeting.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ColorP.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.category,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _meeting.participants.join(", "),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations?.translate('description') ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _meeting.content,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Center(
          child: Text(
            localizations?.translate("noTask") ?? "",
            style: const TextStyle(color: ColorP.textColor, fontSize: 34),
          ),
        ),
      ],
    );
  }

  Widget buildTripleColumnLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
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
                      value: _actionItem,
                      borderRadius: BorderRadius.circular(20.0),
                      iconEnabledColor: ColorP.textColor,
                      onChanged: isTimerRunning()
                          ? null
                          : (newValue) {
                              setState(() {
                                _actionItem = newValue as ActionItem;
                                _controller.clear();
                                if (_actionItem.pomodoro?.note != null) {
                                  Document doc = Document.fromJson(jsonDecode(
                                      _actionItem.pomodoro?.note ?? ""));
                                  _controller.document = doc;
                                }
                                resetTimers();
                              });
                            },
                      items: _actionItems.map<DropdownMenuItem<ActionItem>>(
                        (ActionItem value) {
                          return DropdownMenuItem<ActionItem>(
                            value: value,
                            child: Text(
                              value.name,
                              style: TextStyle(
                                color:
                                    _actionItem.status?.id == StatusEnum.done.id
                                        ? ColorP.buttonColor
                                        : ColorP.textColor,
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
                      if (_actionItem.status?.id == StatusEnum.notDone.id) {
                        setState(() {
                          _actionItem.status = Status(
                              id: StatusEnum.done.id,
                              name: StatusEnum.done.name);

                          try {
                            actionRepo
                                .updateActionItem(_actionItem)
                                .whenComplete(() => initializeData());
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      localizations?.translate("error") ?? "",
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)))),
                            );
                          }

                          if (_actionItems.isNotEmpty) {
                            _actionItem = _actionItems.first;
                          }
                        });
                      } else {
                        null;
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
          if (_actionItems.isNotEmpty)
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
                            onPressed: () async {
                              String content = jsonEncode(
                                  _controller.document.toDelta().toJson());
                              _actionItem.pomodoro?.note = content;
                              try {
                                await pomoRepo.updatePomodoro(
                                    _actionItem.pomodoro?.id ?? "",
                                    _actionItem.pomodoro!);
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
                  onPressed: (isWorkTimerRunning ||
                          _actionItem.status?.id == StatusEnum.done.id)
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
                onPressed: isWorkTimerRunning ? stopWorkTimer : null,
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
                onPressed: resetTimers,
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
