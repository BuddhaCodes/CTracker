import 'package:ctracker/components/dialog.dart';
import 'package:ctracker/components/floating_add.dart';
import 'package:ctracker/components/top_container.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/item_types.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/reminder_details.dart';
import 'package:ctracker/views/task_details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class TrackerPage extends StatefulWidget {
  final Function onReminderDeleted;
  const TrackerPage({super.key, required this.onReminderDeleted});

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  bool _sortAscendingtask = true;
  int _sortColumnIndextaks = 0;

  bool _sortAscendingrem = true;
  int _sortColumnIndexrem = 0;

  List<ItemType> types = ItemTypeData.getAllItemType();
  List<Task> tasks = TaskData.getAllTasks();
  List<Reminder> reminders = ReminderData.getAllReminders();

  ItemType _selectedTable = ItemTypeData.getAllItemType().first;
  int touchedIndex = 0;
  bool isInitialized = true;
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
                                    case 'All':
                                      iconData = Icons.apps_outlined;
                                      iconColor =
                                          Color.fromARGB(255, 63, 75, 82);
                                      break;
                                    default:
                                      iconData = Icons.error;
                                      iconColor = ColorConst.black;
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
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: ValuesConst.boxSeparatorSize,
                        width: ValuesConst.boxSeparatorSize,
                      ),
                      Visibility(
                        visible: _selectedTable.name == 'Reminders',
                        child: _buildDataTableReminder(reminders),
                      ),
                      Visibility(
                        visible: _selectedTable.name == 'Tasks',
                        child: isInitialized
                            ? _buildDataTableTask(tasks)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      Visibility(
                        visible: _selectedTable.name == 'All',
                        child: Column(
                          children: [
                            _buildDataTableReminder(reminders),
                            _buildDataTableTask(tasks),
                          ],
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
      floatingActionButton: FloatingAdd(onTaskAdded: handleTaskAdded),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void handleTaskAdded(bool success) {
    if (success) {
      setState(() {
        isInitialized = false;
        Future.delayed(const Duration(seconds: 3), () {
          tasks = TaskData.getAllTasks();
          reminders = ReminderData.getAllReminders();
        });
        isInitialized = true;
      });
    } else {}
  }

  Widget _buildDataTableReminder(List<Reminder> data) {
    final localizations = MyLocalizations.of(context);
    return Container(
      width: MediaQuery.of(context).size.width * ValuesConst.tableWidth,
      padding: const EdgeInsets.all(ValuesConst.tablePadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.82),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ValuesConst.tableRadius - 1),
            ),
            child: DataTable(
              border: TableBorder.all(
                  width: ValuesConst.tableBorderWidth,
                  color: ColorConst.borderTable,
                  borderRadius: BorderRadius.circular(ValuesConst.tableRadius)),
              sortAscending: _sortAscendingrem,
              sortColumnIndex: _sortColumnIndexrem,
              headingRowColor:
                  const MaterialStatePropertyAll(ColorConst.reminder),
              columns: [
                Utils.buildColumn(localizations.translate("title"),
                    onSort: (columnIndex, ascending) => setState(() {
                          _sortAscendingrem = ascending;
                          _sortColumnIndexrem = columnIndex;
                          if (ascending) {
                            data.sort((a, b) => a.title.compareTo(b.title));
                          } else {
                            data.sort((a, b) => b.title.compareTo(a.title));
                          }
                        })),
                Utils.buildColumn(localizations.translate("duedate")),
                Utils.buildColumn(localizations.translate("description")),
                Utils.buildColumn(localizations.translate("category")),
                Utils.buildColumn(localizations.translate("actions")),
              ],
              rows: List.generate(data.length, (index) {
                final item = data[index];
                final color =
                    index % 2 == 0 ? ColorConst.background : Colors.grey[350];
                return DataRow(
                  color: MaterialStateProperty.all(color),
                  cells: [
                    Utils.buildCell(item.title),
                    Utils.buildCell(
                        DateFormat('yyyy-MM-dd').format(item.duedate)),
                    Utils.buildCell(item.description),
                    Utils.buildCell(item.categories.join(', ')),
                    DataCell(Row(
                      children: [
                        Utils.updateIcon(onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddDialog(updateReminder: item);
                            },
                          );
                        }),
                        Utils.deleteIcon(onPressed: () {
                          setState(() {
                            ReminderData.delete(item.id);
                            widget.onReminderDeleted();
                            reminders = ReminderData.getAllReminders();
                          });
                        }),
                        Utils.detailsIcon(onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReminderDetailsPage(
                                      reminderId: item.id)));
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
    final localizations = MyLocalizations.of(context);
    return Container(
      width: MediaQuery.of(context).size.width * ValuesConst.tableWidth,
      padding: const EdgeInsets.all(ValuesConst.tablePadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.82),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ValuesConst.tableRadius - 1),
            ),
            child: DataTable(
              border: TableBorder.all(
                  width: ValuesConst.tableBorderWidth,
                  color: ColorConst.borderTable,
                  borderRadius: BorderRadius.circular(ValuesConst.tableRadius)),
              sortAscending: _sortAscendingtask,
              sortColumnIndex: _sortColumnIndextaks,
              headingRowColor: const MaterialStatePropertyAll(ColorConst.task),
              columns: [
                Utils.buildColumn(localizations.translate("titles"),
                    onSort: (columnIndex, ascending) => setState(() {
                          _sortAscendingtask = ascending;
                          _sortColumnIndextaks = columnIndex;
                          if (ascending) {
                            data.sort((a, b) => a.title.compareTo(b.title));
                          } else {
                            data.sort((a, b) => b.title.compareTo(a.title));
                          }
                        })),
                Utils.buildColumn(localizations.translate("category")),
                Utils.buildColumn(localizations.translate("description")),
                Utils.buildColumn(localizations.translate("project")),
                Utils.buildColumn(localizations.translate("status")),
                Utils.buildColumn(localizations.translate("actions"))
              ],
              rows: List.generate(data.length, (index) {
                final item = data[index];
                final color =
                    index % 2 == 0 ? ColorConst.background : Colors.grey[350];
                return DataRow(
                  color: MaterialStateProperty.all(color),
                  cells: [
                    Utils.buildCell(item.title),
                    Utils.buildCell(item.categories.join(', ')),
                    Utils.buildCell(item.description),
                    Utils.buildCell(item.project),
                    Utils.buildCell(
                        item.hasFinished ? "Terminada" : "Sin terminar"),
                    DataCell(Row(
                      children: [
                        Utils.updateIcon(onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddDialog(updateTask: item);
                            },
                          );
                        }),
                        Utils.deleteIcon(onPressed: () {
                          setState(() {
                            TaskData.delete(item.id);
                            tasks = TaskData.getAllTasks();
                          });
                        }),
                        Utils.detailsIcon(onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailsPage(taskId: item.id)));
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

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: ColorConst.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: ColorConst.reminder,
            value: 30,
            title: '75%',
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
              borderColor: ColorConst.black,
            ),
            badgePositionPercentageOffset: .98,
          );
        case 1:
          return PieChartSectionData(
            color: ColorConst.task,
            value: 10,
            title: '25%',
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
              borderColor: ColorConst.black,
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
        color: ColorConst.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorConst.black.withOpacity(.5),
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
