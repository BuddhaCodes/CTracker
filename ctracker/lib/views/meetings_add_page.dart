import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/meeting_repository_implementation.dart';
import 'package:ctracker/repository/participant_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

// ignore: must_be_immutable
class MeetingsAddPage extends StatefulWidget {
  final Function onMeetAdded;
  String? uMeetingId;
  late Meeting? uMeeting;
  MeetingsAddPage({super.key, this.uMeetingId, required this.onMeetAdded});
  @override
  State<MeetingsAddPage> createState() => _MeetingAddPageState();
}

class _MeetingAddPageState extends State<MeetingsAddPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController _dateController;
  late TextEditingController _enddateController;
  late ParticipantRepositoryImplementation participantRepo;
  late MultiSelectController _tagController;
  late MultiSelectController _participantController;
  late MeetingRepositoryImplementation meetingRepo;
  late List<Participant> _participants;
  late List<ActionItem> actions;
  MyLocalizations? localizations;

  bool isInit = false;
  bool isNotValidAction = false;
  final formKey = GlobalKey<FormState>();
  List<Participant> _selectedParticipants = [];

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
    setState(() {
      isInit = false;
    });
    participantRepo = ParticipantRepositoryImplementation();
    meetingRepo = locator<MeetingRepositoryImplementation>();
    _dateController = TextEditingController();
    _enddateController = TextEditingController();
    _participantController = MultiSelectController();
    _tagController = MultiSelectController();
    titleController = TextEditingController();
    contentController = TextEditingController();
    actions = [];
    try {
      _participants = await participantRepo.getAllParticipants();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
      Navigator.pop(context);
    }
    widget.uMeeting = null;
    if (widget.uMeetingId != null) {
      widget.uMeeting = await meetingRepo.getById(widget.uMeetingId ?? "");
      titleController.text = widget.uMeeting!.title;
      contentController.text = widget.uMeeting!.content;
      _dateController.text =
          DateFormat('yyyy-MM-dd hh:mm a').format(widget.uMeeting!.start_date);
      _enddateController.text =
          DateFormat('yyyy-MM-dd hh:mm a').format(widget.uMeeting!.end_date);
      _selectedParticipants = widget.uMeeting!.participants;
      actions = widget.uMeeting!.actions;
    }
    setState(() {
      isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorP.background,
        foregroundColor: ColorP.textColor,
      ),
      backgroundColor: ColorP.background,
      body: SafeArea(
        child: !isInit
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localizations?.translate(
                                            'ideaValidationtTitle') ??
                                        "",
                                    style: const TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                TextFormField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    filled: true,
                                    fillColor: ColorP.cardBackground,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations?.translate(
                                              'ideaValidationtTitle') ??
                                          "";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localizations?.translate('contentadd') ??
                                        "",
                                    style: const TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                TextFormField(
                                  maxLines: 4,
                                  controller: contentController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    filled: true,
                                    fillColor: ColorP.cardBackground,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations
                                              ?.translate('contentadd') ??
                                          "";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localizations
                                            ?.translate('participantadd') ??
                                        "",
                                    style: const TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                FormField<List<Participant>>(
                                  validator: (value) {
                                    if (_selectedParticipants.isEmpty) {
                                      return localizations
                                              ?.translate('participantadd') ??
                                          "";
                                    }
                                    return null;
                                  },
                                  builder: (field) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MultiSelectDropDown(
                                          controller: _participantController,
                                          onOptionSelected: (List<ValueItem>
                                              selectedOptions) {
                                            field.didChange(selectedOptions
                                                .map((e) => _participants
                                                    .where((element) =>
                                                        element.id == e.value)
                                                    .first)
                                                .toList());
                                            _selectedParticipants =
                                                selectedOptions
                                                    .map((e) => _participants
                                                        .where((element) =>
                                                            element.id ==
                                                            e.value)
                                                        .first)
                                                    .toList();
                                          },
                                          selectedOptions: widget.uMeeting !=
                                                  null
                                              ? widget.uMeeting?.participants
                                                      .map((participant) =>
                                                          ValueItem(
                                                              label: participant
                                                                  .name,
                                                              value: participant
                                                                  .id))
                                                      .toList() ??
                                                  []
                                              : [],
                                          borderRadius: 4.0,
                                          borderColor: ColorP.cardBackground,
                                          hintFontSize: 16,
                                          options: _participants
                                              .map((participant) => ValueItem(
                                                  label: participant.name,
                                                  value: participant.id))
                                              .toList(),
                                          maxItems: 5,
                                          onOptionRemoved: (index, option) {
                                            setState(() {
                                              _tagController
                                                  .clearSelection(option);
                                            });
                                          },
                                          selectionType: SelectionType.multi,
                                          chipConfig: const ChipConfig(
                                              wrapType: WrapType.wrap,
                                              backgroundColor: ColorP.ColorD,
                                              deleteIconColor: ColorP.ColorA,
                                              labelColor: ColorP.textColor),
                                          dropdownHeight: 150,
                                          dropdownBackgroundColor:
                                              ColorP.cardBackground,
                                          dropdownBorderRadius: 25,
                                          selectedOptionBackgroundColor:
                                              ColorP.ColorD,
                                          selectedOptionTextColor:
                                              ColorP.textColor,
                                          radiusGeometry:
                                              const BorderRadius.all(
                                                  Radius.circular(25.0)),
                                          optionsBackgroundColor:
                                              ColorP.cardBackground,
                                          fieldBackgroundColor:
                                              ColorP.cardBackground,
                                          hintStyle: const TextStyle(
                                              fontSize: 16,
                                              color: ColorP.textColor),
                                          optionTextStyle: const TextStyle(
                                              fontSize: 16,
                                              color: ColorP.textColor),
                                          selectedOptionIcon:
                                              const Icon(Icons.check_circle),
                                        ),
                                        if (field.errorText != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: Text(
                                              field.errorText!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              localizations
                                                      ?.translate('dateadd') ??
                                                  "",
                                              style: const TextStyle(
                                                  color:
                                                      ColorP.textColorSubtitle,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: _dateController,
                                            decoration: const InputDecoration(
                                              icon: Icon(
                                                Icons.calendar_today_rounded,
                                                color: ColorP.textColor,
                                              ),
                                            ),
                                            style: const TextStyle(
                                                color: ColorP.textColor),
                                            onTap: () async {
                                              DateTime? pickeddate =
                                                  await showDateTimePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2101));

                                              if (pickeddate != null) {
                                                setState(() {
                                                  _dateController
                                                      .text = DateFormat(
                                                          'yyyy-MM-dd hh:mm a')
                                                      .format(pickeddate);
                                                });
                                              }
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return localizations?.translate(
                                                        'dateadd') ??
                                                    "";
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              localizations?.translate(
                                                      'endmeetingadd') ??
                                                  "",
                                              style: const TextStyle(
                                                  color:
                                                      ColorP.textColorSubtitle,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: _enddateController,
                                            decoration: const InputDecoration(
                                              icon: Icon(
                                                Icons.calendar_today_rounded,
                                                color: ColorP.textColor,
                                              ),
                                            ),
                                            style: const TextStyle(
                                                color: ColorP.textColor),
                                            onTap: () async {
                                              DateTime? pickeddate =
                                                  await showDateTimePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2101));

                                              if (pickeddate != null) {
                                                setState(() {
                                                  _enddateController
                                                      .text = DateFormat(
                                                          'yyyy-MM-dd hh:mm a')
                                                      .format(pickeddate);
                                                });
                                              }
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return localizations?.translate(
                                                        'endmeetingadd') ??
                                                    "";
                                              }
                                              if (DateFormat(
                                                      'yyyy-MM-dd hh:mm a')
                                                  .parse(value)
                                                  .isBefore(DateFormat(
                                                          'yyyy-MM-dd hh:mm a')
                                                      .parse(_dateController
                                                          .text))) {
                                                return localizations?.translate(
                                                        'daterange') ??
                                                    "";
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          localizations
                                                  ?.translate('addaction') ??
                                              "",
                                          style: const TextStyle(
                                              color: ColorP.textColorSubtitle,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: const BoxDecoration(
                                          color: ColorP.cardBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              actions.add(ActionItem(
                                                  name: "", description: ""));
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: const Icon(
                                            Icons.add,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isNotValidAction == true)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, left: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        localizations?.translate('addaction') ??
                                            "",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 25),
                                ...List.generate(
                                  actions.length,
                                  (index) {
                                    actions.length;
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    TextEditingController(
                                                        text: actions[index]
                                                            .name),
                                                onChanged: (value) {
                                                  actions[index].name = value;
                                                },
                                                decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                25.0)),
                                                  ),
                                                  labelText: '${index + 1}',
                                                  labelStyle: const TextStyle(
                                                      color: ColorP.textColor),
                                                  filled: true,
                                                  fillColor:
                                                      ColorP.cardBackground,
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                25.0)),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return localizations?.translate(
                                                            "itemValidationDescription") ??
                                                        "";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Utils.deleteIcon(onPressed: () {
                                              setState(() {
                                                actions.removeAt(index);
                                              });
                                            })
                                          ],
                                        ),
                                        const SizedBox(height: 20)
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              ColorP.ColorB),
                                      overlayColor: MaterialStatePropertyAll(
                                          ColorP.ColorB.withOpacity(0.8)),
                                      elevation:
                                          const MaterialStatePropertyAll(10),
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(150, 50)),
                                    ),
                                    child: Text(
                                        localizations?.translate("submit") ??
                                            "",
                                        style: const TextStyle(
                                            color: ColorP.textColor)),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        _addMeeting();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
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
    );
  }

  void _addMeeting() async {
    if (actions.isEmpty) {
      isNotValidAction = true;
    }
    if (formKey.currentState!.validate() && !isNotValidAction) {
      if (widget.uMeeting != null) {
        String title = titleController.text;
        String content = contentController.text;
        var meeting = Meeting(
            title: title,
            content: content,
            participants: _selectedParticipants,
            end_date:
                DateFormat('yyyy-MM-dd hh:mm a').parse(_enddateController.text),
            start_date:
                DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
            actions: actions);
        try {
          await meetingRepo
              .updateMeeting(widget.uMeetingId ?? "", meeting)
              .whenComplete(() {
            widget.onMeetAdded;
            Navigator.pop(context);
          });
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(localizations?.translate("error") ?? "",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)))),
            );
          }
        }
      } else {
        String title = titleController.text;
        String content = contentController.text;
        var meeting = Meeting(
            title: title,
            content: content,
            participants: _selectedParticipants,
            end_date:
                DateFormat('yyyy-MM-dd hh:mm a').parse(_enddateController.text),
            start_date:
                DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
            actions: actions);

        try {
          await meetingRepo.addMeeting(meeting).whenComplete(() {
            Navigator.pop(context);
          });
        } catch (e) {
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
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }
}
