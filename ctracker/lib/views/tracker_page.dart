import 'package:ctracker/components/circular_graph_painter.dart';
import 'package:ctracker/components/menu_item.dart';
import 'package:ctracker/components/task_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/effort.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/views/task_add_page.dart';
import 'package:flutter/material.dart';

class TrackerPage extends StatefulWidget {
  final Function onReminderDeleted;
  const TrackerPage({super.key, required this.onReminderDeleted});

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  int _selectedIndex = 0;
  late List<Task> tasks;
  int selectedTile = -1;
  late bool isInitialized = false;
  late int totalTaks;
  late int completedTasks;
  void _onMenuItemClicked(int index) {
    setState(() {
      _selectedIndex = index;
      selectedTile = -1;
      if (_selectedIndex == 0) {
        tasks = TaskData.getAllTasks();
      }
      if (_selectedIndex == 1) {
        tasks = TaskData.getAllTasksCompleted();
      }
      if (_selectedIndex == 2) {
        tasks = TaskData.getAllTByEffort(Effort.poco);
      }
      if (_selectedIndex == 3) {
        tasks = TaskData.getAllTByEffort(Effort.medio);
      }
      if (_selectedIndex == 4) {
        tasks = TaskData.getAllTByEffort(Effort.mucho);
      }
    });
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isInitialized = false;
        totalTaks = TaskData.getTotalTasks();
        completedTasks = TaskData.getCompletedTotal();
        tasks = TaskData.getAllTasks();
        isInitialized = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorP.background,
      body: !isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Card(
                                color: ColorP.cardBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: Center(
                                      child: CircularGraph(
                                          totalTasks: totalTaks,
                                          completedTasks: completedTasks),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const SizedBox(
                                      height: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "My Tasks",
                                            style: TextStyle(
                                              fontSize: 36.0,
                                              color: ColorP.textColor,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            "Let's start being productive",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: ColorP.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: const BoxDecoration(
                                        color: ColorP.cardBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TaskAddPage(
                                                onTaskAdded: handleTaskAdded,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(25),
                                        child: const Icon(
                                          Icons.add,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: double.infinity,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  MenuItem(
                                    text: 'All',
                                    isSelected: _selectedIndex == 0,
                                    onTap: () => _onMenuItemClicked(0),
                                  ),
                                  MenuItem(
                                    text: 'Completed',
                                    isSelected: _selectedIndex == 1,
                                    onTap: () => _onMenuItemClicked(1),
                                  ),
                                  MenuItem(
                                    text: 'Not much effort',
                                    isSelected: _selectedIndex == 2,
                                    onTap: () => _onMenuItemClicked(2),
                                  ),
                                  MenuItem(
                                    text: 'Mid much effort',
                                    isSelected: _selectedIndex == 3,
                                    onTap: () => _onMenuItemClicked(3),
                                  ),
                                  MenuItem(
                                    text: 'A lot of  effort',
                                    isSelected: _selectedIndex == 4,
                                    onTap: () => _onMenuItemClicked(4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.98,
                              child: SizedBox(
                                height: 500,
                                child: tasks != null
                                    ? ListView.builder(
                                        itemCount: tasks.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return TaskCard(
                                            task: tasks[index],
                                            selectedTile: selectedTile,
                                            index: index,
                                            onExpanded: (int sel) {
                                              setState(() {
                                                selectedTile = sel;
                                              });
                                            },
                                            onDelete: () {
                                              widget.onReminderDeleted();
                                              _onMenuItemClicked(
                                                  _selectedIndex);
                                            },
                                          );
                                        },
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void handleTaskAdded(bool success) {
    if (success) {
      setState(() {
        isInitialized = false;
        Future.delayed(const Duration(seconds: 2), () {
          tasks = TaskData.getAllTasks();
          totalTaks = TaskData.getTotalTasks();
          completedTasks = TaskData.getCompletedTotal();
        });
        isInitialized = true;
      });
    } else {}
  }
}
