import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/difficulties.dart';
import 'package:ctracker/models/idea_categories.dart';
import 'package:ctracker/models/item_types.dart';
import 'package:ctracker/models/projects.dart';
import 'package:ctracker/models/reminder_categories.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/models/task_categories.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Effort { mucho, medio, poco }

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _formKey = GlobalKey<FormState>();

  ItemType dropdownValue = ItemTypeData.getAllItemType().first;

  List<ItemType> types = ItemTypeData.getAllItemType();

  Tag _ideaTag = TagData.getAllItemType().first;
  final List<Tag> _ideaTags = TagData.getAllItemType();

  final List<IdeaCategory> _ideaCategories = IdeaCategoryData.getAllItemType();
  IdeaCategory _ideaCategory = IdeaCategoryData.getAllItemType().first;

  ReminderCategory _reminderCategory =
      ReminderCategoryData.getAllItemType().first;

  final List<ReminderCategory> _reminderCategories =
      ReminderCategoryData.getAllItemType();

  TaskCategory _taskrCategory = TaskCategoryData.getAllItemType().first;
  final List<TaskCategory> _taskCategories = TaskCategoryData.getAllItemType();

  Projects _taskProject = ProjectsData.getAllItemType().first;
  final List<Projects> _taskProjecets = ProjectsData.getAllItemType();

  Difficulty _taskDifficulty = DifficultyData.getAllItemType().first;
  final List<Difficulty> _taskDifficulties = DifficultyData.getAllItemType();

  Effort _selectedSentiment = Effort.poco;

  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorConst.background,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(ValuesConst.boxSeparatorSize),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<ItemType>(
                  value: dropdownValue,
                  isExpanded: true,
                  dropdownColor: ColorConst.background,
                  borderRadius: BorderRadius.circular(ValuesConst.borderRadius),
                  onChanged: (ItemType? newValue) {
                    setState(() {
                      dropdownValue = newValue ?? ItemType(id: -1, name: "");
                    });
                  },
                  items:
                      types.map<DropdownMenuItem<ItemType>>((ItemType value) {
                    IconData iconData;
                    Color iconColor;
                    switch (value.name) {
                      case 'Ideas':
                        iconData = Icons.lightbulb;
                        iconColor = ColorConst.idea;
                        break;
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
                        iconColor = Colors.black;
                    }
                    return DropdownMenuItem<ItemType>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(iconData, color: iconColor),
                          const SizedBox(width: 10),
                          Text(value.name,
                              style:
                                  const TextStyle(color: ColorConst.textColor)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                if (dropdownValue.name == 'Ideas') ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.ideaHintTitle,
                            labelText: Strings.ideaLabeltTitle,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Strings.ideaValidationtTitle;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.ideaHintDescription,
                            labelText: Strings.ideaLabelDescription,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Strings.ideaValidationDescription;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.ideaHintNote,
                            labelText: Strings.ideaLabelNote,
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        DropdownButtonFormField(
                          value: _ideaTag,
                          onChanged: (newValue) {
                            setState(() {
                              _ideaTag = newValue ?? Tag(id: -1, name: "");
                            });
                          },
                          items:
                              _ideaTags.map<DropdownMenuItem<Tag>>((Tag value) {
                            return DropdownMenuItem<Tag>(
                              value: value,
                              child: Text(value.name,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: Strings.tags,
                            border: OutlineInputBorder(),
                          ),
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
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: Strings.category,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                ColorConst.buttonColor),
                            overlayColor: const MaterialStatePropertyAll(
                                ColorConst.buttonHoverColor),
                            elevation: const MaterialStatePropertyAll(10),
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload_rounded,
                                color: ColorConst.background,
                                size: 24.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(Strings.addImage,
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          onPressed: () async {
                            _selectFile(true);
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(Strings.processingEntry,
                                          style: TextStyle(
                                              color: ColorConst.textColor))),
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  ColorConst.buttonColor),
                              overlayColor: const MaterialStatePropertyAll(
                                  ColorConst.buttonHoverColor),
                              elevation: const MaterialStatePropertyAll(10),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                            ),
                            child: const Text(Strings.submit,
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
                if (dropdownValue.name == 'Reminders') ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.reminderHintTitle,
                            labelText: Strings.reminderLabeltTitle,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Strings.reminderValidationtTitle;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.reminderHintDescription,
                            labelText: Strings.reminderLabelDescription,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Strings.reminderValidationDescription;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.reminderHintNote,
                            labelText: Strings.reminderLabelNote,
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
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
                          decoration: const InputDecoration(
                            labelText: Strings.category,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                ColorConst.buttonColor),
                            overlayColor: const MaterialStatePropertyAll(
                                ColorConst.buttonHoverColor),
                            elevation: const MaterialStatePropertyAll(10),
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload_rounded,
                                color: ColorConst.background,
                                size: 24.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(Strings.addImage,
                                  style:
                                      TextStyle(color: ColorConst.textColor)),
                            ],
                          ),
                          onPressed: () async {
                            _selectFile(true);
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
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
                                    DateFormat('yyyy-MM-dd').format(pickeddate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  ColorConst.buttonColor),
                              overlayColor: const MaterialStatePropertyAll(
                                  ColorConst.buttonHoverColor),
                              elevation: const MaterialStatePropertyAll(10),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                            ),
                            child: const Text(Strings.submit,
                                style: TextStyle(
                                    color: ColorConst.contrastedTextColor)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(Strings.processingEntry,
                                          style: TextStyle(
                                              color: ColorConst.textColor))),
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
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.taskHintTitle,
                            labelText: Strings.taskLabeltTitle,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Strings.taskValidationtTitle;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.taskHintDescription,
                            labelText: Strings.taskLabelDescription,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return Strings.taskValidationDescription;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.taskHintNote,
                            labelText: Strings.taskLabelNote,
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        DropdownButtonFormField(
                          value: _taskrCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _taskrCategory =
                                  newValue ?? TaskCategory(id: -1, name: "");
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
                          decoration: const InputDecoration(
                            labelText: Strings.category,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        DropdownButtonFormField(
                          value: _taskProject,
                          onChanged: (newValue) {
                            setState(() {
                              _taskProject =
                                  newValue ?? Projects(id: -1, name: "");
                            });
                          },
                          items: _taskProjecets.map<DropdownMenuItem<Projects>>(
                              (Projects value) {
                            return DropdownMenuItem<Projects>(
                              value: value,
                              child: Text(value.name,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: Strings.projects,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        DropdownButtonFormField(
                          value: _taskDifficulty,
                          onChanged: (newValue) {
                            setState(() {
                              _taskDifficulty =
                                  newValue ?? Difficulty(id: -1, name: "");
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
                          decoration: const InputDecoration(
                            labelText: Strings.difficulty,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        DropdownButtonFormField<Effort>(
                          value: _selectedSentiment,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSentiment = newValue!;
                            });
                          },
                          items: Effort.values.map<DropdownMenuItem<Effort>>(
                              (Effort sentiment) {
                            String text = '';
                            IconData icon;
                            Color color;
                            switch (sentiment) {
                              case Effort.poco:
                                text = 'Poco';
                                icon = Icons.sentiment_very_satisfied_outlined;
                                color = Colors.green;
                                break;
                              case Effort.mucho:
                                text = 'Mucho';
                                icon = Icons.sentiment_dissatisfied_outlined;
                                color = Colors.red;
                                break;
                              case Effort.medio:
                                text = 'Mas o menos';
                                color = Colors.yellow;
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
                                    style: TextStyle(
                                        color:
                                            color), // Adjust the style as needed
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: Strings.effort,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: Strings.taskHintPriority,
                            labelText: Strings.taskLabelPriority,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) != null) {
                              return Strings.taskValidationPriority;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                ColorConst.buttonColor),
                            overlayColor: const MaterialStatePropertyAll(
                                ColorConst.buttonHoverColor),
                            elevation: const MaterialStatePropertyAll(10),
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload_rounded,
                                color: ColorConst.background,
                                size: 24.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(Strings.addImage,
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          onPressed: () async {
                            _selectFile(true);
                          },
                        ),
                        const SizedBox(height: ValuesConst.boxSeparatorSize),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  ColorConst.buttonColor),
                              overlayColor: const MaterialStatePropertyAll(
                                  ColorConst.buttonHoverColor),
                              elevation: const MaterialStatePropertyAll(10),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                            ),
                            child: const Text(Strings.submit,
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(Strings.processingEntry,
                                          style: TextStyle(
                                              color: ColorConst.textColor))),
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

  String selectedFile = '';
  List<Uint8List> pickedImagesInBytes = [];
  int imageCounts = 0;

  _selectFile(bool imageFrom) async {
    var fileResult = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (fileResult != null) {
      selectedFile = fileResult.files.first.name;
      for (var element in fileResult.files) {
        setState(() {
          pickedImagesInBytes.add(element.bytes ?? Uint8List(1));
          //selectedImageInBytes = fileResult.files.first.bytes;
          imageCounts += 1;
        });
      }
    }
  }
}
