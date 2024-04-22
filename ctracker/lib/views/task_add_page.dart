import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/enums/difficulty_enum.dart';
import 'package:ctracker/models/enums/effort_enum.dart';
import 'package:ctracker/models/enums/repeat_type_enum.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/enums/tags_enum.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/priorities.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/repeat_types.dart';
import 'package:ctracker/models/status.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/repository/category_repository_implementation.dart';
import 'package:ctracker/repository/idea_repository_implementation.dart';
import 'package:ctracker/repository/priorities_repository_implementation.dart';
import 'package:ctracker/repository/tag_repository_implementation.dart';
import 'package:ctracker/repository/task_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class TaskAddPage extends StatefulWidget {
  final Function onTaskAdded;
  Task? uTask;
  TaskAddPage({super.key, this.uTask, required this.onTaskAdded});
  @override
  State<TaskAddPage> createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  late TextEditingController titleController;
  late TextEditingController reminderController;
  late TextEditingController descriptionController;
  late TextEditingController _dateController;
  late TaskRepositoryImplementation takRepo;
  late CategoryRepositoryImplementation catRepo;
  late PrioritiesRepositoryImplementation prioRepo;
  late IdeaRepositoryImplementation ideaRepo;
  late TagRepositoryImplementation tagRepo;
  late Categories _taskCategory;
  late List<Categories> _taskCategories;

  late DifficultyEnum _taskDifficulty;
  late RepeatTypeEnum _selectedRepeatType;

  late List<Priorities> priorities;
  late Priorities _selectedPriority;

  bool isInit = false;
  late List<Idea> _taskProjects;
  late Idea _taskProject;
  late int imageCounts;
  late List<String> selectedImages;
  late Effort _selectedEffort;
  final formKey = GlobalKey<FormState>();
  MyLocalizations? localizations;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  void initializeData() async {
    setState(() {
      isInit = false;
    });
    catRepo = CategoryRepositoryImplementation();
    takRepo = TaskRepositoryImplementation();
    ideaRepo = IdeaRepositoryImplementation();
    tagRepo = TagRepositoryImplementation();
    prioRepo = PrioritiesRepositoryImplementation();

    selectedImages = [];
    imageCounts = 0;

    _dateController = TextEditingController();
    titleController = TextEditingController();
    reminderController = TextEditingController();
    descriptionController = TextEditingController();
    try {
      _taskCategories = await catRepo.getAllCategories();
      try {
        priorities = await prioRepo.getAllPriorities();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(localizations?.translate("error")??"",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255)))),
          );
        }
        priorities = [];
      }
      _taskProjects = await ideaRepo.getByTags(
          [Tag(id: TagsEnum.project.id, title: TagsEnum.project.name)]);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    if (widget.uTask != null) {
      titleController.text = widget.uTask!.title;
      descriptionController.text = widget.uTask!.description;
      reminderController.text = widget.uTask!.reminder.title;
      _dateController.text = DateFormat('yyyy-MM-dd hh:mm a')
          .format(widget.uTask!.reminder.duedate);
      _selectedRepeatType = RepeatTypeEnum.values
          .where((element) => element.id == widget.uTask!.reminder.type.id)
          .first;
      _taskProject = _taskProjects
          .where((element) => element.id == widget.uTask?.project.id)
          .first;
      _taskCategory = _taskCategories
          .where((element) => element.id == widget.uTask!.category.id)
          .first;
      _selectedPriority = priorities
          .where((element) => element.id == widget.uTask?.priority.id)
          .first;
      _taskDifficulty = widget.uTask!.difficulty;
      _selectedRepeatType = RepeatTypeEnum.values
          .where((element) => element.id == widget.uTask!.reminder.type.id)
          .first;
      _selectedEffort = widget.uTask?.effort ?? Effort.poco;
    } else {
      imageCounts = 0;
      _selectedEffort = Effort.poco;
      _selectedPriority = priorities.first;
      _taskDifficulty = DifficultyEnum.easy;
      selectedImages = [];
      _taskCategory = _taskCategories.first;
      _selectedRepeatType = RepeatTypeEnum.hourly;
      if (_taskProjects.isNotEmpty) {
        _taskProject = _taskProjects.first;
      }
    }
    setState(() {
      isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorP.background,
            foregroundColor: ColorP.textColor,
          ),
          backgroundColor: ColorP.background,
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_taskProjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorP.background,
          foregroundColor: ColorP.textColor,
        ),
        backgroundColor: ColorP.background,
        body: Center(
          child: Text(
            localizations?.translate("noproject") ?? "",
            style: const TextStyle(color: ColorP.textColor, fontSize: 34),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorP.background,
        foregroundColor: ColorP.textColor,
      ),
      backgroundColor: ColorP.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                              localizations
                                      ?.translate('ideaValidationtTitle') ??
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              filled: true,
                              fillColor: ColorP.cardBackground,
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations
                                        ?.translate('ideaValidationtTitle') ??
                                    "";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations?.translate(
                                      'ideaValidationDescription') ??
                                  "",
                              style: const TextStyle(
                                  color: ColorP.textColorSubtitle,
                                  fontSize: 14),
                            ),
                          ),
                          TextFormField(
                            maxLines: 4,
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                              filled: true,
                              fillColor: ColorP.cardBackground,
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations?.translate(
                                        'ideaValidationDescription') ??
                                    "";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations?.translate('taskLabelPriority') ??
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
                              value: _selectedPriority,
                              borderRadius: BorderRadius.circular(20.0),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedPriority = newValue ??
                                      Priorities(
                                        id: "",
                                        name: "",
                                        level: '',
                                      );
                                });
                              },
                              items:
                                  priorities.map<DropdownMenuItem<Priorities>>(
                                (Priorities value) {
                                  return DropdownMenuItem<Priorities>(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                filled: true,
                                iconColor: ColorP.textColor,
                                fillColor: ColorP.cardBackground,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return localizations
                                          ?.translate('taskLabelPriority') ??
                                      "";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations?.translate('catselect') ?? "",
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
                              value: _taskCategory,
                              borderRadius: BorderRadius.circular(20.0),
                              onChanged: (newValue) {
                                setState(() {
                                  _taskCategory = newValue ??
                                      Categories(
                                        id: "",
                                        name: "",
                                        description: '',
                                      );
                                });
                              },
                              items: _taskCategories
                                  .map<DropdownMenuItem<Categories>>(
                                (Categories value) {
                                  return DropdownMenuItem<Categories>(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                filled: true,
                                iconColor: ColorP.textColor,
                                fillColor: ColorP.cardBackground,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return localizations
                                          ?.translate('catselect') ??
                                      "";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations?.translate('difselect') ?? "",
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
                              value: _taskDifficulty,
                              borderRadius: BorderRadius.circular(20.0),
                              onChanged: (newValue) {
                                setState(() {
                                  _taskDifficulty =
                                      newValue ?? DifficultyEnum.easy;
                                });
                              },
                              items: DifficultyEnum.values
                                  .map<DropdownMenuItem<DifficultyEnum>>(
                                (DifficultyEnum value) {
                                  return DropdownMenuItem<DifficultyEnum>(
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                filled: true,
                                iconColor: ColorP.textColor,
                                fillColor: ColorP.cardBackground,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return localizations
                                          ?.translate('difselect') ??
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
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              localizations?.translate('proselect') ?? "",
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
                              value: _taskProject,
                              borderRadius: BorderRadius.circular(20.0),
                              onChanged: (newValue) {
                                setState(() {
                                  _taskProject = newValue ??
                                      Idea(
                                          id: "",
                                          title: "",
                                          tags: [],
                                          description: "",
                                          category: Categories(
                                              id: "",
                                              name: "",
                                              description: ""));
                                });
                              },
                              items: _taskProjects.map<DropdownMenuItem<Idea>>(
                                (Idea value) {
                                  return DropdownMenuItem<Idea>(
                                    value: value,
                                    child: Text(
                                      value.title,
                                      style: const TextStyle(
                                          color: ColorP.textColor),
                                    ),
                                  );
                                },
                              ).toList(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                filled: true,
                                iconColor: ColorP.textColor,
                                fillColor: ColorP.cardBackground,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return localizations
                                          ?.translate('proselect') ??
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
                              localizations?.translate('effortselect') ?? "",
                              style: const TextStyle(
                                  color: ColorP.textColorSubtitle,
                                  fontSize: 14),
                            ),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: ColorP.cardBackground,
                            ),
                            child: DropdownButtonFormField<Effort>(
                              value: _selectedEffort,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedEffort = newValue!;
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
                                    text = Effort.poco.longname;
                                    icon =
                                        Icons.sentiment_very_satisfied_outlined;
                                    color = ColorP.poco;
                                    break;
                                  case Effort.mucho:
                                    text = Effort.mucho.longname;
                                    icon =
                                        Icons.sentiment_dissatisfied_outlined;
                                    color = ColorP.mucho;
                                    break;
                                  case Effort.medio:
                                    text = Effort.medio.longname;
                                    color = ColorP.medio;
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
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                filled: true,
                                iconColor: ColorP.textColor,
                                fillColor: ColorP.cardBackground,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return localizations
                                          ?.translate('effortselect') ??
                                      "";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          // const Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: Text(
                          //     'Add the images *',
                          //     style: TextStyle(
                          //         color: ColorP.textColorSubtitle,
                          //         fontSize: 14),
                          //   ),
                          // ),
                          // ElevatedButton(
                          //   style: ButtonStyle(
                          //     backgroundColor:
                          //         const MaterialStatePropertyAll(
                          //             ColorP.ColorD),
                          //     overlayColor: MaterialStatePropertyAll(
                          //         ColorP.ColorD.withOpacity(0.98)),
                          //     elevation:
                          //         const MaterialStatePropertyAll(10),
                          //     minimumSize: MaterialStateProperty.all(
                          //         const Size(150, 50)),
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: <Widget>[
                          //       const Icon(
                          //         Icons.file_upload_rounded,
                          //         color: ColorP.textColor,
                          //         size: 24.0,
                          //       ),
                          //       const SizedBox(
                          //         width: 10,
                          //       ),
                          //       Text(localizations.translate("addImage"),
                          //           style: const TextStyle(
                          //               color: ColorP.textColor)),
                          //     ],
                          //   ),
                          //   onPressed: () async {
                          //     _selectFile(true);
                          //   },
                          // ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        localizations
                                                ?.translate('enterreminder') ??
                                            "",
                                        style: const TextStyle(
                                          color: ColorP.textColorSubtitle,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        localizations?.translate(
                                                'ideaValidationtTitle') ??
                                            "",
                                        style: const TextStyle(
                                          color: ColorP.textColorSubtitle,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: reminderController,
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
                                        localizations
                                                ?.translate("repeattypeadd") ??
                                            "",
                                        style: const TextStyle(
                                          color: ColorP.textColorSubtitle,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: ColorP.cardBackground,
                                      ),
                                      child: DropdownButtonFormField(
                                        value: _selectedRepeatType,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedRepeatType = newValue ??
                                                RepeatTypeEnum.hourly;
                                          });
                                        },
                                        items: RepeatTypeEnum.values.map<
                                            DropdownMenuItem<RepeatTypeEnum>>(
                                          (RepeatTypeEnum value) {
                                            return DropdownMenuItem<
                                                RepeatTypeEnum>(
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
                                          labelText: localizations
                                                  ?.translate("repeat_type") ??
                                              "",
                                          labelStyle: const TextStyle(
                                              color: ColorP.textColor),
                                          filled: true,
                                          iconColor: ColorP.textColor,
                                          fillColor: ColorP.cardBackground,
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25.0)),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null) {
                                            return localizations?.translate(
                                                    "repeattypeadd") ??
                                                "";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        localizations?.translate("dateadd") ??
                                            "",
                                        style: const TextStyle(
                                            color: ColorP.textColorSubtitle,
                                            fontSize: 14),
                                      ),
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return localizations
                                                  ?.translate("dateadd") ??
                                              "";
                                        }
                                        DateFormat format =
                                            DateFormat("yyyy-MM-dd hh:mm a");
                                        if (!format
                                            .parse(value)
                                            .isAfter(DateTime.now())) {
                                          return localizations
                                                  ?.translate("daterange") ??
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
                                      style: const TextStyle(
                                          color: ColorP.textColor),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: const MaterialStatePropertyAll(
                                    ColorP.ColorB),
                                overlayColor: MaterialStatePropertyAll(
                                    ColorP.ColorB.withOpacity(0.8)),
                                elevation: const MaterialStatePropertyAll(10),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(150, 50)),
                              ),
                              child: Text(
                                  localizations?.translate("submit") ?? "",
                                  style:
                                      const TextStyle(color: ColorP.textColor)),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  _addTask();
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

  void _addTask() async {
    if (formKey.currentState!.validate()) {
      if (widget.uTask != null) {
        String title = titleController.text;
        String description = descriptionController.text;

        Task newTask = Task(
            id: widget.uTask!.id,
            title: title,
            difficulty: _taskDifficulty,
            priority: _selectedPriority,
            effort: _selectedEffort,
            category: _taskCategory,
            project: _taskProject,
            description: description,
            pomodoro: widget.uTask?.pomodoro,
            status: widget.uTask!.status,
            timeSpend: widget.uTask!.timeSpend,
            reminder: Reminder(
                id: widget.uTask!.reminder.id,
                title: reminderController.text,
                duedate: DateFormat('yyyy-MM-dd hh:mm a')
                    .parse(_dateController.text),
                type: RepeatType(
                    id: _selectedRepeatType.id,
                    name: _selectedRepeatType.name)));
        try {
          await takRepo.updateTask(widget.uTask?.id ?? "", newTask);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(localizations?.translate("error")??"",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)))),
            );
          }
          // widget.onTaskAdded(true);
          Navigator.pop(context);
        }
      } else {
        String title = titleController.text;
        String description = descriptionController.text;

        Task newTask = Task(
            title: title,
            difficulty: _taskDifficulty,
            priority: _selectedPriority,
            effort: _selectedEffort,
            category: _taskCategory,
            project: _taskProject,
            description: description,
            pomodoro: null,
            status: Status(
                id: StatusEnum.notDone.id, name: StatusEnum.notDone.name),
            timeSpend: Duration.zero,
            reminder: Reminder(
                title: reminderController.text,
                duedate: DateFormat('yyyy-MM-dd hh:mm a')
                    .parse(_dateController.text),
                type: RepeatType(
                    id: _selectedRepeatType.id,
                    name: _selectedRepeatType.name)));
        try {
          await takRepo.addTask(newTask).whenComplete(() {
            widget.onTaskAdded(true);
            Navigator.pop(context);
          });
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(localizations?.translate("error")??"",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)))),
            );
          }
          widget.onTaskAdded(true);
          Navigator.pop(context);
        }
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
