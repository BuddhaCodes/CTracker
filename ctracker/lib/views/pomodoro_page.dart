import 'dart:async';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/constant/values.dart';
import 'package:flutter/material.dart';

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
  int workTime = ValuesConst.WorkingMinutes; // Default work time in minutes
  int shortRestTime =
      ValuesConst.ShortRestMinutes; // Default short rest time in minutes
  int longRestTime =
      ValuesConst.LongRestMinutes; // Default long rest time in minutes

  int remainingWorkTime =
      ValuesConst.WorkingMinutes * 60; // Initial remaining work time in seconds
  int remainingShortRestTime = ValuesConst.ShortRestMinutes *
      60; // Initial remaining short rest time in seconds
  int remainingLongRestTime = ValuesConst.LongRestMinutes *
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
    workTimer =
        Timer.periodic(const Duration(seconds: ValuesConst.Second), (timer) {
      setState(() {
        if (remainingWorkTime > 0) {
          remainingWorkTime--;
        } else {
          stopWorkTimer();
          _tabController.animateTo(1);
          workTime = ValuesConst.WorkingMinutes;
          remainingWorkTime = ValuesConst.WorkingMinutes * 60;
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
        Timer.periodic(const Duration(seconds: ValuesConst.Second), (timer) {
      setState(() {
        if (remainingShortRestTime > 0) {
          remainingShortRestTime--;
        } else {
          stopShortRestTimer();
          _tabController.animateTo(1);
          shortRestTime = ValuesConst.ShortRestMinutes;
          remainingShortRestTime = ValuesConst.ShortRestMinutes * 60;
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
        Timer.periodic(const Duration(seconds: ValuesConst.Second), (timer) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openSettingsDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: Strings.work),
            Tab(text: Strings.shortRest),
            Tab(text: Strings.longRest),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: ValuesConst.boxSeparatorSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: isWorkTimerRunning ? null : startWorkTimer,
                child: const Text(Strings.start),
              ),
              ElevatedButton(
                onPressed: isWorkTimerRunning ? stopWorkTimer : null,
                child: const Text(Strings.stop),
              ),
              ElevatedButton(
                onPressed: resetTimers,
                child: const Text(Strings.reset),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void openSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(Strings.settings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: Strings.workTimeMessage),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    workTime = int.tryParse(value) ?? workTime;
                    remainingWorkTime = workTime * 60;
                  });
                },
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: Strings.sRestTimeMessage),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    shortRestTime = int.tryParse(value) ?? shortRestTime;
                    remainingShortRestTime = shortRestTime * 60;
                  });
                },
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: Strings.lRestTimeMessage),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    longRestTime = int.tryParse(value) ?? longRestTime;
                    remainingLongRestTime = longRestTime * 60;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(Strings.close),
            ),
          ],
        );
      },
    );
  }
}
