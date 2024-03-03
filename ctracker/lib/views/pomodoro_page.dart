import 'dart:async';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/constant/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PomodoroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PomodoroScreen();
  }
}

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  int workTime = ValuesConst.workingMinutes; // Default work time in minutes
  int shortRestTime =
      ValuesConst.shortRestMinutes; // Default short rest time in minutes
  int longRestTime =
      ValuesConst.longRestMinutes; // Default long rest time in minutes

  int remainingWorkTime =
      ValuesConst.workingMinutes * 60; // Initial remaining work time in seconds
  int remainingShortRestTime = ValuesConst.shortRestMinutes *
      60; // Initial remaining short rest time in seconds
  int remainingLongRestTime = ValuesConst.longRestMinutes *
      60; // Initial remaining long rest time in seconds

  bool isWorkTimerRunning = false;
  bool isShortRestTimerRunning = false;
  bool isLongRestTimerRunning = false;

  Timer? workTimer;
  Timer? shortRestTimer;
  Timer? longRestTimer;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void startWorkTimer() {
    setState(() {
      isWorkTimerRunning = true;
    });
    workTimer = Timer.periodic(Duration(seconds: ValuesConst.second), (timer) {
      setState(() {
        if (remainingWorkTime > 0) {
          remainingWorkTime--;
        } else {
          stopWorkTimer();
          _tabController.animateTo(1);
          workTime = ValuesConst.workingMinutes;
          remainingWorkTime = ValuesConst.workingMinutes * 60;
        }
      });
    });
  }

  void stopWorkTimer() {
    setState(() {
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
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: Strings.work,
              icon: SvgPicture.asset(
                'assets/icons/work.svg',
                width: 36, // Adjust the size as needed
                height: 36,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: Strings.shortRest,
              icon: SvgPicture.asset(
                'assets/icons/rest.svg',
                width: 36, // Adjust the size as needed
                height: 36,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
            Tab(
              text: Strings.longRest,
              icon: SvgPicture.asset(
                'assets/icons/longrest.svg',
                width: 36, // Adjust the size as needed
                height: 36,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTimer(remainingWorkTime),
          buildTimer(remainingShortRestTime),
          buildTimer(remainingLongRestTime),
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
            width: ValuesConst.boxSeparatorSize * 4,
            height: ValuesConst.boxSeparatorSize * 4,
          ),
          Text(
            '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 140),
          ),
          const SizedBox(height: ValuesConst.boxSeparatorSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: isWorkTimerRunning ? null : startWorkTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 45, vertical: 20), // button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // rounded corners
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    Strings.start,
                    style: TextStyle(
                        fontSize: 24, color: ColorConst.contrastedTextColor),
                  )),
              ElevatedButton(
                onPressed: isWorkTimerRunning ? stopWorkTimer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 45, vertical: 20), // button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // rounded corners
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  Strings.stop,
                  style: TextStyle(
                      fontSize: 24, color: ColorConst.contrastedTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: resetTimers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 45, vertical: 20), // button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // rounded corners
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  Strings.reset,
                  style: TextStyle(
                      fontSize: 24, color: ColorConst.contrastedTextColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
