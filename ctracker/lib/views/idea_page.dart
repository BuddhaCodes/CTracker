import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/components/idea_dialog.dart';
import 'package:ctracker/components/note_board.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/general_note.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/idea_categories.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/idea_details.dart';
import 'package:ctracker/views/meeting_details.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class IdeaPage extends StatefulWidget {
  const IdeaPage({super.key});

  @override
  _IdeaPageState createState() => _IdeaPageState();
}

class _IdeaPageState extends State<IdeaPage> {
  final AppFlowyBoardController controller = AppFlowyBoardController();
  late AppFlowyBoardScrollController boardController;
  late GeneralNote generalNote;
  final _formKey = GlobalKey<FormState>();

  final MultiSelectController _tagController = MultiSelectController();

  IdeaCategory _ideaCategory = IdeaCategoryData.getAllItemType().first;
  final List<IdeaCategory> _ideaCategories = IdeaCategoryData.getAllItemType();

  final MultiSelectController _participantController = MultiSelectController();
  final List<Participant> _participants = ParticipantsData.getAllItemType();

  late List<Idea> ideas;
  late List<Meeting> meetingsData;

  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  bool isInitialized = true;
  bool _isInitialized = false;

  int numberOfTextFields = 0;
  List<TextEditingController> numberControllers = [];

