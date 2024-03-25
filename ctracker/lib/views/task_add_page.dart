import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/difficulties.dart';
import 'package:ctracker/models/effort.dart';
import 'package:ctracker/models/projects.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/models/task_categories.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TaskAddPage extends StatefulWidget {
  final Function onTaskAdded;
  Task? uTask;
  TaskAddPage({super.key, this.uTask, required this.onTaskAdded});
  @override
  State<TaskAddPage> createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  late TextEditingController titleController;
  late TextEditingController priorityController;
  late TextEditingController descriptionController;
  bool isInit = false;
  late TaskCategory _taskCategory;
  late List<TaskCategory> _taskCategories;
  late List<Projects> _taskProjects;
  late Difficulty _taskDifficulty;
  late List<Difficulty> _taskDifficulties;
  late Projects _taskProject;
  late int imageCounts;
  late List<String> selectedImages;
  late Effort _selectedSentiment;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        titleController = TextEditingController();
        descriptionController = TextEditingController();
        priorityController = TextEditingController();
        _taskCategories = TaskCategoryData.getAllItemType();
        _taskProjects = ProjectsData.getAllItemType();
        _taskDifficulties = DifficultyData.getAllItemType();
        if (widget.uTask != null) {
          imageCounts = widget.uTask!.images.length;
          selectedImages = widget.uTask!.images;
          titleController.text = widget.uTask!.title;
          descriptionController.text = widget.uTask!.description;
          _taskCategory = _taskCategories
              .where((element) => element.name == widget.uTask?.category)
              .first;
          _taskProject = _taskProjects
              .where((element) => element.name == widget.uTask?.project)
              .first;
          _taskDifficulty = _taskDifficulties
              .where((element) => element.name == widget.uTask?.difficulty)
              .first;
          priorityController.text = widget.uTask!.priority;
          _selectedSentiment = Effort.values
              .where((element) => element.name == widget.uTask?.effort)
              .first;
        } else {
          imageCounts = 0;
          _selectedSentiment = Effort.poco;
          selectedImages = [];
          _taskCategory = TaskCategoryData.getAllItemType().first;
          _taskProject = ProjectsData.getAllItemType().first;
          _taskDifficulty = _taskDifficulties.first;
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
                                const Text(
                                  'Enter the priority *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                TextFormField(
                                  controller: priorityController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                    ),
                                    labelText: 'Enter the priority *',
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
                                      return 'Please enter the priority';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'Select the category *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField(
                                    value: _taskCategory,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _taskCategory = newValue ??
                                            TaskCategory(
                                              id: -1,
                                              name: "",
                                            );
                                      });
                                    },
                                    items: _taskCategories
                                        .map<DropdownMenuItem<TaskCategory>>(
                                      (TaskCategory value) {
                                        return DropdownMenuItem<TaskCategory>(
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
                                  'Select the difficulty *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField(
                                    value: _taskDifficulty,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _taskDifficulty = newValue ??
                                            Difficulty(
                                              id: -1,
                                              name: "",
                                            );
                                      });
                                    },
                                    items: _taskDifficulties
                                        .map<DropdownMenuItem<Difficulty>>(
                                      (Difficulty value) {
                                        return DropdownMenuItem<Difficulty>(
                                          value: value,
                                          child: Text(
                                            value.name,
                                            style: const TextStyle(
                                                color: ColorP.textColor),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                      labelText: "Difficulties",
                                      labelStyle:
                                          TextStyle(color: ColorP.textColor),
                                      filled: true,
                                      iconColor: ColorP.textColor,
                                      fillColor: ColorP.cardBackground,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  'Select the project *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField(
                                    value: _taskProject,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _taskProject = newValue ??
                                            Projects(
                                              id: -1,
                                              name: "",
                                            );
                                      });
                                    },
                                    items: _taskProjects
                                        .map<DropdownMenuItem<Projects>>(
                                      (Projects value) {
                                        return DropdownMenuItem<Projects>(
                                          value: value,
                                          child: Text(
                                            value.name,
                                            style: const TextStyle(
                                                color: ColorP.textColor),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                      labelText: "Projects",
                                      labelStyle:
                                          TextStyle(color: ColorP.textColor),
                                      filled: true,
                                      iconColor: ColorP.textColor,
                                      fillColor: ColorP.cardBackground,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  'Select the effort *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: ColorP.cardBackground,
                                  ),
                                  child: DropdownButtonFormField<Effort>(
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
                                          color = ColorP.poco;
                                          break;
                                        case Effort.mucho:
                                          text = Effort.mucho.name;
                                          icon = Icons
                                              .sentiment_dissatisfied_outlined;
                                          color = ColorP.mucho;
                                          break;
                                        case Effort.medio:
                                          text = Effort.medio.name;
                                          color = ColorP.medio;
                                          icon =
                                              Icons.sentiment_neutral_outlined;
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
                                                color: color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                      labelText: "Effort",
                                      labelStyle:
                                          TextStyle(color: ColorP.textColor),
                                      filled: true,
                                      iconColor: ColorP.textColor,
                                      fillColor: ColorP.cardBackground,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  'Add the images *',
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
                                        _addTask();
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

  void _addTask() {
    if (formKey.currentState!.validate()) {
      if (widget.uTask != null) {
        String title = titleController.text;
        String description = descriptionController.text;

        Task newTask = Task([],
            id: widget.uTask!.id,
            title: title,
            difficulty: _taskDifficulty.name,
            priority: priorityController.text,
            effort: _selectedSentiment,
            category: _taskCategory.name,
            project: _taskProject.name,
            description: description,
            images: selectedImages,
            hasFinished: widget.uTask!.hasFinished,
            timeSpend: widget.uTask!.timeSpend);

        TaskData.updateTask(newTask);
      } else {
        String title = titleController.text;
        String description = descriptionController.text;

        Task newTask = Task(
          [],
          id: 5,
          title: title,
          difficulty: _taskDifficulty.name,
          priority: priorityController.text,
          effort: _selectedSentiment,
          category: _taskCategory.name,
          project: _taskProject.name,
          description: description,
          images: selectedImages,
          hasFinished: false,
          timeSpend: Duration.zero,
        );
        TaskData.addTask(newTask);
      }

      widget.onTaskAdded(true);
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
