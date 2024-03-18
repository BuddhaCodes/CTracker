import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/idea_categories.dart';
import 'package:ctracker/models/item_types.dart';
import 'package:ctracker/models/tags.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import 'package:path_provider/path_provider.dart';

class AddIdeaDialog extends StatefulWidget {
  final Function(bool) onIdeaAdded;

  const AddIdeaDialog({super.key, required this.onIdeaAdded});
  @override
  _AddIdeaDialogState createState() => _AddIdeaDialogState();
}

class _AddIdeaDialogState extends State<AddIdeaDialog> {
  final _formKey = GlobalKey<FormState>();

  final MultiSelectController _tagsController = MultiSelectController();
  List<String> ideaTags = [];
  List<Tag> tags = TagData.getAllItemType();

  IdeaCategory _ideaCategory = IdeaCategoryData.getAllItemType().first;
  final List<IdeaCategory> _ideaCategories = IdeaCategoryData.getAllItemType();

  List<ItemType> types = ItemTypeData.getAllItemType();

  final ititleController = TextEditingController();
  final idescriptionController = TextEditingController();

  final String selectedFile = '';
  int imageCounts = 0;
  List<String> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return Dialog(
      backgroundColor: ColorConst.background,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(ValuesConst.boxSeparatorSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: ititleController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.text_fields_outlined),
                        hintText: localizations.translate("ideaHintTitle"),
                        labelText: localizations.translate("ideaLabeltTitle"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .translate("ideaValidationtTitle");
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: ValuesConst.boxSeparatorSize),
                    TextFormField(
                      controller: idescriptionController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.text_fields_outlined),
                        hintText:
                            localizations.translate("reminderHintDescription"),
                        labelText:
                            localizations.translate("reminderLabelDescription"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .translate("reminderValidationDescription");
                        }
                        return null;
                      },
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
                              style:
                                  const TextStyle(color: ColorConst.textColor)),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: localizations.translate("category"),
                        border: const OutlineInputBorder(),
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
                              style:
                                  const TextStyle(color: ColorConst.textColor)),
                        ],
                      ),
                      onPressed: () async {
                        _selectFile(true);
                      },
                    ),
                    const SizedBox(height: ValuesConst.boxSeparatorSize),
                    MultiSelectDropDown(
                      controller: _tagsController,
                      onOptionSelected: (List<ValueItem> selectedOptions) {
                        ideaTags = selectedOptions.map((e) => e.label).toList();
                      },
                      borderRadius: 4.0,
                      fieldBackgroundColor: Colors.transparent,
                      hintFontSize: 16,
                      options: tags
                          .map((tag) =>
                              ValueItem(label: tag.name, value: tag.id))
                          .toList(),
                      maxItems: 5,
                      onOptionRemoved: (index, option) {
                        setState(() {
                          _tagsController.clearSelection(option);
                        });
                      },
                      selectionType: SelectionType.multi,
                      chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                      dropdownHeight: 150,
                      borderWidth: 2,
                      borderColor: Color.fromARGB(255, 188, 183, 190),
                      hintStyle: const TextStyle(
                          fontSize: 16, color: ColorConst.textColor),
                      optionTextStyle: const TextStyle(
                          fontSize: 16, color: ColorConst.textColor),
                      selectedOptionIcon: const Icon(Icons.check_circle),
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
                          minimumSize:
                              MaterialStateProperty.all(const Size(150, 50)),
                        ),
                        child: Text(localizations.translate("submit"),
                            style: const TextStyle(
                                color: ColorConst.contrastedTextColor)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _addIdea();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      localizations
                                          .translate("processingEntry"),
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
          ),
        ),
      ),
    );
  }

  void _addIdea() {
    if (_formKey.currentState!.validate()) {
      String title = ititleController.text;
      String description = idescriptionController.text;

      Idea newIdea = Idea(
          id: 5,
          title: title,
          tags: ideaTags,
          description: description,
          images: selectedImages,
          category: _ideaCategory.name);

      IdeaData.addIdea(newIdea);
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
