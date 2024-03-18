import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/difficulties.dart';
import 'package:ctracker/models/effort.dart';
import 'package:ctracker/models/item_types.dart';
import 'package:ctracker/models/projects.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/reminder_categories.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/models/task_categories.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';

class AddDialog extends StatefulWidget {
  final Function(bool)? onTaskAdded;
  Reminder? updateReminder;
  Task? updateTask;
  AddDialog(
      {super.key, this.updateReminder, this.updateTask, this.onTaskAdded});
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _formKey = GlobalKey<FormState>();

  late ItemType dropdownValue;

  late List<ItemType> types;

  late ReminderCategory _reminderCategory;

  late List<ReminderCategory> _reminderCategories;

  late TaskCategory _taskCategory;
  late List<TaskCategory> _taskCategories;

  late Projects _taskProject;
  late List<Projects> _taskProjecets;

  late Difficulty _taskDifficulty;
  late List<Difficulty> _taskDifficulties;

  late Effort _selectedSentiment;

  late TextEditingController _dateController;

  late TextEditingController ttitleController;
  late TextEditingController tdescriptionController;
  late TextEditingController _tpriorityController;

  late TextEditingController rtitleController;
  late TextEditingController rdescriptionController;

  late String selectedFile;
  late int imageCounts;
  late List<String> selectedImages;
  bool isInit = false;
  @override
  void initState() {
    super.initState();
    isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        dropdownValue = ItemTypeData.getAllItemType().first;
        types = ItemTypeData.getAllItemType();

        _reminderCategories = ReminderCategoryData.getAllItemType();
        _taskCategories = TaskCategoryData.getAllItemType();
        _taskProjecets = ProjectsData.getAllItemType();
        _taskDifficulties = DifficultyData.getAllItemType();
        _selectedSentiment = Effort.poco;
        _dateController = TextEditingController();

        ttitleController = TextEditingController();
        tdescriptionController = TextEditingController();
        _tpriorityController = TextEditingController();

        rtitleController = TextEditingController();
        rdescriptionController = TextEditingController();

        selectedFile = '';
        imageCounts = 0;
        selectedImages = [];

        if (widget.updateReminder != null) {
          dropdownValue = ItemTypeData.getById(1);
          rtitleController.text = widget.updateReminder?.title ?? "";
          rdescriptionController.text =
              widget.updateReminder?.description ?? "";
          _reminderCategory = _reminderCategories
              .where((element) =>
                  element.name == widget.updateReminder?.categories.first)
              .first;
          _dateController.text = _dateController.text =
              DateFormat('yyyy-MM-dd').format(widget.updateReminder!.duedate);
        } else {
          _reminderCategory = ReminderCategoryData.getAllItemType().first;
        }

        if (widget.updateTask != null) {
          dropdownValue = ItemTypeData.getById(2);
          ttitleController.text = widget.updateTask?.title ?? "";
          tdescriptionController.text = widget.updateTask?.description ?? "";
          _taskCategory = _taskCategories
              .where((element) =>
                  element.name == widget.updateTask?.categories.first)
              .first;
          _taskProject = _taskProjecets
              .where((element) => element.name == widget.updateTask?.project)
              .first;
          _taskDifficulty = _taskDifficulties
              .where((element) => element.name == widget.updateTask?.difficulty)
              .first;
          _tpriorityController.text = widget.updateTask!.priority;
          _selectedSentiment = Effort.values
              .where((element) => element.name == widget.updateTask?.effort)
              .first;
        } else {
          _taskCategory = TaskCategoryData.getAllItemType().first;

          _taskProject = ProjectsData.getAllItemType().first;

          _taskDifficulty = DifficultyData.getAllItemType().first;
          _selectedSentiment = Effort.poco;
        }
      });
      isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return Dialog(
      backgroundColor: ColorConst.background,
      child: !isInit
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(ValuesConst.boxSeparatorSize),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.updateReminder == null &&
                          widget.updateTask == null)
                        DropdownButton<ItemType>(
                          value: dropdownValue,
                          isExpanded: true,
                          dropdownColor: ColorConst.background,
                          borderRadius:
                              BorderRadius.circular(ValuesConst.borderRadius),
                          onChanged: (ItemType? newValue) {
                            setState(() {
                              dropdownValue =
                                  newValue ?? ItemType(id: -1, name: "");
                            });
                          },
                          items: types.map<DropdownMenuItem<ItemType>>(
                              (ItemType value) {
                            IconData iconData;
                            Color iconColor;
                            switch (value.name) {
                              case 'Reminders':
                                iconData = Icons.notification_important;
                                iconColor = ColorConst.reminder;
                                break;
                              case 'Tasks':
                                iconData = Icons.assignment;
                                iconColor = ColorConst.task;
                                break;
                              default:
                                iconData = Icons.error;
                                iconColor = ColorConst.black;
                            }
                            return DropdownMenuItem<ItemType>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(iconData, color: iconColor),
                                  const SizedBox(width: 10),
                                  Text(value.name,
                                      style: const TextStyle(
                                          color: ColorConst.textColor)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 10),
                      if (dropdownValue.name == 'Reminders') ...[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: rtitleController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.text_fields_outlined),
                                  hintText: localizations
                                      .translate("reminderHintTitle"),
                                  labelText: localizations
                                      .translate("reminderLabeltTitle"),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return localizations
                                        .translate("reminderValidationtTitle");
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              TextFormField(
                                controller: rdescriptionController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.text_fields_outlined),
                                  hintText: localizations
                                      .translate("reminderHintDescription"),
                                  labelText: localizations
                                      .translate("reminderLabelDescription"),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return Strings
                                        .reminderValidationDescription;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              DropdownButtonFormField(
                                value: _reminderCategory,
                                onChanged: (newValue) {
                                  setState(() {
                                    _reminderCategory = newValue ??
                                        ReminderCategory(id: -1, name: "");
                                  });
                                },
                                items: _reminderCategories
                                    .map<DropdownMenuItem<ReminderCategory>>(
                                        (ReminderCategory value) {
                                  return DropdownMenuItem<ReminderCategory>(
                                    value: value,
                                    child: Text(value.name,
                                        style: const TextStyle(
                                            color: ColorConst.textColor)),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      localizations.translate("category"),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          ColorConst.buttonColor),
                                  overlayColor: const MaterialStatePropertyAll(
                                      ColorConst.buttonHoverColor),
                                  elevation: const MaterialStatePropertyAll(10),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(150, 50)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.file_upload_rounded,
                                      color: ColorConst.background,
                                      size: 24.0,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(localizations.translate("addImage"),
                                        style: const TextStyle(
                                            color: ColorConst.textColor)),
                                  ],
                                ),
                                onPressed: () async {
                                  _selectFile(true);
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              TextField(
                                controller: _dateController,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.calendar_today_rounded),
                                    labelText: "Selecciona fecha"),
                                onTap: () async {
                                  DateTime? pickeddate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101));

                                  if (pickeddate != null) {
                                    setState(() {
                                      _dateController.text =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickeddate);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            ColorConst.buttonColor),
                                    overlayColor:
                                        const MaterialStatePropertyAll(
                                            ColorConst.buttonHoverColor),
                                    elevation:
                                        const MaterialStatePropertyAll(10),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(150, 50)),
                                  ),
                                  child: Text(localizations.translate("submit"),
                                      style: const TextStyle(
                                          color:
                                              ColorConst.contrastedTextColor)),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _addReminder();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                localizations.translate(
                                                    "processingEntry"),
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255)))),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                      if (dropdownValue.name == 'Tasks') ...[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: ttitleController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.text_fields_outlined),
                                  hintText:
                                      localizations.translate("taskHintTitle"),
                                  labelText: localizations
                                      .translate("taskLabeltTitle"),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return localizations
                                        .translate("taskValidationtTitle");
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              TextFormField(
                                controller: tdescriptionController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.text_fields_outlined),
                                  hintText: localizations
                                      .translate("taskHintDescription"),
                                  labelText: localizations
                                      .translate("taskLabelDescription"),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return localizations
                                        .translate("taskValidationDescription");
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              DropdownButtonFormField(
                                value: _taskCategory,
                                onChanged: (newValue) {
                                  setState(() {
                                    _taskCategory = newValue ??
                                        TaskCategory(id: -1, name: "");
                                  });
                                },
                                items: _taskCategories
                                    .map<DropdownMenuItem<TaskCategory>>(
                                        (TaskCategory value) {
                                  return DropdownMenuItem<TaskCategory>(
                                    value: value,
                                    child: Text(value.name,
                                        style: const TextStyle(
                                            color: ColorConst.textColor)),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      localizations.translate("category"),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              DropdownButtonFormField(
                                value: _taskProject,
                                onChanged: (newValue) {
                                  setState(() {
                                    _taskProject =
                                        newValue ?? Projects(id: -1, name: "");
                                  });
                                },
                                items: _taskProjecets
                                    .map<DropdownMenuItem<Projects>>(
                                        (Projects value) {
                                  return DropdownMenuItem<Projects>(
                                    value: value,
                                    child: Text(value.name,
                                        style: const TextStyle(
                                            color: ColorConst.textColor)),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      localizations.translate("projects"),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              DropdownButtonFormField(
                                value: _taskDifficulty,
                                onChanged: (newValue) {
                                  setState(() {
                                    _taskDifficulty = newValue ??
                                        Difficulty(id: -1, name: "");
                                  });
                                },
                                items: _taskDifficulties
                                    .map<DropdownMenuItem<Difficulty>>(
                                        (Difficulty value) {
                                  return DropdownMenuItem<Difficulty>(
                                    value: value,
                                    child: Text(value.name,
                                        style: const TextStyle(
                                            color: ColorConst.textColor)),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText:
                                      localizations.translate("difficulty"),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              DropdownButtonFormField<Effort>(
                                value: _selectedSentiment,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedSentiment = newValue!;
                                  });
                                },
                                items: Effort.values
                                    .map<DropdownMenuItem<Effort>>(
                                        (Effort sentiment) {
                                  String text = '';
                                  IconData icon;
                                  Color color;
                                  switch (sentiment) {
                                    case Effort.poco:
                                      text = Effort.poco.name;
                                      icon = Icons
                                          .sentiment_very_satisfied_outlined;
                                      color = ColorConst.poco;
                                      break;
                                    case Effort.mucho:
                                      text = Effort.mucho.name;
                                      icon =
                                          Icons.sentiment_dissatisfied_outlined;
                                      color = ColorConst.mucho;
                                      break;
                                    case Effort.medio:
                                      text = Effort.medio.name;
                                      color = ColorConst.medio;
                                      icon = Icons.sentiment_neutral_outlined;
                                      break;
                                  }
                                  return DropdownMenuItem<Effort>(
                                    value: sentiment,
                                    child: Row(
                                      children: [
                                        Icon(icon),
                                        const SizedBox(width: 8),
                                        Text(
                                          text,
                                          style: TextStyle(color: color),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  labelText: localizations.translate("effort"),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              TextFormField(
                                controller: _tpriorityController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.text_fields_outlined),
                                  hintText: localizations
                                      .translate("taskHintPriority"),
                                  labelText: localizations
                                      .translate("taskLabelPriority"),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      int.tryParse(value) == null) {
                                    return localizations
                                        .translate("taskValidationPriority");
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          ColorConst.buttonColor),
                                  overlayColor: const MaterialStatePropertyAll(
                                      ColorConst.buttonHoverColor),
                                  elevation: const MaterialStatePropertyAll(10),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(150, 50)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.file_upload_rounded,
                                      color: ColorConst.background,
                                      size: 24.0,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(localizations.translate("addImage"),
                                        style: const TextStyle(
                                            color: ColorConst.white)),
                                  ],
                                ),
                                onPressed: () async {
                                  _selectFile(true);
                                },
                              ),
                              const SizedBox(
                                  height: ValuesConst.boxSeparatorSize),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                            ColorConst.buttonColor),
                                    overlayColor:
                                        const MaterialStatePropertyAll(
                                            ColorConst.buttonHoverColor),
                                    elevation:
                                        const MaterialStatePropertyAll(10),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(150, 50)),
                                  ),
                                  child: Text(localizations.translate("submit"),
                                      style: const TextStyle(
                                          color: ColorConst.white)),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _addTask();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                localizations.translate(
                                                    "processingEntry"),
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255)))),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ]),
              ),
            ),
    );
  }

  void _addReminder() {
    if (_formKey.currentState!.validate()) {
      String title = rtitleController.text;
      String description = rdescriptionController.text;

      Reminder newReminder = Reminder(
        id: 5,
        title: title,
        duedate: DateTime.parse(_dateController.text),
        categories: [_taskCategory.name],
        description: description,
        images: selectedImages,
      );

      ReminderData.addReminder(newReminder);
      widget.onTaskAdded!(true);
      Navigator.pop(context);
    }
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      String title = ttitleController.text;
      String description = tdescriptionController.text;

      Task newTask = Task(
        [],
        id: 5,
        title: title,
        difficulty: _taskDifficulty.name,
        priority: _tpriorityController.text,
        effort: _selectedSentiment.name,
        categories: [_taskCategory.name],
        project: _taskProject.name,
        description: description,
        images: selectedImages,
        hasFinished: false,
        timeSpend: Duration.zero,
      );

      TaskData.addTask(newTask);
      widget.onTaskAdded!(true);
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
}
