import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/components/note_board.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/board.dart';
import 'package:ctracker/repository/board_repository_implementation.dart';
import 'package:ctracker/repository/sticky_note_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';

class GeneralNotes extends StatefulWidget {
  const GeneralNotes({super.key});

  @override
  State<GeneralNotes> createState() => _GeneralNotesState();
}

class _GeneralNotesState extends State<GeneralNotes> {
  bool isInitialized = false;
  MyLocalizations? localizations;
  late StickyNoteRepositoryImplementation stickyRepo;
  late BoardRepositoryImplementation boardRepo;
  late AppFlowyBoardController controller;
  late List<Board> boardsWithNotes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  void initState() {
    initializeData();

    super.initState();
  }

  void initializeData() async {
    isInitialized = false;
    stickyRepo = StickyNoteRepositoryImplementation();
    boardRepo = BoardRepositoryImplementation();
    controller = AppFlowyBoardController();

    try {
      final stickyFetch = await boardRepo.getAllBoards();

      setState(() {
        boardsWithNotes = stickyFetch;
        isInitialized = true;
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

  @override
  Widget build(BuildContext context) {
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
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
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
                                        localizations?.translate('gnote') ?? "",
                                        style: const TextStyle(
                                          fontSize: 36.0,
                                          color: ColorP.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        localizations?.translate('gnotesub') ??
                                            "",
                                        style: const TextStyle(
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
                                            onUpdate: initializeData,
                                            board: boardsWithNotes,
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
                                                  labelText:
                                                      localizations?.translate(
                                                              "title") ??
                                                          "",
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
                                                onPressed: () async {
                                                  if (title.isNotEmpty) {
                                                    try {
                                                      Board b = await boardRepo
                                                          .addBoards(Board(
                                                              title: title));
                                                      final group =
                                                          AppFlowyGroupData(
                                                              id: b.id ?? "",
                                                              name: b.title,
                                                              items: []);

                                                      controller
                                                          .addGroup(group);
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  localizations
                                                                          ?.translate(
                                                                              "error") ??
                                                                      "",
                                                                  style: const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255)))),
                                                        );
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Text(localizations
                                                        ?.translate("add") ??
                                                    ""),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  shape: const CircleBorder(),
                                  tooltip:
                                      localizations?.translate("add") ?? "",
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
