import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/reminder_categories.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ReminderAddPage extends StatefulWidget {
  final Function onReminderAdded;
  Reminder? uReminder;
  ReminderAddPage({super.key, this.uReminder, required this.onReminderAdded});
  @override
  State<ReminderAddPage> createState() => _ReminderAddPageState();
}

class _ReminderAddPageState extends State<ReminderAddPage> {
  late ReminderCategory _reminderCategory;

  late List<ReminderCategory> _reminderCategories;
  late TextEditingController _dateController;
  late QuillController _controller;

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  bool isInit = false;

  late int imageCounts;
  late List<String> selectedImages;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _reminderCategories = ReminderCategoryData.getAllItemType();
        _controller = QuillController.basic();
        _dateController = TextEditingController();
        titleController = TextEditingController();
        descriptionController = TextEditingController();

        if (widget.uReminder != null) {
          imageCounts = widget.uReminder!.images.length;
          selectedImages = widget.uReminder!.images;
          titleController.text = widget.uReminder!.title;
          descriptionController.text = widget.uReminder!.description;
          Document doc =
              Document.fromJson(jsonDecode(widget.uReminder?.note ?? ""));
          _controller.document = doc;
          _dateController.text = DateFormat('yyyy-MM-dd hh:mm a')
              .format(widget.uReminder!.duedate);
          _reminderCategory = ReminderCategoryData.getAllItemType()
              .where((element) => element.id == widget.uReminder?.categories.id)
              .first;
        } else {
          imageCounts = 0;
          selectedImages = [];
          _reminderCategory = ReminderCategoryData.getAllItemType().first;
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
                                  'Enter the description *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                TextFormField(
                                  maxLines: 4,
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    labelText: 'Enter the description *',
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
                                      return 'Please enter some description';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  "Select ${localizations.translate("category")}",
                                  style: const TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField(
                                    value: _reminderCategory,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _reminderCategory = newValue ??
                                            ReminderCategory(
                                              id: -1,
                                              name: "",
                                              color: Colors.black,
                                            );
                                      });
                                    },
                                    items: _reminderCategories.map<
                                        DropdownMenuItem<ReminderCategory>>(
                                      (ReminderCategory value) {
                                        return DropdownMenuItem<
                                            ReminderCategory>(
                                          value: value,
                                          child: Text(
                                            value.name,
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
                                      labelText:
                                          localizations.translate("category"),
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
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Enter image *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            ColorP.ColorD),
                                    overlayColor: MaterialStatePropertyAll(
                                        ColorP.ColorD.withOpacity(0.98)),
                                    elevation:
                                        const MaterialStatePropertyAll(10),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(150, 50)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(
                                        Icons.file_upload_rounded,
                                        color: ColorP.textColor,
                                        size: 24.0,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(localizations.translate("addImage"),
                                          style: const TextStyle(
                                              color: ColorP.textColor)),
                                    ],
                                  ),
                                  onPressed: () async {
                                    _selectFile(true);
                                  },
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
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
                                  'Enter the note content *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: QuillToolbar.simple(
                                          configurations:
                                              QuillSimpleToolbarConfigurations(
                                            controller: _controller,
                                            showLink: true,
                                            showSearchButton: false,
                                            showCodeBlock: false,
                                            showInlineCode: false,
                                            showAlignmentButtons: false,
                                            showIndent: false,
                                            showSubscript: false,
                                            showSuperscript: false,
                                            showQuote: false,
                                            showStrikeThrough: false,
                                            showUnderLineButton: true,
                                            showClearFormat: false,
                                            color: ColorP.textColor,
                                            sharedConfigurations:
                                                const QuillSharedConfigurations(
                                              locale: Locale('en'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      Expanded(
                                        child: QuillEditor.basic(
                                          configurations:
                                              QuillEditorConfigurations(
                                            controller: _controller,
                                            readOnly: false,
                                            minHeight: 400,
                                            padding: const EdgeInsets.all(20),
                                            sharedConfigurations:
                                                const QuillSharedConfigurations(
                                              locale: Locale('en'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  void _addReminder() {
    if (formKey.currentState!.validate()) {
      if (widget.uReminder != null) {
        String title = titleController.text;
        String description = descriptionController.text;
        String content = jsonEncode(_controller.document.toDelta().toJson());

        setState(() {
          _controller.clear();
        });
        Reminder newReminder = Reminder(
          id: widget.uReminder!.id,
          title: title,
          note: content,
          duedate: DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
          categories: _reminderCategory,
          description: description,
          images: selectedImages,
        );

        ReminderData.updateReminder(newReminder);
      } else {
        String title = titleController.text;
        String description = descriptionController.text;
        String content = jsonEncode(_controller.document.toDelta().toJson());

        setState(() {
          _controller.clear();
        });
        Reminder newReminder = Reminder(
          id: 5,
          title: title,
          note: content,
          duedate: DateFormat('yyyy-MM-dd hh:mm a').parse(_dateController.text),
          categories: _reminderCategory,
          description: description,
          images: selectedImages,
        );

        ReminderData.addReminder(newReminder);
      }

      widget.onReminderAdded(true);
      Navigator.pop(context);
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
