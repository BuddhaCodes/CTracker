import 'package:ctracker/components/top_container.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/item_types.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  int touchedIndex = 0;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorConst.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopContainer(
              padding: EdgeInsets.zero,
              height: 300,
              width: width,
              child: AspectRatio(
                aspectRatio: 1.3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      sections: showingSections(),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: ValuesConst.boxSeparatorSize,
                        width: ValuesConst.boxSeparatorSize,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.82,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: DropdownButton<ItemType>(
                              value: _selectedTable,
                              isExpanded: true,
                              dropdownColor: ColorConst.background,
                              borderRadius: BorderRadius.circular(
                                  ValuesConst.borderRadius),
                              onChanged: (ItemType? newValue) {
                                setState(() {
                                  _selectedTable =
                                      newValue ?? ItemType(id: -1, name: "");
                                });
                              },
                              items: types.map<DropdownMenuItem<ItemType>>(
                                  (ItemType value) {
                                IconData iconData;
                                Color iconColor;
                                switch (value.name) {
                                  case 'Ideas':
                                    iconData = Icons.lightbulb;
                                    iconColor = ColorConst.idea;
                                    break;
                                  case 'Reminders':
                                    iconData = Icons.notification_important;
                                    iconColor = ColorConst.reminder;
                                    break;
                                  case 'Tasks':
                                    iconData = Icons.assignment;
                                    iconColor = ColorConst.task;
                                    break;
                                  default:
                                    iconData = Icons.error;
                                    iconColor = Colors.black;
                                }
                                return DropdownMenuItem<ItemType>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Icon(iconData, color: iconColor),
                                      const SizedBox(width: 10),
                                      Text(value.name)
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                        width: 30,
                      ),
                      if (_selectedTable.name == 'Ideas')
                        _buildDataTable(ideas),
                      if (_selectedTable.name == 'Reminders')
                        _buildDataTableReminder(reminders),
                      if (_selectedTable.name == 'Tasks')
                        _buildDataTableTask(tasks),
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
                  color: ColorConst.borderTable,
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
                color: ColorConst.borderTable,
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
                color: ColorConst.borderTable,
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

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: ColorConst.idea,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              'assets/icons/idea.svg',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 1:
          return PieChartSectionData(
            color: ColorConst.reminder,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              'assets/icons/reminder.svg',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 2:
          return PieChartSectionData(
            color: ColorConst.task,
            value: 16,
            title: '16%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgeWidget: _Badge(
              'assets/icons/task.svg',
              size: widgetSize,
              borderColor: Colors.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.svgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
        ),
      ),
    );
  }
}
