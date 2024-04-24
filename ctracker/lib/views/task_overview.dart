import 'package:ctracker/components/legend.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/enums/month_enum.dart';
import 'package:ctracker/models/graphs/bar_data.dart';
import 'package:ctracker/models/graphs/defficulty_resume.dart';
import 'package:ctracker/models/graphs/effort_resume.dart';
import 'package:ctracker/models/graphs/spend_time_task.dart';
import 'package:ctracker/repository/task_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TaskOverview extends StatefulWidget {
  const TaskOverview({super.key});

  @override
  TaskOverviewState createState() => TaskOverviewState();
}

class TaskOverviewState extends State<TaskOverview> {
  MyLocalizations? localizations;
  late TaskRepositoryImplementation taskRepo;
  bool isInit = false;
  int _selectedYear = DateTime.now().year;
  int _selectedYear2 = DateTime.now().year;
  int _selectedYear3 = DateTime.now().year;
  final aColor = ColorP.contentColorPurple;
  final bColor = ColorP.contentColorCyan;
  final cColor = ColorP.contentColorBlue;
  final betweenSpace = 0.2;
  late List<BarData> dataList;
  late List<FlSpot> allSpots;
  late List<BarChartGroupData> dataDifficulty = [];
  late List<BarChartGroupData> dataEffort = [];
  late List<LineChartBarData> lineBarsData;
  List<int> showingTooltipOnSpots = [DateTime.now().month - 1];
  BarChartGroupData generateGroupData(
    int x,
    double hard,
    double mid,
    double easy,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: hard,
          color: aColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: hard + betweenSpace,
          toY: hard + betweenSpace + mid,
          color: bColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: hard + betweenSpace + mid + betweenSpace,
          toY: hard + betweenSpace + mid + betweenSpace + easy,
          color: cColor,
          width: 5,
        ),
      ],
    );
  }

  late LineChartBarData tooltipsOnBar;
  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = MonthEnum.january.name;
        break;
      case 1:
        text = MonthEnum.february.name;
        break;
      case 2:
        text = MonthEnum.march.name;
        break;
      case 3:
        text = MonthEnum.april.name;
        break;
      case 4:
        text = MonthEnum.may.name;
        break;
      case 5:
        text = MonthEnum.june.name;
        break;
      case 6:
        text = MonthEnum.july.name;
        break;
      case 7:
        text = MonthEnum.august.name;
        break;
      case 8:
        text = MonthEnum.september.name;
        break;
      case 9:
        text = MonthEnum.october.name;
        break;
      case 10:
        text = MonthEnum.november.name;
        break;
      case 11:
        text = MonthEnum.december.name;
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MyLocalizations.of(context);
  }

  @override
  void initState() {
    super.initState();

    initializeData();
  }

  Future<void> initializeData() async {
    taskRepo = locator<TaskRepositoryImplementation>();
    await initializeDifficulty(DateTime.now().year);
    await initializeByEffort(DateTime.now().year);
    await initializeBySpendTime(DateTime.now().year);
    setState(() {
      isInit = true;
    });
  }

  Future<void> initializeDifficulty(int year) async {
    late List<DifficultyResume> fetch = [];
    try {
      fetch = await taskRepo.getAmountByMonthAndDifficulty(year);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );

        for (var i = 0; i < 12; i++) {
          fetch.add(DifficultyResume(month: i, easy: 0, medium: 0, hard: 0));
        }
      }
    }

    setState(() {
      dataDifficulty.clear();
      for (var element in fetch) {
        dataDifficulty.add(generateGroupData(
            element.month,
            element.hard.toDouble(),
            element.medium.toDouble(),
            element.easy.toDouble()));
      }
    });
  }

  Future<void> initializeByEffort(int year) async {
    late List<EffortResume> fetch = [];
    try {
      fetch = await taskRepo.getAmountByMonthAndEffort(year);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );

        for (var i = 0; i < 12; i++) {
          fetch.add(EffortResume(month: i, poco: 0, medio: 0, mucho: 0));
        }
      }
    }

    setState(() {
      dataEffort.clear();
      for (var element in fetch) {
        dataEffort.add(generateGroupData(
            element.month,
            element.mucho.toDouble(),
            element.medio.toDouble(),
            element.poco.toDouble()));
      }
    });
  }

  Future<void> initializeBySpendTime(int year) async {
    late SpendTimeTask fetchMonth;
    try {
      fetchMonth = await taskRepo.getAllDurationByMonth(year);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
        fetchMonth = SpendTimeTask(
            january: 0,
            feb: 0,
            march: 0,
            april: 0,
            may: 0,
            june: 0,
            july: 0,
            august: 0,
            september: 0,
            october: 0,
            november: 0,
            december: 0);
      }
    }

    setState(() {
      allSpots = [];
      allSpots.add(FlSpot(0, fetchMonth.january.toDouble()));
      allSpots.add(FlSpot(1, fetchMonth.feb.toDouble()));
      allSpots.add(FlSpot(2, fetchMonth.march.toDouble()));
      allSpots.add(FlSpot(3, fetchMonth.april.toDouble()));
      allSpots.add(FlSpot(4, fetchMonth.may.toDouble()));
      allSpots.add(FlSpot(5, fetchMonth.june.toDouble()));
      allSpots.add(FlSpot(6, fetchMonth.july.toDouble()));
      allSpots.add(FlSpot(7, fetchMonth.august.toDouble()));
      allSpots.add(FlSpot(8, fetchMonth.september.toDouble()));
      allSpots.add(FlSpot(9, fetchMonth.october.toDouble()));
      allSpots.add(FlSpot(10, fetchMonth.november.toDouble()));
      allSpots.add(FlSpot(11, fetchMonth.december.toDouble()));
    });

    lineBarsData = [
      LineChartBarData(
        showingIndicators: [],
        spots: allSpots,
        isCurved: true,
        barWidth: 4,
        shadow: const Shadow(
          blurRadius: 8,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              ColorP.contentColorBlue.withOpacity(0.4),
              ColorP.contentColorPink.withOpacity(0.4),
              ColorP.contentColorRed.withOpacity(0.4),
            ],
          ),
        ),
        preventCurveOverShooting: true,
        dotData: const FlDotData(show: false),
        gradient: const LinearGradient(
          colors: [
            ColorP.contentColorBlue,
            ColorP.contentColorPink,
            ColorP.contentColorRed,
          ],
          stops: [0.1, 0.4, 0.9],
        ),
      ),
    ];

    tooltipsOnBar = lineBarsData[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorP.background,
      body: !isInit
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 650,
                        child: Card(
                          elevation: 2,
                          color: ColorP.cardBackground,
                          child: SizedBox(
                            height: 450,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations
                                            ?.translate('numoftaskbydiff') ??
                                        "",
                                    style: const TextStyle(
                                      color: ColorP.contentColorBlue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LegendsListWidget(
                                    legends: [
                                      Legend('Hard', aColor),
                                      Legend('Medium', bColor),
                                      Legend('Easy', cColor),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: SizedBox(
                                      height: 400,
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceBetween,
                                          titlesData: FlTitlesData(
                                            leftTitles: const AxisTitles(),
                                            rightTitles: const AxisTitles(),
                                            topTitles: const AxisTitles(),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: bottomTitles,
                                                reservedSize: 50,
                                              ),
                                            ),
                                          ),
                                          barTouchData:
                                              BarTouchData(enabled: false),
                                          borderData: FlBorderData(show: false),
                                          gridData:
                                              const FlGridData(show: false),
                                          barGroups: dataDifficulty,
                                          maxY: 11 + (betweenSpace * 3),
                                          extraLinesData: ExtraLinesData(
                                            horizontalLines: [
                                              HorizontalLine(
                                                y: 3.3,
                                                color: aColor,
                                                strokeWidth: 1,
                                                dashArray: [20, 4],
                                              ),
                                              HorizontalLine(
                                                y: 8,
                                                color: bColor,
                                                strokeWidth: 1,
                                                dashArray: [20, 4],
                                              ),
                                              HorizontalLine(
                                                y: 11,
                                                color: cColor,
                                                strokeWidth: 1,
                                                dashArray: [20, 4],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: ColorP.cardBackground,
                                      ),
                                      child: DropdownButtonFormField(
                                        value: _selectedYear,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        onChanged: (newValue) async {
                                          setState(() {
                                            _selectedYear =
                                                newValue ?? DateTime.now().year;
                                            lineBarsData = [];
                                          });
                                          await initializeDifficulty(
                                              _selectedYear);
                                        },
                                        items: Utils
                                            .buildYearDropdownItems(), // Call a method to build the list of year dropdown items
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                          ),
                                          filled: true,
                                          iconColor: ColorP.textColor,
                                          fillColor: ColorP.background,
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null) {
                                            return localizations
                                                    ?.translate("yearSelect") ??
                                                ""; // Adjust error message for year
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 670,
                        child: Card(
                          elevation: 2,
                          color: ColorP.cardBackground,
                          child: SizedBox(
                            height: 450,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations
                                            ?.translate('numoftaskbyeffort') ??
                                        "",
                                    style: const TextStyle(
                                      color: ColorP.contentColorBlue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LegendsListWidget(
                                    legends: [
                                      Legend(Effort.mucho.longname, aColor),
                                      Legend(Effort.medio.longname, bColor),
                                      Legend(Effort.poco.longname, cColor),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: SizedBox(
                                      height: 400,
                                      child: BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceBetween,
                                          titlesData: FlTitlesData(
                                            leftTitles: const AxisTitles(),
                                            rightTitles: const AxisTitles(),
                                            topTitles: const AxisTitles(),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: bottomTitles,
                                                reservedSize: 50,
                                              ),
                                            ),
                                          ),
                                          barTouchData:
                                              BarTouchData(enabled: false),
                                          borderData: FlBorderData(show: false),
                                          gridData:
                                              const FlGridData(show: false),
                                          barGroups: dataEffort,
                                          maxY: 11 + (betweenSpace * 3),
                                          extraLinesData: ExtraLinesData(
                                            horizontalLines: [
                                              HorizontalLine(
                                                y: 3.3,
                                                color: aColor,
                                                strokeWidth: 1,
                                                dashArray: [20, 4],
                                              ),
                                              HorizontalLine(
                                                y: 8,
                                                color: bColor,
                                                strokeWidth: 1,
                                                dashArray: [20, 4],
                                              ),
                                              HorizontalLine(
                                                y: 11,
                                                color: cColor,
                                                strokeWidth: 1,
                                                dashArray: [20, 4],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: ColorP.cardBackground,
                                      ),
                                      child: DropdownButtonFormField(
                                        value: _selectedYear2,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        onChanged: (newValue) async {
                                          setState(() {
                                            _selectedYear2 =
                                                newValue ?? DateTime.now().year;
                                            lineBarsData = [];
                                          });
                                          await initializeByEffort(
                                              _selectedYear2);
                                        },
                                        items: Utils
                                            .buildYearDropdownItems(), // Call a method to build the list of year dropdown items
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                          ),
                                          filled: true,
                                          iconColor: ColorP.textColor,
                                          fillColor: ColorP.background,
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null) {
                                            return localizations
                                                    ?.translate("yearSelect") ??
                                                ""; // Adjust error message for year
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 650,
                        child: Card(
                          elevation: 2,
                          color: ColorP.cardBackground,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    // localizations?.translate(
                                    //         'frecuencyofentriesinjournal') ??
                                    //     "",
                                    localizations
                                            ?.translate('timespendmonth') ??
                                        "",
                                    style: const TextStyle(
                                      color: ColorP.contentColorBlue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: SizedBox(
                                  height: 400,
                                  child: LineChart(LineChartData(
                                    showingTooltipIndicators:
                                        showingTooltipOnSpots.map((index) {
                                      return ShowingTooltipIndicators([
                                        LineBarSpot(
                                          tooltipsOnBar,
                                          lineBarsData.indexOf(tooltipsOnBar),
                                          tooltipsOnBar.spots[index],
                                        ),
                                      ]);
                                    }).toList(),
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      handleBuiltInTouches: false,
                                      touchCallback: (FlTouchEvent event,
                                          LineTouchResponse? response) {
                                        if (response == null ||
                                            response.lineBarSpots == null) {
                                          return;
                                        }
                                        if (event is FlTapUpEvent) {
                                          final spotIndex = response
                                              .lineBarSpots!.first.spotIndex;
                                          setState(() {
                                            if (showingTooltipOnSpots
                                                .contains(spotIndex)) {
                                              showingTooltipOnSpots
                                                  .remove(spotIndex);
                                            } else {
                                              showingTooltipOnSpots
                                                  .add(spotIndex);
                                            }
                                          });
                                        }
                                      },
                                      mouseCursorResolver: (FlTouchEvent event,
                                          LineTouchResponse? response) {
                                        if (response == null ||
                                            response.lineBarSpots == null) {
                                          return SystemMouseCursors.basic;
                                        }
                                        return SystemMouseCursors.click;
                                      },
                                      getTouchedSpotIndicator:
                                          (LineChartBarData barData,
                                              List<int> spotIndexes) {
                                        return spotIndexes.map((index) {
                                          return TouchedSpotIndicatorData(
                                            const FlLine(
                                              color: Colors.pink,
                                            ),
                                            FlDotData(
                                              show: true,
                                              getDotPainter: (spot, percent,
                                                      barData, index) =>
                                                  FlDotCirclePainter(
                                                radius: 8,
                                                color: Utils.lerpGradient(
                                                  barData.gradient!.colors,
                                                  barData.gradient!.stops!,
                                                  percent / 100,
                                                ),
                                                strokeWidth: 2,
                                                strokeColor: ColorP.textColor,
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (touchedSpot) =>
                                            Colors.pink,
                                        tooltipRoundedRadius: 8,
                                        getTooltipItems:
                                            (List<LineBarSpot> lineBarsSpot) {
                                          return lineBarsSpot
                                              .map((lineBarSpot) {
                                            return LineTooltipItem(
                                              lineBarSpot.y.toString(),
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    lineBarsData: lineBarsData,
                                    minY: 0,
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        axisNameWidget: Text('Min.'),
                                        axisNameSize: 24,
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                          reservedSize: 0,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            return bottomTitleWidgets(
                                              value,
                                              meta,
                                              400,
                                            );
                                          },
                                          reservedSize: 80,
                                        ),
                                      ),
                                      rightTitles: const AxisTitles(
                                        axisNameWidget: Text('Min.'),
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                          reservedSize: 0,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        axisNameWidget: Text(
                                          'Month',
                                          textAlign: TextAlign.left,
                                        ),
                                        axisNameSize: 24,
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 0,
                                        ),
                                      ),
                                    ),
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                        color: ColorP.borderColor,
                                      ),
                                    ),
                                  )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField(
                                    value: _selectedYear3,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) async {
                                      setState(() {
                                        _selectedYear3 =
                                            newValue ?? DateTime.now().year;
                                        lineBarsData = [];
                                      });
                                      await initializeBySpendTime(
                                          _selectedYear3);
                                    },
                                    items: Utils
                                        .buildYearDropdownItems(), // Call a method to build the list of year dropdown items
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25.0),
                                        ),
                                      ),
                                      filled: true,
                                      iconColor: ColorP.textColor,
                                      fillColor: ColorP.background,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(25.0),
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return localizations
                                                ?.translate("yearSelect") ??
                                            ""; // Adjust error message for year
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: ColorP.contentColorPink,
      fontFamily: 'Digital',
      fontSize: 18 * chartWidth / 500,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = MonthEnum.january.name;
        break;
      case 1:
        text = MonthEnum.february.name;
        break;
      case 2:
        text = MonthEnum.march.name;
        break;
      case 3:
        text = MonthEnum.april.name;
        break;
      case 4:
        text = MonthEnum.may.name;
        break;
      case 5:
        text = MonthEnum.june.name;
        break;
      case 6:
        text = MonthEnum.july.name;
        break;
      case 7:
        text = MonthEnum.august.name;
        break;
      case 8:
        text = MonthEnum.september.name;
        break;
      case 9:
        text = MonthEnum.october.name;
        break;
      case 10:
        text = MonthEnum.november.name;
        break;
      case 11:
        text = MonthEnum.december.name;
        break;

      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }
}
