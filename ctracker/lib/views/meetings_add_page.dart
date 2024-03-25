import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/action_items.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/models/chip_config.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:numberpicker/numberpicker.dart';

class MeetingsAddPage extends StatefulWidget {
  final Function onMeetAdded;
  Meeting? uMeeting;
  MeetingsAddPage({super.key, this.uMeeting, required this.onMeetAdded});
  @override
  State<MeetingsAddPage> createState() => _MeetingAddPageState();
}

class _MeetingAddPageState extends State<MeetingsAddPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController _dateController;
  late MultiSelectController _tagController;
  late MultiSelectController _participantController;
  late List<Participant> _participants;
  int minutes = 45;
  int hours = 0;
  bool isInit = false;
  final formKey = GlobalKey<FormState>();
  List<Participant> _selectedParticipants = [];
  int numberOfTextFields = 0;
  List<TextEditingController> numberControllers = [];
  @override
  void initState() {
    super.initState();
    isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _participants = ParticipantsData.getAllItemType();
        _dateController = TextEditingController();
        _participantController = MultiSelectController();
        _tagController = MultiSelectController();
        titleController = TextEditingController();
        contentController = TextEditingController();

        if (widget.uMeeting != null) {
          titleController.text = widget.uMeeting!.title;
          contentController.text = widget.uMeeting!.content;
          _dateController.text =
              DateFormat('yyyy-MM-dd hh:mm a').format(widget.uMeeting!.duedate);
          _selectedParticipants = widget.uMeeting!.participants;
          minutes = widget.uMeeting!.meetingDuration.inMinutes.remainder(60);
          hours = widget.uMeeting!.meetingDuration.inHours;
          numberOfTextFields = widget.uMeeting!.actions.length;
          numberControllers = widget.uMeeting!.actions.map((actionItem) {
            TextEditingController controller = TextEditingController();
            controller.text = actionItem.title;
            return controller;
          }).toList();
        }
      });
      isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Enter the title *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                TextFormField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    labelText: 'Enter the title *',
                                    labelStyle:
                                        TextStyle(color: ColorP.textColor),
                                    filled: true,
                                    fillColor: ColorP.cardBackground,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Enter the content *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                TextFormField(
                                  maxLines: 4,
                                  controller: contentController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    labelText: 'Enter the content *',
                                    labelStyle:
                                        TextStyle(color: ColorP.textColor),
                                    filled: true,
                                    fillColor: ColorP.cardBackground,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some content';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Select participants *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                MultiSelectDropDown(
                                  controller: _participantController,
                                  onOptionSelected:
                                      (List<ValueItem> selectedOptions) {
                                    _selectedParticipants = selectedOptions
                                        .map((e) => _participants
                                            .where((element) =>
                                                element.id == e.value)
                                            .first)
                                        .toList();
                                  },
                                  selectedOptions: widget.uMeeting?.participants
                                          .map((participant) => ValueItem(
                                              label: participant.name,
                                              value: participant.id))
                                          .toList() ??
                                      [],
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
                                      _tagController.clearSelection(option);
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
                                  selectedOptionBackgroundColor: ColorP.ColorD,
                                  selectedOptionTextColor: ColorP.textColor,
                                  radiusGeometry: const BorderRadius.all(
                                      Radius.circular(25.0)),
                                  optionsBackgroundColor: ColorP.cardBackground,
                                  fieldBackgroundColor: ColorP.cardBackground,
                                  hintStyle: const TextStyle(
                                      fontSize: 16, color: ColorP.textColor),
                                  optionTextStyle: const TextStyle(
                                      fontSize: 16, color: ColorP.textColor),
                                  selectedOptionIcon:
                                      const Icon(Icons.check_circle),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Enter the date *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                TextField(
                                  controller: _dateController,
                                  decoration: const InputDecoration(
                                      icon: Icon(
                                        Icons.calendar_today_rounded,
                                        color: ColorP.textColor,
                                      ),
                                      labelText: "Selecciona fecha",
                                      labelStyle: TextStyle(
                                          color: ColorP.textColorSubtitle)),
                                  style:
                                      const TextStyle(color: ColorP.textColor),
                                  onTap: () async {
                                    DateTime? pickeddate =
                                        await showDateTimePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101));

                                    if (pickeddate != null) {
                                      setState(() {
                                        _dateController.text =
                                            DateFormat('yyyy-MM-dd hh:mm a')
                                                .format(pickeddate);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Enter # of action items *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    labelText: 'Enter the # of items *',
                                    labelStyle:
                                        TextStyle(color: ColorP.textColor),
                                    filled: true,
                                    fillColor: ColorP.cardBackground,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      numberOfTextFields =
                                          int.tryParse(value) ?? 0;
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
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                            ),
                                            labelText:
                                                'Action Item ${index + 1}',
                                            labelStyle: const TextStyle(
                                                color: ColorP.textColor),
                                            filled: true,
                                            fillColor: ColorP.cardBackground,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return localizations.translate(
                                                  "itemValidationDescription");
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20)
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  'Duration of the meeting *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Hours",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(height: 8.0),
                                        NumberPicker(
                                          value: hours,
                                          haptics: true,
                                          minValue: 0,
                                          maxValue: 24,
                                          onChanged: (value) =>
                                              setState(() => hours = value),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                                color:
                                                    ColorP.textColorSubtitle),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Minutes",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(height: 8.0),
                                          NumberPicker(
                                            value: minutes,
                                            haptics: true,
                                            minValue: 0,
                                            maxValue: 60,
                                            onChanged: (value) =>
                                                setState(() => minutes = value),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                  color:
                                                      ColorP.textColorSubtitle),
                                            ),
                                          ),
                                        ]),
                                  ],
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
                                        localizations.translate("submit"),
                                        style: const TextStyle(
                                            color: ColorP.textColorSubtitle)),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        _addMeeting();
                                      }
                                    },
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
    );
  }

  void _addMeeting() {
    if (formKey.currentState!.validate()) {
      if (widget.uMeeting != null) {
        String title = titleController.text;
        String content = contentController.text;
        var meeting = Meeting(
            id: 5,
            title: title,
            content: content,
            participants: _selectedParticipants,
            meetingDuration: Duration(hours: hours, minutes: minutes),
            duedate:
                DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
            actions: numberControllers
                .map((e) => ActionItem([], id: 29, title: e.text))
                .toList());

        MeetingData.add(meeting);
      } else {
        String title = titleController.text;
        String content = contentController.text;
        var meeting = Meeting(
            id: widget.uMeeting!.id,
            title: title,
            content: content,
            participants: _selectedParticipants,
            meetingDuration: Duration(hours: hours, minutes: minutes),
            duedate:
                DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
            actions: numberControllers
                .map((e) => ActionItem([], id: 29, title: e.text))
                .toList());

        MeetingData.update(meeting);
      }

      widget.onMeetAdded(true);
      Navigator.pop(context);
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
