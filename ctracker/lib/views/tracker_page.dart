import 'package:ctracker/components/circular_graph_painter.dart';
import 'package:ctracker/components/menu_item.dart';
import 'package:ctracker/components/task_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/repository/task_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/views/task_add_page.dart';
import 'package:flutter/material.dart';

class TrackerPage extends StatefulWidget {
  final Function onReminderDeleted;
  const TrackerPage({super.key, required this.onReminderDeleted});

  @override
  TrackerPageState createState() => TrackerPageState();
}

class TrackerPageState extends State<TrackerPage> {
  int _selectedIndex = 0;
  MyLocalizations? localizations;
  late List<Task> tasks;
  int selectedTile = -1;
  late TaskRepositoryImplementation taskRepo;
  late bool isInitialized = false;
  late int totalTaks = 0;
  late int completedTasks = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  Future<void> _onMenuItemClicked(int index) async {
    setState(() {
      isInitialized = false;
    });
    List<Task> fetch = [];
    setState(() {
      _selectedIndex = index;
      selectedTile = -1;
    });

    if (_selectedIndex == 0) {
      try {
        fetch = await taskRepo.getAllTasks();
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
    if (_selectedIndex == 1) {
      try {
        fetch = await taskRepo.getCompletedTask();
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
    if (_selectedIndex == 2) {
      try {
        fetch = await taskRepo.getByEffort(Effort.poco);
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
    if (_selectedIndex == 3) {
      try {
        fetch = await taskRepo.getByEffort(Effort.medio);
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
    if (_selectedIndex == 4) {
      try {
        fetch = await taskRepo.getByEffort(Effort.mucho);
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
      tasks = fetch;
      isInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    taskRepo = TaskRepositoryImplementation();
    tasks = [];
    initializeData();
  }

  void initializeData() {
    setState(() {
      isInitialized = false;
    });
    _initializeGraph().whenComplete(() =>
        _onMenuItemClicked(_selectedIndex).whenComplete(() => setState(() {
              isInitialized = true;
            })));
  }

  Future<void> _initializeGraph() async {
    totalTaks = await taskRepo.getAmountOfTask();
    completedTasks = await taskRepo.getAmountCompletedTasks();
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
                                    SizedBox(
                                      height: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            localizations?.translate('taskp') ??
                                                "",
                                            style: const TextStyle(
                                              fontSize: 36.0,
                                              color: ColorP.textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            localizations
                                                    ?.translate('taskpsub') ??
                                                "",
                                            style: const TextStyle(
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
                                    text: localizations?.translate('all') ?? "",
                                    isSelected: _selectedIndex == 0,
                                    onTap: () => _onMenuItemClicked(0),
                                  ),
                                  MenuItem(
                                    text:
                                        localizations?.translate('completed') ??
                                            "",
                                    isSelected: _selectedIndex == 1,
                                    onTap: () => _onMenuItemClicked(1),
                                  ),
                                  MenuItem(
                                    text: localizations?.translate('notmuch') ??
                                        "",
                                    isSelected: _selectedIndex == 2,
                                    onTap: () => _onMenuItemClicked(2),
                                  ),
                                  MenuItem(
                                    text: localizations?.translate('mid') ?? "",
                                    isSelected: _selectedIndex == 3,
                                    onTap: () => _onMenuItemClicked(3),
                                  ),
                                  MenuItem(
                                    text: localizations?.translate('lot') ?? "",
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
                                  child: ListView.builder(
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
                                          initializeData();
                                        },
                                      );
                                    },
                                  )),
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
    initializeData();
  }
}
