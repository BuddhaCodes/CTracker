import 'package:ctracker/components/icon_widget.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/enums/month_enum.dart';
import 'package:ctracker/models/graphs/bar_data.dart';
import 'package:ctracker/models/graphs/jounralbymonth.dart';
import 'package:ctracker/models/graphs/journalbymood.dart';
import 'package:ctracker/repository/journal_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class JournalOverview extends StatefulWidget {
  const JournalOverview({super.key});

  @override
  JournalOverviewState createState() => JournalOverviewState();
}

class JournalOverviewState extends State<JournalOverview> {
  MyLocalizations? localizations;
  final Color indicatorStrokeColor = ColorP.mainTextColor1;
  late JournalRepositoryImplementation journalRepo;
  late List<BarData> dataList;
  late List<FlSpot> allSpots;
  int _selectedYear = DateTime.now().year;

  bool isInit = false;
  MonthEnum _selectedMonth = MonthEnum.values
      .where((element) => element.value == DateTime.now().month)
      .first;
  final emotions = [
    IconlyC.angry,
    IconlyC.happy,
    IconlyC.sad,
    IconlyC.crying,
    IconlyC.coughing,
    IconlyC.calm
  ];

  BarChartGroupData generateBarGroup(
    int x,
    Color color,
    double value,
    double shadowValue,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 6,
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }

  int touchedGroupIndex = -1;
  List<int> showingTooltipOnSpots = [DateTime.now().month - 1];

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

  late List<LineChartBarData> lineBarsData;

  late LineChartBarData tooltipsOnBar;

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
    journalRepo = locator<JournalRepositoryImplementation>();
    await initializeMonth();
    await initializeByYear();

    setState(() {
      isInit = true;
    });
  }

  Future<void> initializeMonth() async {
    late JournalByMood fetch;
    try {
      fetch =
          await journalRepo.getAllJournalByMoodInMonth(_selectedMonth.value);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
        fetch = JournalByMood(
            angry: 0, calm: 0, coughing: 0, crying: 0, happy: 0, sad: 0);
      }
    }

    setState(() {
      dataList = [];
      allSpots = [];
      dataList.add(BarData(ColorP.angryColor, fetch.angry.toDouble(), 0));
      dataList.add(BarData(ColorP.happyColor, fetch.happy.toDouble(), 0));
      dataList.add(BarData(ColorP.sadColor, fetch.sad.toDouble(), 0));
      dataList.add(BarData(ColorP.cryingColor, fetch.crying.toDouble(), 0));
      dataList.add(BarData(ColorP.coughingColor, fetch.coughing.toDouble(), 0));
      dataList.add(BarData(ColorP.calmColor, fetch.calm.toDouble(), 0));
    });
  }

  Future<void> initializeByYear() async {
    late JournalByMonth fetchMonth;
    allSpots.clear();
    try {
      fetchMonth = await journalRepo.getAllByYear(_selectedYear);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
        fetchMonth = JournalByMonth(
            january: 0,
            feb: 0,
            march: 0,
            april: 0,
            may: 0,
            june: 0,
            july: 0,
            agust: 0,
            september: 0,
            october: 0,
            november: 0,
            december: 0);
      }
    }

    setState(() {
      allSpots.add(FlSpot(0, fetchMonth.january.toDouble()));
      allSpots.add(FlSpot(1, fetchMonth.feb.toDouble()));
      allSpots.add(FlSpot(2, fetchMonth.march.toDouble()));
      allSpots.add(FlSpot(3, fetchMonth.april.toDouble()));
      allSpots.add(FlSpot(4, fetchMonth.may.toDouble()));
      allSpots.add(FlSpot(5, fetchMonth.june.toDouble()));
      allSpots.add(FlSpot(6, fetchMonth.july.toDouble()));
      allSpots.add(FlSpot(7, fetchMonth.agust.toDouble()));
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
                        height: 628,
                        child: Card(
                          elevation: 2,
                          color: ColorP.cardBackground,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    localizations?.translate(
                                            'journalentryofmonthbymood') ??
                                        "",
                                    style: const TextStyle(
                                      color: ColorP.contentColorBlue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 450,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: AspectRatio(
                                    aspectRatio: 1.4,
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceBetween,
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                              color: ColorP.borderColor
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          leftTitles: AxisTitles(
                                            drawBelowEverything: true,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.toInt().toString(),
                                                  textAlign: TextAlign.left,
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 36,
                                              getTitlesWidget: (value, meta) {
                                                final index = value.toInt();
                                                return SideTitleWidget(
                                                  axisSide: meta.axisSide,
                                                  child: IconWidget(
                                                    icon: emotions[index],
                                                    color:
                                                        dataList[index].color,
                                                    isSelected:
                                                        touchedGroupIndex ==
                                                            index,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(),
                                          topTitles: const AxisTitles(),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          getDrawingHorizontalLine: (value) =>
                                              FlLine(
                                            color: ColorP.borderColor
                                                .withOpacity(0.2),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        barGroups:
                                            dataList.asMap().entries.map((e) {
                                          final index = e.key;
                                          final data = e.value;
                                          return generateBarGroup(
                                            index,
                                            data.color,
                                            data.value,
                                            data.shadowValue,
                                          );
                                        }).toList(),
                                        maxY: 20,
                                        barTouchData: BarTouchData(
                                          enabled: true,
                                          handleBuiltInTouches: false,
                                          touchTooltipData: BarTouchTooltipData(
                                            tooltipMargin: 0,
                                            getTooltipItem: (
                                              BarChartGroupData group,
                                              int groupIndex,
                                              BarChartRodData rod,
                                              int rodIndex,
                                            ) {
                                              return BarTooltipItem(
                                                rod.toY.toString(),
                                                TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: rod.color,
                                                  fontSize: 18,
                                                  shadows: const [
                                                    Shadow(
                                                      color: Colors.black26,
                                                      blurRadius: 12,
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          touchCallback: (event, response) {
                                            if (event
                                                    .isInterestedForInteractions &&
                                                response != null &&
                                                response.spot != null) {
                                              setState(() {
                                                touchedGroupIndex = response
                                                    .spot!.touchedBarGroupIndex;
                                              });
                                            } else {
                                              setState(() {
                                                touchedGroupIndex = -1;
                                              });
                                            }
                                          },
                                        ),
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
                                    value: _selectedMonth,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedMonth =
                                            newValue ?? MonthEnum.january;
                                        initializeMonth();
                                      });
                                    },
                                    items: MonthEnum.values
                                        .map<DropdownMenuItem<MonthEnum>>(
                                      (MonthEnum month) {
                                        return DropdownMenuItem<MonthEnum>(
                                          value: month,
                                          child: Text(
                                            month.name,
                                            style: const TextStyle(
                                              color: ColorP.textColor,
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
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
                                                ?.translate("monthSelect") ??
                                            "";
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
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: 600,
                        child: Card(
                          elevation: 2,
                          color: ColorP.cardBackground,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    localizations?.translate(
                                            'frecuencyofentriesinjournal') ??
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
                                                strokeColor:
                                                    indicatorStrokeColor,
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
                                        axisNameWidget: Text('Count'),
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
                                        axisNameWidget: Text('Count'),
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
                                    value: _selectedYear,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) async {
                                      setState(() {
                                        _selectedYear =
                                            newValue ?? DateTime.now().year;
                                        lineBarsData = [];
                                      });
                                      await initializeByYear();
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
}
