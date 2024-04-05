import 'dart:convert';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/journal.dart';
import 'package:ctracker/repository/journal_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

class JournalEntryPage extends StatefulWidget {
  final String? id;
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
  bool isLoading = true;
  MyLocalizations? localizations;
  final QuillController _controller = QuillController.basic();
  String text = "";
  Journal? journalEntry;
  List<Reaction<String>> flagsReactions = [];
  String selectedRection = "";
  late JournalRepositoryImplementation journalRepo;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MyLocalizations.of(context);
  }

  void initializeData() async {
    isLoading = true;
    journalRepo = JournalRepositoryImplementation();
    flagsReactions = [
      Reaction<String>(
        value: IconlyC.angry,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.angry,
              color: ColorP.angryColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.angry,
          color: ColorP.angryColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.happy,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.happy,
              color: ColorP.happyColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.happy,
          color: ColorP.happyColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.sad,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.sad,
              color: ColorP.sadColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.sad,
          color: ColorP.sadColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.crying,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.crying,
              color: ColorP.cryingColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.crying,
          color: ColorP.cryingColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.coughing,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.coughing,
              color: ColorP.coughingColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.coughing,
          color: ColorP.coughingColor,
        ),
      ),
      Reaction<String>(
        value: IconlyC.calm,
        previewIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              IconlyC.calm,
              color: ColorP.calmColor,
            ),
          ],
        ),
        icon: Image.asset(
          IconlyC.calm,
          color: ColorP.calmColor,
        ),
      )
    ];

    if (widget.id == null) {
      text = ValuesConst.baseEntry;
      selectedRection = flagsReactions.first.value ?? "";
    } else {
      try {
        journalEntry = await journalRepo.getById(widget.id ?? "");
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

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (text.isNotEmpty) {
      Document doc = Document.fromJson(jsonDecode(text));
      _controller.document = doc;
    }

    return Scaffold(
      backgroundColor: ColorP.background,
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                      padding:
                          const EdgeInsets.all(ValuesConst.boxSeparatorSize),
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
                              .where(
                                  (element) => element.value == selectedRection)
                              .first,
                          reactions: flagsReactions,
                          placeholder: flagsReactions.first,
                          boxColor: ColorP.white,
                          boxRadius: 10,
                          itemsSpacing: 20,
                          itemSize: const Size(40, 40),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(ColorP.ColorD)),
                        onPressed: () async {
                          String content = jsonEncode(
                              _controller.document.toDelta().toJson());
                          try {
                            widget.id == null
                                ? await journalRepo.addJournal(Journal(
                                    moodIcon: selectedRection,
                                    date: widget.date,
                                    content: content))
                                : await journalRepo.updateJournal(
                                    widget.id ?? "",
                                    Journal(
                                        moodIcon: selectedRection,
                                        date: widget.date,
                                        content: content));
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        localizations?.translate("error") ?? "",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)))),
                              );
                            }
                          }

                          setState(() {
                            _controller.clear();
                          });

                          widget.entryHandle();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          localizations?.translate('submit') ?? "",
                          style: const TextStyle(color: ColorP.textColor),
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
