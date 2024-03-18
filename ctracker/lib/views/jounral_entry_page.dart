import 'dart:convert';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

class JournalEntryPage extends StatefulWidget {
  final int? id;
  final DateTime date;
  final Function entryHandle;
  const JournalEntryPage(
      {super.key,
      required this.id,
      required this.date,
      required this.entryHandle});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  QuillController _controller = QuillController.basic();
  String text = "";
  Journal? journalEntry;
  List<Reaction<String>> flagsReactions = [];
  String selectedRection = "";

  @override
  void initState() {
    super.initState();
    flagsReactions = [
      Reaction<String>(
        value: IconlyC.angry,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.angry,
              color: ColorConst.angryColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.angry,
          color: ColorConst.angryColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.happy,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.happy,
              color: ColorConst.happyColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.happy,
          color: ColorConst.happyColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.sad,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.sad,
              color: ColorConst.sadColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.sad,
          color: ColorConst.sadColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.crying,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.crying,
              color: ColorConst.cryingColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.crying,
          color: ColorConst.cryingColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.coughing,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.coughing,
              color: ColorConst.coughingColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.coughing,
          color: ColorConst.coughingColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.calm,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.calm,
              color: ColorConst.calmColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.calm,
          color: ColorConst.calmColor,
        ),
      )
    ];

    if (widget.id == null) {
      text = "";
      selectedRection = flagsReactions.first.value ?? "";
    } else {
      journalEntry = JournalData.getById(widget.id ?? 0);
      if (journalEntry != null) {
        text = journalEntry?.content ?? "";
        selectedRection = (flagsReactions
                .where((element) => element.value == journalEntry?.moodIcon)
                .first
                .value ??
            flagsReactions.first.value)!;
      } else {
        text = "";
        selectedRection = flagsReactions.first.value ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (text.isNotEmpty) {
      Document doc = Document.fromJson(jsonDecode(text));
      _controller.document = doc;
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(ValuesConst.boxSeparatorSize),
            child: QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                readOnly: false,
                padding: const EdgeInsets.all(ValuesConst.boxSeparatorSize),
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: ValuesConst.boxSeparatorSize,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                child: SizedBox.square(
                  dimension: 30,
                  child: ReactionButton<String>(
                    toggle: false,
                    isChecked: true,
                    direction: ReactionsBoxAlignment.rtl,
                    onReactionChanged: (Reaction<String>? reaction) {
                      selectedRection = reaction?.value ?? "";
                    },
                    selectedReaction: flagsReactions
                        .where((element) => element.value == selectedRection)
                        .first,
                    reactions: flagsReactions,
                    placeholder: flagsReactions.first,
                    boxColor: Color.fromARGB(255, 255, 255, 255),
                    boxRadius: 10,
                    itemsSpacing: 20,
                    itemSize: const Size(40, 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                child: ElevatedButton(
                  onPressed: () {
                    String content =
                        jsonEncode(_controller.document.toDelta().toJson());

                    widget.id == null
                        ? JournalData.AddEntry(
                            selectedRection, widget.date, content)
                        : JournalData.UpdateEntry(widget.id ?? 0,
                            selectedRection, widget.date, content);

                    setState(() {
                      _controller.clear();
                    });

                    widget.entryHandle();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: ColorConst.textColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
