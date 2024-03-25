import 'dart:async';

import 'package:appflowy_board/appflowy_board.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ctracker/components/note_board.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class MeetingDetailsPage extends StatefulWidget {
  final int meetingId;

  const MeetingDetailsPage({Key? key, required this.meetingId})
      : super(key: key);

  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage>
    with SingleTickerProviderStateMixin {
  late int workTime;
  late int shortRestTime;
  late int longRestTime;

  ActionItem _actionItem =
      ActionItem([], id: -1, title: "", hasFinished: false);
  late List<ActionItem> _actionItems;

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

  final AppFlowyBoardController controller = AppFlowyBoardController();

  late TabController _tabController;
  late AppFlowyBoardScrollController boardController;

  final player = AudioPlayer();

  late Meeting _meeting;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    workTime = ValuesConst.workingMinutes;
    shortRestTime = ValuesConst.shortRestMinutes;
    longRestTime = ValuesConst.longRestMinutes;

    Future.delayed(const Duration(seconds: 2), () {
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
        _meeting = MeetingData.getById(widget.meetingId);

        _actionItems = _meeting.actions
            .where((element) => element.hasFinished == false)
            .toList();
        if (_actionItems.isNotEmpty) {
          _actionItem = _actionItems.first;
        }

        initializeAppFlowyBoard();
        isInitialized = true;
      });
    });
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
        //Duration elapsedTime = DateTime.now().difference(startTime);
        // _taskProject.timeSpend += elapsedTime;
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
    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                    const ColorFilter.mode(ColorP.ColorC, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: localizations.translate("shortRest"),
              icon: SvgPicture.asset(
                IconlyC.shortRest,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorP.ColorC, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: localizations.translate("longRest"),
              icon: SvgPicture.asset(
                IconlyC.longRest,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorP.ColorC, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
      body: _actionItems.isEmpty
          ? buildNoTaskContent(context, localizations)
          : buildTripleColumnLayout(context, localizations),
    );
  }

  Widget buildNoTaskContent(
      BuildContext context, MyLocalizations localizations) {
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
                  const Text(
                    'Description:',
                    style: TextStyle(
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
            localizations.translate("noTask"),
            style: const TextStyle(color: ColorP.textColor, fontSize: 34),
          ),
        ),
      ],
    );
  }

  Widget buildTripleColumnLayout(
      BuildContext context, MyLocalizations localizations) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const Text(
                      'Description:',
                      style: TextStyle(
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
          SizedBox(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildTimer(localizations, remainingWorkTime),
                      buildTimer(localizations, remainingShortRestTime),
                      buildTimer(localizations, remainingLongRestTime),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          buildTaskDropdown(context, localizations),
          const Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 20 * 2),
          buildNoteBoard(context),
        ],
      ),
    );
  }

  Widget buildTaskDropdown(
      BuildContext context, MyLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 400,
            child: DropdownButtonFormField(
              value: _actionItem,
              onChanged: isTimerRunning()
                  ? null
                  : (newValue) {
                      setState(() {
                        _actionItem = newValue as ActionItem;
                        controller.clear();
                        initializeAppFlowyBoard();
                        resetTimers();
                      });
                    },
              items: _actionItems
                  .map<DropdownMenuItem<ActionItem>>((ActionItem value) {
                return DropdownMenuItem<ActionItem>(
                  value: value,
                  child: Text(value.title,
                      style: const TextStyle(color: ColorP.textColor)),
                );
              }).toList(),
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
                _actionItem.hasFinished = true;
                controller.clear();
                _actionItems = _meeting.actions
                    .where((element) => element.hasFinished == false)
                    .toList();
                if (_actionItems.isNotEmpty) {
                  _actionItem = _actionItems.first;
                }
                initializeAppFlowyBoard();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorP.buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ValuesConst.buttonBorderRadius / 2),
              ),
              elevation: 5,
            ),
            child: Text(
              localizations.translate("ended"),
              style: const TextStyle(
                fontSize: 14,
                color: ColorP.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildNoteBoard(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return Center(
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
                    task: _actionItem,
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
              onPressed: () {
                String title = '';
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextField(
                            style: const TextStyle(color: ColorP.ColorC),
                            decoration: InputDecoration(
                                labelStyle: TextStyle(color: ColorP.ColorC),
                                labelText: localizations.translate("title")),
                            onChanged: (value) {
                              title = value;
                            },
                          ),
                          const SizedBox(height: ValuesConst.boxSeparatorSize),
                          ElevatedButton(
                            onPressed: () {
                              if (title.isNotEmpty) {
                                final group = AppFlowyGroupData(
                                    id: title, name: title, items: []);
                                setState(() {
                                  controller.addGroup(group);
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: Text(localizations.translate("add")),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              shape: const CircleBorder(),
              tooltip: localizations.translate("add"),
              hoverColor: ColorP.buttonColor,
              backgroundColor: ColorP.buttonHoverColor,
              child: const Icon(
                Icons.add,
                color: ColorP.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimer(MyLocalizations localizations, int remainingTime) {
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
                  onPressed: isWorkTimerRunning ? null : startWorkTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorP.buttonColor,
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
                        color: ColorP.white),
                  )),
              ElevatedButton(
                onPressed: isWorkTimerRunning ? stopWorkTimer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorP.buttonColor,
                  padding: EdgeInsets.symmetric(
                      horizontal: ValuesConst.pomodoroButtonPaddingH,
                      vertical:
                          ValuesConst.pomodoroButtonPaddingV), // button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ValuesConst.buttonBorderRadius), // rounded corners
                  ),
                  elevation: 5,
                ),
                child: Text(
                  localizations.translate("stop"),
                  style: TextStyle(
                      fontSize: ValuesConst.buttonFontSize,
                      color: ColorP.white),
                ),
              ),
              ElevatedButton(
                onPressed: resetTimers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorP.buttonColor,
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
                      color: ColorP.textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void initializeAppFlowyBoard() {
    List<TextItem> groupedNotes = [];

    for (var note in _actionItem.note) {
      groupedNotes.add(TextItem(
        note.title,
        note.content,
        DateFormat('yyyy-MM-dd').format(note.createdTime),
      ));
    }

    AppFlowyGroupData group = AppFlowyGroupData(
      id: "Notes",
      name: "Notes",
      items: groupedNotes,
    );

    boardController = AppFlowyBoardScrollController();

    controller.addGroup(group);
  }
}
