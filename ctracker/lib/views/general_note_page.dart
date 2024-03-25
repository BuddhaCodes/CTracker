import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/components/note_board.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/general_note.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GeneralNotes extends StatefulWidget {
  const GeneralNotes({super.key});

  @override
  State<GeneralNotes> createState() => _GeneralNotesState();
}

class _GeneralNotesState extends State<GeneralNotes> {
  bool isInitialized = false;
  late AppFlowyBoardController controller;
  late GeneralNote generalNote;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        generalNote = GeneralNote([]);
        isInitialized = false;
        controller = AppFlowyBoardController();
        isInitialized = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorP.background,
      body: !isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                        child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 90,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "General notes",
                                        style: TextStyle(
                                          fontSize: 36.0,
                                          color: ColorP.textColor,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        "Anotate the important stuff",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          color: ColorP.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width,
                                    child: Card.filled(
                                      elevation: 2,
                                      color: ColorP.cardBackground,
                                      child: SizedBox(
                                        height: ValuesConst.noteBoardContainer,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: NoteBoard(
                                            task: generalNote,
                                            controller: controller,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 32.0,
                                right: 32.0,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    String title = '';
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              TextField(
                                                decoration: InputDecoration(
                                                  labelText: localizations
                                                      .translate("title"),
                                                  labelStyle: const TextStyle(
                                                      color: ColorP.ColorC),
                                                ),
                                                style: const TextStyle(
                                                    color: ColorP.ColorC),
                                                onChanged: (value) {
                                                  title = value;
                                                },
                                              ),
                                              const SizedBox(
                                                  height: ValuesConst
                                                      .boxSeparatorSize),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (title.isNotEmpty) {
                                                    final group =
                                                        AppFlowyGroupData(
                                                            id: title,
                                                            name: title,
                                                            items: []);
                                                    controller.addGroup(group);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text(localizations
                                                    .translate("add")),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  shape: const CircleBorder(),
                                  tooltip: localizations.translate("add"),
                                  hoverColor: ColorP.ColorD.withOpacity(0.8),
                                  backgroundColor: ColorP.ColorD,
                                  child: const Icon(
                                    Icons.add,
                                    color: ColorP.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
    );
  }
}
