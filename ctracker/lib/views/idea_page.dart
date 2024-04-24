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
import 'package:ctracker/utils/pocketbase_provider.dart';
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
  late List<Idea> ideas = [];
  late MultiSelectController _tagsController;
  late IdeaRepositoryImplementation ideaRepo;
  late TagRepositoryImplementation tagRepo;

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
    ideaRepo = locator<IdeaRepositoryImplementation>();
    tagRepo = locator<TagRepositoryImplementation>();
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
    final String translateIdeasub2 =
        localizations?.translate("ideapsub2") ?? "";
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
                                      fontSize: 58.0,
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
