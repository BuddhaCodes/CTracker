import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/item_types.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/material.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  bool _sortAscendingtask = true;
  int _sortColumnIndextaks = 0;

  bool _sortAscendingrem = true;
  int _sortColumnIndexrem = 0;

  List<ItemType> types = ItemTypeData.getAllItemType();
  List<Task> tasks = TaskData.getAllTasks();
  List<Idea> ideas = IdeaData.getAllIdeas();
  List<Reminder> reminders = ReminderData.getAllReminders();

  ItemType _selectedTable = ItemTypeData.getAllItemType().first;

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
                  child: DropdownButton<ItemType>(
                    value: _selectedTable,
                    isExpanded: true,
                    dropdownColor: ColorConst.drawerBG,
                    borderRadius:
                        BorderRadius.circular(ValuesConst.borderRadius),
                    onChanged: (ItemType? newValue) {
                      setState(() {
                        _selectedTable = newValue ?? ItemType(id: -1, name: "");
                      });
                    },
                    items:
                        types.map<DropdownMenuItem<ItemType>>((ItemType value) {
                      IconData iconData;
                      Color iconColor;
                      switch (value.name) {
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
                      return DropdownMenuItem<ItemType>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(iconData, color: iconColor),
                            const SizedBox(width: 10),
                            Text(value.name,
                                style: const TextStyle(
                                    color: ColorConst.textColor)),
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
              if (_selectedTable.name == 'Ideas') _buildDataTable(ideas),
              if (_selectedTable.name == 'Reminders')
                _buildDataTableReminder(reminders),
              if (_selectedTable.name == 'Tasks') _buildDataTableTask(tasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableReminder(List<Reminder> data) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * ValuesConst.tableWidth,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.82),
            child: DataTable(
              border: TableBorder.all(
                  width: ValuesConst.tableBorderWidth,
                  color: ColorConst.chartBorderColor,
                  borderRadius: BorderRadius.circular(ValuesConst.tableRadius)),
              sortAscending: _sortAscendingrem,
              sortColumnIndex: _sortColumnIndexrem,
              columns: [
                Utils.buildColumn(Strings.title,
                    onSort: (columnIndex, ascending) => setState(() {
                          _sortAscendingrem = ascending;
                          _sortColumnIndexrem = columnIndex;
                          if (ascending) {
                            data.sort((a, b) => a.title.compareTo(b.title));
                          } else {
                            data.sort((a, b) => b.title.compareTo(a.title));
                          }
                        })),
                Utils.buildColumn(Strings.duedate),
                Utils.buildColumn(Strings.description),
                Utils.buildColumn(Strings.category),
                Utils.buildColumn(Strings.actions),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    Utils.buildCell(item.title),
                    Utils.buildCell(item.duedate.toString()),
                    Utils.buildCell(item.description),
                    Utils.buildCell(item.categories.join(', ')),
                    DataCell(Row(
                      children: [
                        Utils.updateIcon(onPressed: () {
                          // Implement update functionality
                        }),
                        Utils.deleteIcon(onPressed: () {
                          setState(() {
                            ReminderData.delete(item.id);
                            reminders = ReminderData.getAllReminders();
                          });
                        }),
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
      width: MediaQuery.of(context).size.width * ValuesConst.tableWidth,
      padding: const EdgeInsets.all(ValuesConst.tablePadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.82),
          child: DataTable(
            border: TableBorder.all(
                width: ValuesConst.tableBorderWidth,
                color: ColorConst.chartBorderColor,
                borderRadius: BorderRadius.circular(ValuesConst.tableRadius)),
            sortAscending: _sortAscendingtask,
            sortColumnIndex: _sortColumnIndextaks,
            columns: [
              Utils.buildColumn(Strings.title,
                  onSort: (columnIndex, ascending) => setState(() {
                        _sortAscendingtask = ascending;
                        _sortColumnIndextaks = columnIndex;
                        if (ascending) {
                          data.sort((a, b) => a.title.compareTo(b.title));
                        } else {
                          data.sort((a, b) => b.title.compareTo(a.title));
                        }
                      })),
              Utils.buildColumn(Strings.difficulty,
                  onSort: (columnIndex, ascending) => setState(() {
                        _sortAscendingtask = ascending;
                        _sortColumnIndextaks = columnIndex;
                        if (ascending) {
                          data.sort(
                              (a, b) => a.difficulty.compareTo(b.difficulty));
                        } else {
                          data.sort(
                              (a, b) => b.difficulty.compareTo(a.difficulty));
                        }
                      })),
              Utils.buildColumn(Strings.priority),
              Utils.buildColumn(Strings.effort),
              Utils.buildColumn(Strings.category),
              Utils.buildColumn(Strings.description),
              Utils.buildColumn(Strings.effort),
              Utils.buildColumn(Strings.actions)
            ],
            rows: data.map((item) {
              return DataRow(
                cells: [
                  Utils.buildCell(item.title),
                  Utils.buildCell(item.difficulty),
                  Utils.buildCell(item.priority),
                  Utils.buildCell(item.effort),
                  Utils.buildCell(item.categories.join(', ')),
                  Utils.buildCell(item.description),
                  Utils.buildCell(item.project),
                  DataCell(Row(
                    children: [
                      Utils.updateIcon(onPressed: () {}),
                      Utils.deleteIcon(onPressed: () {
                        setState(() {
                          TaskData.delete(item.id);
                          tasks = TaskData.getAllTasks();
                        });
                      }),
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
      width: MediaQuery.of(context).size.width * ValuesConst.tableWidth,
      padding: const EdgeInsets.all(ValuesConst.tablePadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.82),
          child: DataTable(
            sortAscending: _sortAscending,
            sortColumnIndex: _sortColumnIndex,
            border: TableBorder.all(
                width: ValuesConst.tableBorderWidth,
                color: ColorConst.chartBorderColor,
                borderRadius: BorderRadius.circular(ValuesConst.tableRadius)),
            columns: [
              Utils.buildColumn(Strings.title,
                  onSort: (columnIndex, ascending) => setState(() {
                        _sortAscending = ascending;
                        _sortColumnIndex = columnIndex;
                        if (ascending) {
                          data.sort((a, b) => a.title.compareTo(b.title));
                        } else {
                          data.sort((a, b) => b.title.compareTo(a.title));
                        }
                      })),
              Utils.buildColumn(Strings.tags,
                  onSort: (columnIndex, ascending) => setState(() {
                        _sortAscending = ascending;
                        _sortColumnIndex = columnIndex;
                        if (ascending) {
                          data.sort(
                              (a, b) => a.tags.length.compareTo(b.tags.length));
                        } else {
                          data.sort(
                              (a, b) => b.tags.length.compareTo(a.tags.length));
                        }
                      })),
              Utils.buildColumn(Strings.description),
              Utils.buildColumn(Strings.category),
              Utils.buildColumn(Strings.actions),
            ],
            rows: data.map((item) {
              return DataRow(
                cells: [
                  Utils.buildCell(item.title),
                  Utils.buildCell(item.tags.join(', ')),
                  Utils.buildCell(item.description),
                  Utils.buildCell(item.category),
                  DataCell(Row(
                    children: [
                      Utils.updateIcon(onPressed: () {}),
                      Utils.deleteIcon(onPressed: () {
                        setState(() {
                          IdeaData.delete(item.id);
                          ideas = IdeaData.getAllIdeas();
                        });
                      }),
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
