import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/idea_categories.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path_provider/path_provider.dart';

class IdeaAddPage extends StatefulWidget {
  final Function onIdeaAdded;
  Idea? uIdea;
  IdeaAddPage({super.key, this.uIdea, required this.onIdeaAdded});
  @override
  State<IdeaAddPage> createState() => _IdeaAddPageState();
}

class _IdeaAddPageState extends State<IdeaAddPage> {
  late IdeaCategory _ideaCategory;
  late List<Tag> tags;
  late List<Tag> ideaTags;

  late List<IdeaCategory> _ideaCategories;
  late QuillController _controller;

  late TextEditingController titleController;
  bool isInit = false;

  late int imageCounts;
  late List<String> selectedImages;

  late MultiSelectController _tagsController;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _ideaCategories = IdeaCategoryData.getAllItemType();
        _controller = QuillController.basic();
        titleController = TextEditingController();
        tags = TagData.getAllItemType();
        _tagsController = MultiSelectController();

        if (widget.uIdea != null) {
          imageCounts = widget.uIdea!.image.length;
          selectedImages = [widget.uIdea!.image];
          titleController.text = widget.uIdea!.title;
          ideaTags = widget.uIdea!.tags;
          Document doc =
              Document.fromJson(jsonDecode(widget.uIdea?.description ?? ""));
          _controller.document = doc;

          _ideaCategory = IdeaCategoryData.getAllItemType()
              .where((element) => element.id == widget.uIdea?.category.id)
              .first;
        } else {
          imageCounts = 0;
          ideaTags = [];
          selectedImages = [];
          _ideaCategory = IdeaCategoryData.getAllItemType().first;
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
                                    value: _ideaCategory,
                                    borderRadius: BorderRadius.circular(20.0),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _ideaCategory = newValue ??
                                            IdeaCategory(
                                              id: -1,
                                              name: "",
                                            );
                                      });
                                    },
                                    items: _ideaCategories
                                        .map<DropdownMenuItem<IdeaCategory>>(
                                      (IdeaCategory value) {
                                        return DropdownMenuItem<IdeaCategory>(
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
                                  'Select the idea tags *',
                                  style: TextStyle(
                                      color: ColorP.textColorSubtitle,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: MultiSelectDropDown(
                                    controller: _tagsController,
                                    onOptionSelected:
                                        (List<ValueItem> selectedOptions) {
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
                                        .map((participant) => ValueItem(
                                            label: participant.name,
                                            value: participant.id))
                                        .toList(),
                                    maxItems: 5,
                                    onOptionRemoved: (index, option) {
                                      setState(() {
                                        _tagsController.clearSelection(option);
                                      });
                                    },
                                    selectionType: SelectionType.multi,
                                    chipConfig: const ChipConfig(
                                        wrapType: WrapType.scroll,
                                        backgroundColor: ColorP.ColorD,
                                        deleteIconColor: ColorP.ColorA,
                                        labelColor: ColorP.textColor),
                                    dropdownHeight: 150,
                                    dropdownBackgroundColor:
                                        ColorP.cardBackground,
                                    dropdownBorderRadius: 25,
                                    selectedOptionBackgroundColor:
                                        ColorP.ColorD,
                                    selectedOptionTextColor: ColorP.textColor,
                                    radiusGeometry: const BorderRadius.all(
                                        Radius.circular(25.0)),
                                    optionsBackgroundColor:
                                        ColorP.cardBackground,
                                    fieldBackgroundColor: ColorP.cardBackground,
                                    hintStyle: const TextStyle(
                                        fontSize: 16, color: ColorP.textColor),
                                    optionTextStyle: const TextStyle(
                                        fontSize: 16, color: ColorP.textColor),
                                    selectedOptionIcon:
                                        const Icon(Icons.check_circle),
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
                                  'Enter the idea description *',
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

  void _addIdea() {
    if (formKey.currentState!.validate()) {
      if (widget.uIdea != null) {
        String title = titleController.text;
        String content = jsonEncode(_controller.document.toDelta().toJson());

        Idea newIdea = Idea(
          id: widget.uIdea!.id,
          title: title,
          category: _ideaCategory,
          description: content,
          tags: ideaTags,
          image: selectedImages.first,
        );

        IdeaData.upadateIdea(newIdea);
      } else {
        String title = titleController.text;
        String content = jsonEncode(_controller.document.toDelta().toJson());
        Idea newIdea = Idea(
          id: 5,
          title: title,
          category: _ideaCategory,
          description: content,
          tags: ideaTags,
          image: "",
        );

        IdeaData.addIdea(newIdea);
      }

      widget.onIdeaAdded(true);
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
