import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/task.dart';
import 'package:flutter/material.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({Key? key}) : super(key: key);

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  String _selectedTable = 'Ideas';

  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  bool _sortAscendingtask = true;
  int _sortColumnIndextaks = 0;

  bool _sortAscendingrem = true;
  int _sortColumnIndexrem = 0;

  List<Task> tasks = TaskData.getAllTasks();
  List<Idea> ideas = IdeaData.getAllIdeas();
  List<Reminder> reminders = ReminderData.getAllReminders();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.82,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: DropdownButton<String>(
                    value: _selectedTable,
                    isExpanded: true,
                    dropdownColor: ColorConst.drawerBG,
                    borderRadius:
                        BorderRadius.circular(ValuesConst.borderRadius),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTable = newValue ?? "";
                      });
                    },
                    items: <String>['Ideas', 'Reminders', 'Tasks']
                        .map<DropdownMenuItem<String>>((String value) {
                      IconData iconData;
                      Color iconColor;
                      // Assigning icons based on the value
                      switch (value) {
                        case 'Ideas':
                          iconData = Icons.lightbulb;
                          iconColor = ColorConst.chartColorYellow;
                          break;
                        case 'Reminders':
                          iconData = Icons.notification_important;
                          iconColor = ColorConst.chartColorGreen;
                          break;
                        case 'Tasks':
                          iconData = Icons.assignment;
                          iconColor = ColorConst.chartColorBlue;
                          break;
                        default:
                          iconData = Icons.error;
                          iconColor = ColorConst.lightRed;
                      }
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(iconData, color: iconColor), // Icon
                            const SizedBox(
                                width: 10), // Adjust as needed for spacing
                            Text(value,
                                style: const TextStyle(
                                    color: ColorConst.textColor)), // Text
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
                width: 30,
              ),
              if (_selectedTable == 'Ideas') _buildDataTable(ideas),
              if (_selectedTable == 'Reminders')
                _buildDataTableReminder(reminders),
              if (_selectedTable == 'Tasks') _buildDataTableTask(tasks),
            ],
          ),
        ),
      ),
    );
  }

  DataCell buildCell(String item) {
    return DataCell(
        Text(item, style: const TextStyle(color: ColorConst.textColor)));
  }

  DataColumn buildColumn(String item) {
    return DataColumn(
      label: Text(item, style: const TextStyle(color: ColorConst.textColor)),
    );
  }

  Widget _buildDataTableReminder(List<Reminder> data) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.82),
            child: DataTable(
              border: TableBorder.all(
                  width: 1,
                  color: ColorConst.chartBorderColor,
                  borderRadius: BorderRadius.circular(20)),
              sortAscending: _sortAscendingrem,
              sortColumnIndex: _sortColumnIndexrem,
              columns: [
                DataColumn(
                  label: const Text('Title',
                      style: TextStyle(color: ColorConst.textColor)),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortAscendingrem = ascending;
                      _sortColumnIndexrem = columnIndex;
                      if (ascending) {
                        data.sort((a, b) => a.title.compareTo(b.title));
                      } else {
                        data.sort((a, b) => b.title.compareTo(a.title));
                      }
                    });
                  },
                ),
                buildColumn('Due date'),
                buildColumn('Description'),
                buildColumn('Category'),
                buildColumn('Actions'),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    buildCell(item.title),
                    buildCell(item.duedate.toString()),
                    buildCell(item.description),
                    buildCell(item.categories.join(', ')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: ColorConst.sendButtonColor),
                          onPressed: () {
                            // Implement update functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: ColorConst.lightRed),
                          onPressed: () {
                            setState(() {
                              ReminderData.delete(item.id);
                              reminders = ReminderData.getAllReminders();
                            });
                          },
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableTask(List<Task> data) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.82),
          child: DataTable(
            border: TableBorder.all(
                width: 1,
                color: ColorConst.chartBorderColor,
                borderRadius: BorderRadius.circular(20)),
            sortAscending: _sortAscendingtask,
            sortColumnIndex: _sortColumnIndextaks,
            columns: [
              DataColumn(
                label: const Text('Title',
                    style: TextStyle(color: ColorConst.textColor)),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortAscendingtask = ascending;
                    _sortColumnIndextaks = columnIndex;
                    if (ascending) {
                      data.sort((a, b) => a.title.compareTo(b.title));
                    } else {
                      data.sort((a, b) => b.title.compareTo(a.title));
                    }
                  });
                },
              ),
              DataColumn(
                label: const Text('Difficulty',
                    style: TextStyle(color: ColorConst.textColor)),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortAscendingtask = ascending;
                    _sortColumnIndextaks = columnIndex;
                    if (ascending) {
                      data.sort((a, b) => a.difficulty.compareTo(b.difficulty));
                    } else {
                      data.sort((a, b) => b.difficulty.compareTo(a.difficulty));
                    }
                  });
                },
              ),
              buildColumn('Priority'),
              buildColumn('Effort'),
              buildColumn('Category'),
              buildColumn('Description'),
              buildColumn('Project'),
              buildColumn('Actions')
            ],
            rows: data.map((item) {
              return DataRow(
                cells: [
                  buildCell(item.title),
                  buildCell(item.difficulty),
                  buildCell(item.priority),
                  buildCell(item.effort),
                  buildCell(item.categories.join(', ')),
                  buildCell(item.description),
                  buildCell(item.project),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: ColorConst.sendButtonColor),
                        onPressed: () {
                          //
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: ColorConst.lightRed),
                        onPressed: () {
                          setState(() {
                            TaskData.delete(item.id);
                            tasks = TaskData.getAllTasks();
                          });
                        },
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Idea> data) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.82),
          child: DataTable(
            sortAscending: _sortAscending,
            sortColumnIndex: _sortColumnIndex,
            border: TableBorder.all(
                width: 1,
                color: ColorConst.chartBorderColor,
                borderRadius: BorderRadius.circular(20)),
            columns: [
              DataColumn(
                label: const Text('Title',
                    style: TextStyle(color: ColorConst.textColor)),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortAscending = ascending;
                    _sortColumnIndex = columnIndex;
                    if (ascending) {
                      data.sort((a, b) => a.title.compareTo(b.title));
                    } else {
                      data.sort((a, b) => b.title.compareTo(a.title));
                    }
                  });
                },
              ),
              DataColumn(
                label: const Text('Tags',
                    style: TextStyle(color: ColorConst.textColor)),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortAscending = ascending;
                    _sortColumnIndex = columnIndex;
                    if (ascending) {
                      data.sort(
                          (a, b) => a.tags.length.compareTo(b.tags.length));
                    } else {
                      data.sort(
                          (a, b) => b.tags.length.compareTo(a.tags.length));
                    }
                  });
                },
              ),
              buildColumn('Description'),
              buildColumn('Category'),
              buildColumn('Actions'),
            ],
            rows: data.map((item) {
              return DataRow(
                cells: [
                  buildCell(item.title),
                  buildCell(item.tags.join(', ')),
                  buildCell(item.description),
                  buildCell(item.category),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: ColorConst.sendButtonColor),
                        onPressed: () {
                          // Implement update functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: ColorConst.lightRed),
                        onPressed: () {
                          setState(() {
                            IdeaData.delete(item.id);
                            ideas = IdeaData.getAllIdeas();
                          });
                        },
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
