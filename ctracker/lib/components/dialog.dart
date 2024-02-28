import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/values.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Sentiment { happy, sad, neutral }

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final _formKey = GlobalKey<FormState>();

  String dropdownValue = 'Ideas';

  String _ideaTag = 'Innovative';
  final List<String> _ideaTags = ['Innovative', 'Clever', 'House', 'Project'];

  String _ideaCategory = 'Blue';
  final List<String> _ideaCategories = ['Blue', 'Green', 'Red', 'Yellow'];

  String _reminderCategory = 'Blue';
  final List<String> _reminderCategories = ['Blue', 'Green', 'Red', 'Yellow'];

  String _taskrCategory = 'Blue';
  final List<String> _taskCategories = ['Blue', 'Green', 'Red', 'Yellow'];

  String _taskProject = 'Project 1';
  final List<String> _taskProjecets = ['Project 1', 'Project 2', 'Project 3'];

  String _taskDifficulty = 'easy';
  final List<String> _taskDifficulties = ['easy', 'medium', 'hard'];

  Sentiment _selectedSentiment = Sentiment.happy;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: dropdownValue,
                  isExpanded: true,
                  dropdownColor: ColorConst.drawerBG,
                  borderRadius: BorderRadius.circular(ValuesConst.borderRadius),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue ?? "";
                    });
                  },
                  items: <String>['Ideas', 'Reminders', 'Tasks']
                      .map<DropdownMenuItem<String>>((String value) {
                    IconData iconData;
                    Color iconColor;
                    // Assigning icons based on the value
                    switch (value) {
                      case 'Ideas':
                        iconData = Icons.lightbulb;
                        iconColor = ColorConst.chartColorYellow;
                        break;
                      case 'Reminders':
                        iconData = Icons.notification_important;
                        iconColor = ColorConst.chartColorGreen;
                        break;
                      case 'Tasks':
                        iconData = Icons.assignment;
                        iconColor = ColorConst.chartColorBlue;
                        break;
                      default:
                        iconData = Icons.error;
                        iconColor = ColorConst.lightRed;
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(iconData, color: iconColor), // Icon
                          const SizedBox(
                              width: 10), // Adjust as needed for spacing
                          Text(value,
                              style: const TextStyle(
                                  color: ColorConst.textColor)), // Text
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                if (dropdownValue == 'Ideas') ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Título de la idea',
                            labelText: 'Título *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Descripción de la idea',
                            labelText: 'Descripción *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre una descripción';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Nota extra',
                            labelText: 'Nota *',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _ideaTag,
                          onChanged: (newValue) {
                            setState(() {
                              _ideaTag = newValue ?? "";
                            });
                          },
                          items: _ideaTags
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _ideaCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _ideaCategory = newValue ?? "";
                            });
                          },
                          items: _ideaCategories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Categories',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                ColorConst.primary),
                            overlayColor: const MaterialStatePropertyAll(
                                ColorConst.sendButtonColor),
                            elevation: const MaterialStatePropertyAll(10),
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload_rounded,
                                color: ColorConst.drawerIcon,
                                size: 24.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Añadir imagen!",
                                  style: TextStyle(color: ColorConst.white)),
                            ],
                          ),
                          onPressed: () async {
                            _selectFile(true);
                            // _showPicker(context);
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data',
                                          style: TextStyle(
                                              color: ColorConst.textColor))),
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  ColorConst.primary),
                              overlayColor: const MaterialStatePropertyAll(
                                  ColorConst.sendButtonColor),
                              elevation: const MaterialStatePropertyAll(10),
                              minimumSize: MaterialStateProperty.all(const Size(
                                  150, 50)), // Adjust the size as needed
                            ),
                            child: const Text('Submit',
                                style: TextStyle(color: ColorConst.white)),
                          ),
                        )
                      ],
                    ),
                  ), // Add more form fields as needed
                ],
                if (dropdownValue == 'Reminders') ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Título del recordatorio',
                            labelText: 'Título *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Descripción del recordatorio',
                            labelText: 'Descripción *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre una descripción';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Nota extra',
                            labelText: 'Nota *',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _reminderCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _reminderCategory = newValue ?? "";
                            });
                          },
                          items: _reminderCategories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Categories',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                ColorConst.primary),
                            overlayColor: const MaterialStatePropertyAll(
                                ColorConst.sendButtonColor),
                            elevation: const MaterialStatePropertyAll(10),
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload_rounded,
                                color: ColorConst.drawerIcon,
                                size: 24.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Añadir imagen!",
                                  style: TextStyle(color: ColorConst.white)),
                            ],
                          ),
                          onPressed: () async {
                            _selectFile(true);
                          },
                        ),
                        const SizedBox(height: 20.0),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  ColorConst.primary),
                              overlayColor: const MaterialStatePropertyAll(
                                  ColorConst.sendButtonColor),
                              elevation: const MaterialStatePropertyAll(10),
                              minimumSize: MaterialStateProperty.all(const Size(
                                  150, 50)), // Adjust the size as needed
                            ),
                            child: const Text('Submit',
                                style: TextStyle(color: ColorConst.white)),
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data',
                                          style: TextStyle(
                                              color: ColorConst.textColor))),
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ), // Add more form fields as needed
                ],
                if (dropdownValue == 'Tasks') ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Título de la tarea',
                            labelText: 'Título *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Descripción del recordatorio',
                            labelText: 'Descripción *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Entre una descripción';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Nota extra',
                            labelText: 'Nota *',
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _taskrCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _taskrCategory = newValue ?? "";
                            });
                          },
                          items: _taskCategories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Categorias',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _taskProject,
                          onChanged: (newValue) {
                            setState(() {
                              _taskProject = newValue ?? "";
                            });
                          },
                          items: _taskProjecets
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Projects',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _taskDifficulty,
                          onChanged: (newValue) {
                            setState(() {
                              _taskDifficulty = newValue ?? "";
                            });
                          },
                          items: _taskDifficulties
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Dificultad',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField(
                          value: _taskDifficulty,
                          onChanged: (newValue) {
                            setState(() {
                              _taskDifficulty = newValue ?? "";
                            });
                          },
                          items: _taskDifficulties
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: ColorConst.textColor)),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Dificultad',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        DropdownButtonFormField<Sentiment>(
                          value: _selectedSentiment,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSentiment = newValue!;
                            });
                          },
                          items: Sentiment.values
                              .map<DropdownMenuItem<Sentiment>>(
                                  (Sentiment sentiment) {
                            String text = '';
                            IconData icon;
                            Color color;
                            switch (sentiment) {
                              case Sentiment.happy:
                                text = 'Poco';
                                icon = Icons.sentiment_very_satisfied_outlined;
                                color = Colors.green;
                                break;
                              case Sentiment.sad:
                                text = 'Mucho';
                                icon = Icons.sentiment_dissatisfied_outlined;
                                color = Colors.red;
                                break;
                              case Sentiment.neutral:
                                text = 'Mas o menos';
                                color = Colors.yellow;
                                icon = Icons.sentiment_neutral_outlined;
                                break;
                            }
                            return DropdownMenuItem<Sentiment>(
                              value: sentiment,
                              child: Row(
                                children: [
                                  Icon(icon),
                                  SizedBox(width: 8),
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
                            labelText: 'Esfuerzo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields_outlined),
                            hintText: 'Prioridad',
                            labelText: 'Prioridad *',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) != null) {
                              return 'Entre una número';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                ColorConst.primary),
                            overlayColor: const MaterialStatePropertyAll(
                                ColorConst.sendButtonColor),
                            elevation: const MaterialStatePropertyAll(10),
                            minimumSize:
                                MaterialStateProperty.all(const Size(150, 50)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.file_upload_rounded,
                                color: ColorConst.drawerIcon,
                                size: 24.0,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Añadir imagen!",
                                  style: TextStyle(color: ColorConst.white)),
                            ],
                          ),
                          onPressed: () async {
                            _selectFile(true);
                            // _showPicker(context);
                          },
                        ),
                        const SizedBox(height: 20.0),
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
                        const SizedBox(height: 20.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  ColorConst.primary),
                              overlayColor: const MaterialStatePropertyAll(
                                  ColorConst.sendButtonColor),
                              elevation: const MaterialStatePropertyAll(10),
                              minimumSize: MaterialStateProperty.all(const Size(
                                  150, 50)), // Adjust the size as needed
                            ),
                            child: const Text('Submit',
                                style: TextStyle(color: ColorConst.white)),
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data',
                                          style: TextStyle(
                                              color: ColorConst.textColor))),
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ), // Add more form fields as needed
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
      fileResult.files.forEach((element) {
        setState(() {
          pickedImagesInBytes.add(element.bytes ?? Uint8List(1));
          //selectedImageInBytes = fileResult.files.first.bytes;
          imageCounts += 1;
        });
      });
    }
    print(selectedFile);
  }
}