  TextEditingController mtitlecontroller = TextEditingController();
  TextEditingController mdescriptionController = TextEditingController();
  List<String> _selectedParticipants = [];
  @override
  void initState() {
    super.initState();

    boardController = AppFlowyBoardScrollController();
    ideas = IdeaData.getAllIdeas();

    Future.delayed(const Duration(seconds: 2), () {
      generalNote = GeneralNote([]);
      setState(() {
        meetingsData = MeetingData.getAllMeetings();
        _isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);

    double width = MediaQuery.of(context).size.width;

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: width * 0.75,
                    child: Card.filled(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ideas",
                              style: TextStyle(
                                  color: ColorConst.textColor, fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            _buildDataTable(ideas),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddIdeaDialog(
                                onIdeaAdded: handleTaskAdded,
                              );
                            },
                          );
                        },
                        backgroundColor: ColorConst.buttonColor,
                        child: const Icon(
                          Icons.add,
                          color: ColorConst.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Stack(
                children: [
                  SizedBox(
                    width: width * 0.75,
                    child: Card.filled(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Meetings",
                              style: TextStyle(
                                  color: ColorConst.textColor, fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            _buildDataTableMeetings(meetingsData),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16.0,
                    right: 16.0,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () {
                          _showAddItemModal(context);
                        },
                        backgroundColor: ColorConst.buttonColor,
                        child: const Icon(
                          Icons.add,
                          color: ColorConst.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "General notes",
                        style: TextStyle(
                            color: ColorConst.textColor, fontSize: 20),
                      ),
                      SizedBox(
                        width: width * 0.75,
                        child: Card.filled(
                          elevation: 2,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: SizedBox(
                            height: ValuesConst.noteBoardContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: NoteBoard(
                                task: generalNote,
                                controller: controller,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        String title = '';
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextField(
                                    decoration: InputDecoration(
                                        labelText:
                                            localizations.translate("title")),
                                    onChanged: (value) {
                                      title = value;
                                    },
                                  ),
                                  const SizedBox(
                                      height: ValuesConst.boxSeparatorSize),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (title.isNotEmpty) {
                                        final group = AppFlowyGroupData(
                                            id: title, name: title, items: []);
                                        controller.addGroup(group);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text(localizations.translate("add")),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      backgroundColor: ColorConst.buttonColor,
                      child: const Icon(
                        Icons.add,
                        color: ColorConst.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleTaskAdded(bool success) {
    if (success) {
      setState(() {
        isInitialized = false;
        Future.delayed(const Duration(seconds: 3), () {
          ideas = IdeaData.getAllIdeas();
        });
        isInitialized = true;
      });
    } else {}
  }

  void _showAddItemModal(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: mtitlecontroller,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.text_fields_outlined),
                        hintText: localizations.translate("ideaHintTitle"),
                        labelText: localizations.translate("ideaLabeltTitle"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .translate("ideaValidationtTitle");
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: ValuesConst.boxSeparatorSize),
                    TextFormField(
                      controller: mdescriptionController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.text_fields_outlined),
                        hintText:
                            localizations.translate("ideaHintDescription"),
                        labelText:
                            localizations.translate("ideaLabelDescription"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .translate("ideaValidationDescription");
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: ValuesConst.boxSeparatorSize),
                    MultiSelectDropDown(
                      controller: _participantController,
                      onOptionSelected: (List<ValueItem> selectedOptions) {
                        _selectedParticipants =
                            selectedOptions.map((e) => e.label).toList();
                      },
                      borderRadius: 4.0,
                      fieldBackgroundColor: Colors.transparent,
                      hintFontSize: 16,
                      options: _participants
                          .map((participant) => ValueItem(
                              label: participant.name, value: participant.id))
                          .toList(),
                      maxItems: 5,
                      onOptionRemoved: (index, option) {
                        setState(() {
                          _tagController.clearSelection(option);
                        });
                      },
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      dropdownHeight: 150,
                      borderWidth: 2,
                      borderColor: Color.fromARGB(255, 188, 183, 190),
                      hintStyle: const TextStyle(
                          fontSize: 16, color: ColorConst.textColor),
                      optionTextStyle: const TextStyle(
                          fontSize: 16, color: ColorConst.textColor),
                      selectedOptionIcon: const Icon(Icons.check_circle),
                    ),
                    const SizedBox(height: ValuesConst.boxSeparatorSize),
                    DropdownButtonFormField(
                      value: _ideaCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _ideaCategory =
                              newValue ?? IdeaCategory(id: -1, name: "");
                        });
                      },
                      items: _ideaCategories
                          .map<DropdownMenuItem<IdeaCategory>>(
                              (IdeaCategory value) {
                        return DropdownMenuItem<IdeaCategory>(
                          value: value,
                          child: Text(value.name,
                              style:
                                  const TextStyle(color: ColorConst.textColor)),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: localizations.translate("category"),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: ValuesConst.boxSeparatorSize),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: localizations.translate("actionItems"),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          numberOfTextFields = int.tryParse(value) ?? 0;
                          numberControllers = List.generate(
                            numberOfTextFields,
                            (index) => TextEditingController(),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      numberOfTextFields,
                      (index) {
                        return Column(
                          children: [
                            TextFormField(
                              controller: numberControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Action Item ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations
                                      .translate("itemValidationDescription");
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10)
                          ],
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _addItemToMeetings();
                            Navigator.pop(context);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(
                              ColorConst.buttonColor),
                          overlayColor: const MaterialStatePropertyAll(
                              ColorConst.buttonHoverColor),
                          elevation: const MaterialStatePropertyAll(10),
                          minimumSize:
                              MaterialStateProperty.all(const Size(150, 50)),
                        ),
                        child: Text(localizations.translate("submit"),
                            style: const TextStyle(color: ColorConst.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDataTable(List<Idea> data) {
    final localizations = MyLocalizations.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(ValuesConst.tablePadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.70),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ValuesConst.tableRadius - 1),
            ),
            child: DataTable(
              sortAscending: _sortAscending,
              sortColumnIndex: _sortColumnIndex,
              border: TableBorder.all(
                width: ValuesConst.tableBorderWidth,
                color: ColorConst.borderTable,
                borderRadius: BorderRadius.circular(ValuesConst.tableRadius),
              ),
              headingRowColor: const MaterialStatePropertyAll(ColorConst.idea),
              columns: [
                Utils.buildColumn(localizations.translate("title"),
                    onSort: (columnIndex, ascending) => setState(() {
                          _sortAscending = ascending;
                          _sortColumnIndex = columnIndex;
                          if (ascending) {
                            data.sort((a, b) => a.title.compareTo(b.title));
                          } else {
                            data.sort((a, b) => b.title.compareTo(a.title));
                          }
                        })),
                Utils.buildColumn(localizations.translate("tags"),
                    onSort: (columnIndex, ascending) => setState(() {
                          _sortAscending = ascending;
                          _sortColumnIndex = columnIndex;
                          if (ascending) {
                            data.sort((a, b) =>
                                a.tags.length.compareTo(b.tags.length));
                          } else {
                            data.sort((a, b) =>
                                b.tags.length.compareTo(a.tags.length));
                          }
                        })),
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
                        Utils.detailsIcon(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IdeaDetailsPage(ideaId: item.id),
                            ),
                          );
                        }),
                      ],
                    )),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableMeetings(List<Meeting> data) {
    final localizations = MyLocalizations.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(ValuesConst.tablePadding),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.70),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ValuesConst.tableRadius - 1),
            ),
            child: DataTable(
              sortAscending: _sortAscending,
              sortColumnIndex: _sortColumnIndex,
              border: TableBorder.all(
                width: ValuesConst.tableBorderWidth,
                color: ColorConst.borderTable,
                borderRadius: BorderRadius.circular(ValuesConst.tableRadius),
              ),
              headingRowColor: const MaterialStatePropertyAll(
                  Color.fromARGB(255, 91, 159, 228)),
              columns: [
                Utils.buildColumn(localizations.translate("title"),
                    onSort: (columnIndex, ascending) => setState(() {
                          _sortAscending = ascending;
                          _sortColumnIndex = columnIndex;
                          if (ascending) {
                            data.sort((a, b) => a.title.compareTo(b.title));
                          } else {
                            data.sort((a, b) => b.title.compareTo(a.title));
                          }
                        })),
                Utils.buildColumn(localizations.translate("participants")),
                Utils.buildColumn(localizations.translate("amountactions")),
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
                    Utils.buildCell(item.participants.join(', ')),
                    Utils.buildCell(item.actions.length.toString()),
                    DataCell(Row(
                      children: [
                        Utils.updateIcon(onPressed: () {}),
                        Utils.deleteIcon(onPressed: () {
                          setState(() {
                            MeetingData.delete(item.id);
                            meetingsData = MeetingData.getAllMeetings();
                          });
                        }),
                        Utils.detailsIcon(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MeetingDetailsPage(meetingId: item.id),
                            ),
                          );
                        }),
                      ],
                    )),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _addItemToMeetings() {
    setState(() {
      var meeting = Meeting(
          id: 5,
          title: mtitlecontroller.text,
          content: mdescriptionController.text,
          participants: _selectedParticipants,
          actions: numberControllers
              .map((e) => ActionItem([], id: 29, title: e.text))
              .toList());
      MeetingData.add(meeting);
      meetingsData = MeetingData.getAllMeetings();
    });
  }
}
