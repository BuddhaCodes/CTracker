import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/category.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/repository/category_repository_implementation.dart';
import 'package:ctracker/repository/idea_repository_implementation.dart';
import 'package:ctracker/repository/tag_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class IdeaAddPage extends StatefulWidget {
  final Function onIdeaAdded;
  Idea? uIdea;
  IdeaAddPage({super.key, this.uIdea, required this.onIdeaAdded});
  @override
  State<IdeaAddPage> createState() => _IdeaAddPageState();
}

class _IdeaAddPageState extends State<IdeaAddPage> {
  bool isNotValidDescription = false;

  late Categories _ideaCategory;
  late List<Tag> tags;
  late List<Tag> ideaTags;

  late List<Categories> _ideaCategories;
  late QuillController _controller;
  late IdeaRepositoryImplementation ideaRepo;
  late TagRepositoryImplementation tagRepo;
  late CategoryRepositoryImplementation catRepo;
  late TextEditingController titleController;
  bool isInit = false;

  late int imageCounts;
  late List<String> selectedImages;
  MyLocalizations? localizations;
  late MultiSelectController _tagsController;

  final formKey = GlobalKey<FormState>();

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
    isInit = false;

    ideaRepo = IdeaRepositoryImplementation();
    tagRepo = TagRepositoryImplementation();
    catRepo = CategoryRepositoryImplementation();
    try {
      _ideaCategories = await catRepo.getAllCategories();
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    tags = await tagRepo.getAllTags();

    setState(() {
      _tagsController = MultiSelectController();
      _controller = QuillController.basic();
      titleController = TextEditingController();
      selectedImages = [];
      if (widget.uIdea != null) {
        titleController.text = widget.uIdea!.title;
        ideaTags = widget.uIdea!.tags;

        Document doc =
            Document.fromJson(jsonDecode(widget.uIdea?.description ?? ""));
        _controller.document = doc;

        _ideaCategory = _ideaCategories
            .where((element) => element.id == widget.uIdea?.category.id)
            .first;
      } else {
        ideaTags = [];
        imageCounts = 0;
        _ideaCategory = _ideaCategories.first;
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
                                    localizations?.translate("catselect") ?? "",
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
                                    value: _ideaCategory,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _ideaCategory =
                                            newValue ?? _ideaCategories.first;
                                      });
                                    },
                                    items: _ideaCategories
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                      filled: true,
                                      iconColor: ColorP.textColor,
                                      fillColor: ColorP.cardBackground,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25.0)),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return localizations
                                                ?.translate("catselect") ??
                                            "";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Select the idea tags *',
                                    style: TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  height: 80,
                                  child: FormField<List<Tag>>(
                                    validator: (value) {
                                      if (ideaTags.isEmpty) {
                                        return localizations
                                                ?.translate('tagselectvalid') ??
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
                                            controller: _tagsController,
                                            onOptionSelected: (List<ValueItem>
                                                selectedOptions) {
                                              field.didChange(selectedOptions
                                                  .map((e) => tags
                                                      .where((element) =>
                                                          element.id == e.value)
                                                      .first)
                                                  .toList());
                                              ideaTags = selectedOptions
                                                  .map((e) => tags
                                                      .where((element) =>
                                                          element.id == e.value)
                                                      .first)
                                                  .toList();
                                            },
                                            borderRadius: 4.0,
                                            borderColor: ColorP.cardBackground,
                                            hintFontSize: 16,
                                            options: tags
                                                .map((tag) => ValueItem(
                                                    label: tag.title,
                                                    value: tag.id))
                                                .toList(),
                                            maxItems: 5,
                                            onOptionRemoved: (index, option) {
                                              setState(() {
                                                _tagsController
                                                    .clearSelection(option);
                                              });
                                            },
                                            selectionType: SelectionType.multi,
                                            chipConfig: const ChipConfig(
                                                wrapType: WrapType.scroll,
                                                backgroundColor: ColorP.ColorD,
                                                deleteIconColor: ColorP.ColorA,
                                                labelColor: ColorP.textColor),
                                            dropdownHeight: 150,
                                            selectedOptions: ideaTags
                                                .map((e) => ValueItem(
                                                    label: e.title,
                                                    value: e.id))
                                                .toList(),
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
                                ),
                                // const SizedBox(height: 30),
                                // const Padding(
                                //   padding: EdgeInsets.all(8.0),
                                //   child: Text(
                                //     'Enter image *',
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
                                const SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localizations?.translate(
                                            'taskValidationDescription') ??
                                        "",
                                    style: const TextStyle(
                                        color: ColorP.textColorSubtitle,
                                        fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: QuillToolbar(
                                          configurations:
                                              const QuillToolbarConfigurations(),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                QuillToolbarHistoryButton(
                                                  isUndo: true,
                                                  controller: _controller,
                                                ),
                                                QuillToolbarHistoryButton(
                                                  isUndo: false,
                                                  controller: _controller,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  options:
                                                      const QuillToolbarToggleStyleButtonOptions(),
                                                  controller: _controller,
                                                  attribute: Attribute.bold,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  options:
                                                      const QuillToolbarToggleStyleButtonOptions(),
                                                  controller: _controller,
                                                  attribute: Attribute.italic,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  controller: _controller,
                                                  attribute:
                                                      Attribute.underline,
                                                ),
                                                QuillToolbarClearFormatButton(
                                                  controller: _controller,
                                                ),
                                                const VerticalDivider(),
                                                QuillToolbarColorButton(
                                                  controller: _controller,
                                                  isBackground: false,
                                                ),
                                                QuillToolbarColorButton(
                                                  controller: _controller,
                                                  isBackground: true,
                                                ),
                                                const VerticalDivider(),
                                                QuillToolbarToggleCheckListButton(
                                                  controller: _controller,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  controller: _controller,
                                                  attribute: Attribute.ol,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  controller: _controller,
                                                  attribute: Attribute.ul,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  controller: _controller,
                                                  attribute:
                                                      Attribute.inlineCode,
                                                ),
                                                QuillToolbarToggleStyleButton(
                                                  controller: _controller,
                                                  attribute:
                                                      Attribute.blockQuote,
                                                ),
                                                QuillToolbarIndentButton(
                                                  controller: _controller,
                                                  isIncrease: true,
                                                ),
                                                QuillToolbarIndentButton(
                                                  controller: _controller,
                                                  isIncrease: false,
                                                ),
                                                const VerticalDivider(),
                                                QuillToolbarLinkStyleButton(
                                                  controller: _controller,
                                                  options:
                                                      const QuillToolbarLinkStyleButtonOptions(
                                                    dialogTheme:
                                                        QuillDialogTheme(
                                                      inputTextStyle: TextStyle(
                                                          color: ColorP.ColorC),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      if (isNotValidDescription == true)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, left: 8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              localizations?.translate(
                                                      'taskValidationDescription') ??
                                                  "",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
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
                                        localizations?.translate("submit") ??
                                            "",
                                        style: const TextStyle(
                                            color: ColorP.textColor)),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        _addIdea();
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

  void _addIdea() async {
    String content = jsonEncode(_controller.document.toDelta().toJson());
    String title = titleController.text;

    setState(() {
      if (content.isEmpty || _controller.document.isEmpty()) {
        isNotValidDescription = true;
      } else {
        isNotValidDescription = false;
      }
    });

    if (formKey.currentState!.validate() && !isNotValidDescription) {
      Idea newIdea = Idea(
        title: title,
        category: _ideaCategory,
        description: content,
        tags: ideaTags,
      );
      if (widget.uIdea != null) {
        try {
          await ideaRepo
              .updateIdea(widget.uIdea?.id ?? "", newIdea)
              .whenComplete(() {
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
        try {
          await ideaRepo.addIdea(newIdea).whenComplete(() {
            widget.onIdeaAdded(true);
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

  _selectFile(bool imageFrom) async {
    var fileResult = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (fileResult != null) {
      for (var element in fileResult.files) {
        Uint8List bytes = element.bytes ?? Uint8List(0);

        if (_isImageFile(element.name)) {
          await _saveImageToFolder(bytes, element.name);
          setState(() {
            selectedImages.add(element.path!);
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
