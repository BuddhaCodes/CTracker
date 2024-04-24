import 'dart:convert';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

// ignore: must_be_immutable
class TaskViewNote extends StatefulWidget {
  bool isInit = false;
  Task uTask;
  TaskViewNote({super.key, required this.uTask});

  @override
  TaskViewNoteState createState() => TaskViewNoteState();
}

class TaskViewNoteState extends State<TaskViewNote> {
  @override
  void initState() {
    super.initState();
    setState(() {
      widget.isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    QuillController controller = QuillController.basic();
    if (widget.uTask.pomodoro!.note.isNotEmpty) {
      Document doc =
          Document.fromJson(jsonDecode(widget.uTask.pomodoro!.note));
      controller.document = doc;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorP.background,
        foregroundColor: ColorP.textColor,
      ),
      backgroundColor: ColorP.background,
      body: !widget.isInit
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        controller: controller,
                        readOnly: true,
                        minHeight: 300,
                        padding: const EdgeInsets.all(20),
                        sharedConfigurations: const QuillSharedConfigurations(
                          locale: Locale('en'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
