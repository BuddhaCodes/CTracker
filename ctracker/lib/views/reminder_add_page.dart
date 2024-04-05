import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/enums/repeat_type_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/repeat_types.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/repository/reminder_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class ReminderAddPage extends StatefulWidget {
  final Function onReminderAdded;
  Reminder? uReminder;
  ReminderAddPage({super.key, this.uReminder, required this.onReminderAdded});
  @override
  State<ReminderAddPage> createState() => _ReminderAddPageState();
}

class _ReminderAddPageState extends State<ReminderAddPage> {
  late TextEditingController _dateController;
  late TextEditingController titleController;
  late ReminderRepositoryImplementation reminderRepo;
  bool isInit = false;
  MyLocalizations? localizations;
  late RepeatTypeEnum _selectedRepeatType;

  late int imageCounts;
  late List<String> selectedImages;

  final formKey = GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  void initState() {
    super.initState();
    isInit = false;
    initializeData();
  }

  void initializeData() async {
    _dateController = TextEditingController();
    titleController = TextEditingController();
    reminderRepo = ReminderRepositoryImplementation();

    setState(() {
      if (widget.uReminder != null) {
        titleController.text = widget.uReminder!.title;
        _selectedRepeatType = RepeatTypeEnum.values
            .where((element) => element.id == widget.uReminder?.type.id)
            .first;
        _dateController.text =
            DateFormat('yyyy-MM-dd hh:mm a').format(widget.uReminder!.duedate);
      } else {
        _selectedRepeatType = RepeatTypeEnum.hourly;
        imageCounts = 0;
        selectedImages = [];
      }
    });
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
                                    localizations?.translate("repeattypeadd") ??
                                        "",
                                    style: const TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField(
                                    value: _selectedRepeatType,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedRepeatType =
                                            newValue ?? RepeatTypeEnum.hourly;
                                      });
                                    },
                                    items: RepeatTypeEnum.values
                                        .map<DropdownMenuItem<RepeatTypeEnum>>(
                                      (RepeatTypeEnum value) {
                                        return DropdownMenuItem<RepeatTypeEnum>(
                                          value: value,
                                          child: Text(
                                            value
                                                .name, // Convert enum value to string
                                            style: const TextStyle(
                                                color: ColorP.textColor),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                      labelText: localizations
                                              ?.translate("repeat_type") ??
                                          "",
                                      labelStyle: const TextStyle(
                                          color: ColorP.textColor),
                                      filled: true,
                                      iconColor: ColorP.textColor,
                                      fillColor: ColorP.cardBackground,
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return localizations
                                                ?.translate("repeattypeadd") ??
                                            "";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localizations?.translate('dateadd') ?? "",
                                    style: const TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations
                                              ?.translate('dateadd') ??
                                          "";
                                    }
                                    DateFormat format =
                                        DateFormat("yyyy-MM-dd hh:mm a");
                                    if (!format
                                        .parse(value)
                                        .isAfter(DateTime.now())) {
                                      return localizations
                                              ?.translate('daterange') ??
                                          "";
                                    }
                                    return null;
                                  },
                                  controller: _dateController,
                                  decoration: const InputDecoration(
                                    icon: Icon(
                                      Icons.calendar_today_rounded,
                                      color: ColorP.textColor,
                                    ),
                                  ),
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
                                        _addReminder();
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

  void _addReminder() async {
    if (formKey.currentState!.validate()) {
      String title = titleController.text;

      Reminder newReminder = Reminder(
        title: title,
        type: RepeatType(
            id: _selectedRepeatType.id, name: _selectedRepeatType.name),
        duedate: DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
      );
      if (widget.uReminder == null) {
        newReminder.status =
            Status(id: StatusEnum.notDone.id, name: StatusEnum.notDone.name);
        await reminderRepo.addReminder(newReminder).whenComplete(() {
          widget.onReminderAdded(true);
          Navigator.pop(context);
        });
      } else {
        newReminder.status = widget.uReminder?.status;
        await reminderRepo
            .updateReminder(widget.uReminder?.id ?? "", newReminder)
            .whenComplete(() {
          Navigator.pop(context);
        });
      }
    }
  }

  _selectFile(bool imageFrom) async {
    var fileResult = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (fileResult != null) {
      for (var element in fileResult.files) {
        Uint8List bytes = element.bytes ?? Uint8List(0);

        if (_isImageFile(element.name)) {
          await _saveImageToFolder(bytes, element.name);
          setState(() {
            selectedImages.add(element.path!); // Store selected image path
            imageCounts += 1;
          });
        }
      }
    }
  }

  bool _isImageFile(String fileName) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
    return imageExtensions
        .any((extension) => fileName.toLowerCase().endsWith(extension));
  }

  Future<void> _saveImageToFolder(Uint8List bytes, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();

    File destinationFile = File(
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}-$fileName');

    await destinationFile.writeAsBytes(bytes);
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
