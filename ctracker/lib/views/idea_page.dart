import 'package:ctracker/components/idea_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/enums/tags_enum.dart';
import 'package:ctracker/models/graphs/idea_graph.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/repository/idea_repository_implementation.dart';
import 'package:ctracker/repository/tag_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/views/idea_add_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

// ignore: must_be_immutable
class IdeaPage extends StatefulWidget {
  bool isInit = false;

  IdeaPage({super.key});

  @override
  IdeaPageState createState() => IdeaPageState();
}

class IdeaPageState extends State<IdeaPage> {
  MyLocalizations? localizations;
  List<Tag> ideaTags = [];
  late List<Tag> tags;
  late List<Idea> ideas;
  late MultiSelectController _tagsController;
  late IdeaRepositoryImplementation ideaRepo;
  late TagRepositoryImplementation tagRepo;
  late List<BarChartGroupData> chartData;

  int selectedTile = -1;
  int touchedIndex = -1;
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

  void initializeData() async {
    ideaRepo = IdeaRepositoryImplementation();
    tagRepo = TagRepositoryImplementation();
    chartData = [];
    widget.isInit = false;
    try {
      ideaRepo.getAllIdeas().then((ideasResult) {
        setState(() {
          ideas = ideasResult;
        });
      });
    } catch (e) {
      ideas = [];
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations!.translate("error"),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
    }

    try {
      IdeaTagsChart fetch = await ideaRepo.getNumberByTags();

      chartData = List.generate(3, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, fetch.house.toDouble(),
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, fetch.innovative.toDouble(),
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, fetch.project.toDouble(),
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });
    } catch (e) {
      chartData = List.generate(3, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 0, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 0, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 0, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations!.translate("error"),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
    }

    try {
      tagRepo.getAllTags().then((tagsResult) {
        setState(() {
          tags = tagsResult;
          _tagsController = MultiSelectController();
          widget.isInit = true;
        });
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations!.translate("error"),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
      tags = [];
      _tagsController = MultiSelectController();
      widget.isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String translateError = localizations?.translate("error") ?? "";
    final String translateIdeaP = localizations?.translate("ideap") ?? "";
    final String translateIdeapsub1 =
        localizations?.translate("ideapsub1") ?? "";
    final String translateIdeasub2 = localizations?.translate("ideasub2") ?? "";
    return Scaffold(
      backgroundColor: ColorP.background,
      body: !widget.isInit
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Center(
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Card(
                              color: ColorP.cardBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 400,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: AspectRatio(
                                        aspectRatio: 1.4,
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Stack(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: BarChart(
                                                          mainBarData(),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                                  SizedBox(
                                    width: 100,
                                    height: 140,
                                    child: Image.asset(
                                      IconlyC.ideaIdle,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Text(
                                    translateIdeaP,
                                    style: const TextStyle(
                                      fontSize: 64.0,
                                      fontWeight: FontWeight.bold,
                                      color: ColorP.textColor,
                                    ),
                                  ),
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
                                          translateIdeapsub1,
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            color: ColorP.textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 20.0),
                                        Text(
                                          translateIdeasub2,
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
                                            builder: (context) => IdeaAddPage(
                                              onIdeaAdded: handle,
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
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            height: 40,
                            width: 450,
                            child: MultiSelectDropDown(
                              controller: _tagsController,
                              onOptionSelected:
                                  (List<ValueItem> selectedOptions) {
                                ideaTags = selectedOptions
                                    .map((e) => tags
                                        .where(
                                            (element) => element.id == e.value)
                                        .first)
                                    .toList();

                                try {
                                  ideaRepo
                                      .getByTags(ideaTags)
                                      .then((ideasResult) {
                                    setState(() {
                                      ideas = ideasResult;
                                      widget.isInit = true;
                                    });
                                  });
                                } catch (e) {
                                  ideas = [];
                                  widget.isInit = true;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(translateError,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                    );
                                  }
                                }
                              },
                              borderRadius: 4.0,
                              borderColor: ColorP.cardBackground,
                              hintFontSize: 16,
                              options: tags
                                  .map((participant) => ValueItem(
                                      label: participant.title,
                                      value: participant.id))
                                  .toList(),
                              maxItems: 5,
                              onOptionRemoved: (index, option) {
                                setState(() {
                                  _tagsController.clearSelection(option);
                                });
                              },
                              selectionType: SelectionType.multi,
                              chipConfig: const ChipConfig(
                                  wrapType: WrapType.scroll,
                                  backgroundColor: ColorP.ColorD,
                                  deleteIconColor: ColorP.ColorA,
                                  labelColor: ColorP.textColor),
                              dropdownHeight: 150,
                              dropdownBackgroundColor: ColorP.cardBackground,
                              dropdownBorderRadius: 25,
                              selectedOptionBackgroundColor: ColorP.ColorD,
                              selectedOptionTextColor: ColorP.textColor,
                              radiusGeometry:
                                  const BorderRadius.all(Radius.circular(25.0)),
                              optionsBackgroundColor: ColorP.cardBackground,
                              fieldBackgroundColor: ColorP.cardBackground,
                              hintStyle: const TextStyle(
                                  fontSize: 16, color: ColorP.textColor),
                              optionTextStyle: const TextStyle(
                                  fontSize: 16, color: ColorP.textColor),
                              selectedOptionIcon:
                                  const Icon(Icons.check_circle),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.98,
                            child: SizedBox(
                              height: 500,
                              child: ListView.builder(
                                itemCount: ideas.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return IdeaCard(
                                    idea: ideas[index],
                                    selectedTile: selectedTile,
                                    index: index,
                                    onExpanded: (int sel) {
                                      setState(() {
                                        selectedTile = sel;
                                      });
                                    },
                                    onDelete: () => handle(true),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = TagsEnum.house.name;
                break;
              case 1:
                weekDay = TagsEnum.innovative.name;
                break;
              case 2:
                weekDay = TagsEnum.project.name;
                break;
              default:
                weekDay = TagsEnum.house.name;
                break;
            }
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY).toString(),
                  style: const TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: chartData,
      gridData: const FlGridData(show: false),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= ColorP.contentColorWhite;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? ColorP.contentColorGreen : barColor,
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Color.fromARGB(255, 0, 152, 10))
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: ColorP.contentColorWhite.withOpacity(0.3),
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(TagsEnum.house.name, style: style);
        break;
      case 1:
        text = Text(TagsEnum.innovative.name, style: style);
        break;
      case 2:
        text = Text(TagsEnum.project.name, style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  void handle(bool added) async {
    try {
      initializeData();
    } catch (e) {
      ideas = [];
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
}
