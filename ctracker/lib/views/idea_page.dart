import 'package:ctracker/components/idea_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/views/idea_add_page.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/models/chip_config.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class IdeaPage extends StatefulWidget {
  bool isInit = false;

  IdeaPage({super.key});

  @override
  _IdeaPageState createState() => _IdeaPageState();
}

class _IdeaPageState extends State<IdeaPage> {
  List<Tag> ideaTags = [];
  late List<Tag> tags;
  late List<Idea> ideas;
  late MultiSelectController _tagsController;
  int selectedTile = -1;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      widget.isInit = false;
      ideas = IdeaData.getAllIdeas();
      tags = TagData.getAllItemType();
      _tagsController = MultiSelectController();
      setState(() {
        widget.isInit = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);

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
                                  const Text(
                                    "I think",
                                    style: TextStyle(
                                      fontSize: 64.0,
                                      fontWeight: FontWeight.bold,
                                      color: ColorP.textColor,
                                    ),
                                  ),
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
                                          "therefore",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: ColorP.textColor,
                                          ),
                                        ),
                                        SizedBox(height: 20.0),
                                        Text(
                                          "I am",
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
                                setState(() {
                                  ideas = IdeaData.getByTags(ideaTags);
                                });
                              },
                              borderRadius: 4.0,
                              borderColor: ColorP.cardBackground,
                              hintFontSize: 16,
                              options: tags
                                  .map((participant) => ValueItem(
                                      label: participant.name,
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

  void handle(bool added) {
    setState(() {
      widget.isInit = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        ideas = IdeaData.getAllIdeas();
        ideaTags = [];
        widget.isInit = true;
      });
    });
  }
}
