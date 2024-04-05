import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/components/card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/board.dart';
import 'package:ctracker/models/sticky_notes.dart';
import 'package:ctracker/repository/board_repository_implementation.dart';
import 'package:ctracker/repository/sticky_note_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteBoard extends StatefulWidget {
  final List<Board> board;
  final AppFlowyBoardController controller;
  final Function onUpdate;

  const NoteBoard({
    Key? key,
    required this.board,
    required this.controller,
    required this.onUpdate,
  }) : super(key: key);

  @override
  NoteBoardState createState() => NoteBoardState();
}

class NoteBoardState extends State<NoteBoard> {
  late final AppFlowyBoardScrollController boardController;
  late final BoardRepositoryImplementation boardRepo;
  late final StickyNoteRepositoryImplementation stickyRepo;
  MyLocalizations? localizations;
  @override
  void initState() {
    super.initState();
    boardController = AppFlowyBoardScrollController();
    boardRepo = BoardRepositoryImplementation();
    stickyRepo = StickyNoteRepositoryImplementation();

    _setupBoard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  void _setupBoard() {
    final groupedNotes = _groupNotesByBoard(widget.board);
    final groups = _createAppFlowyGroups(groupedNotes);

    for (final board in groups) {
      widget.controller.addGroup(board);
    }
  }

  Map<String, List<TextItem>> _groupNotesByBoard(List<Board> boards) {
    final groupedNotes = <String, List<TextItem>>{};

    for (var b in boards) {
      final key = "${b.id}-${b.title}";
      groupedNotes.putIfAbsent(key, () => []);

      for (var note in b.notes ?? []) {
        groupedNotes[key]!.add(
          TextItem(
            note.id ?? "",
            note.title,
            note.content,
            DateFormat('yyyy-MM-dd').format(note.createdTime ?? DateTime.now()),
            note.createdTime ?? DateTime.now(),
            b.id ?? "",
          ),
        );
      }
    }

    return groupedNotes;
  }

  List<AppFlowyGroupData> _createAppFlowyGroups(
      Map<String, List<TextItem>> groupedNotes) {
    return groupedNotes.entries.map((entry) {
      final keypair = entry.key.split("-");
      return AppFlowyGroupData(
        id: keypair.elementAt(0),
        name: keypair.elementAt(1),
        items: entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppFlowyBoard(
      controller: widget.controller,
      cardBuilder: _buildCard,
      boardScrollController: boardController,
      footerBuilder: _buildFooter,
      headerBuilder: _buildHeader,
      groupConstraints: const BoxConstraints.tightFor(width: 240),
      config: const AppFlowyBoardConfig(
        groupBackgroundColor: ColorP.ColorB,
        stretchGroupHeight: true,
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, AppFlowyGroupData group, Object groupItem) {
    final textItem = groupItem as TextItem;
    return GestureDetector(
      key: ObjectKey(textItem),
      onTap: () {
        _showNoteContent(context, group.headerData.groupId, textItem);
      },
      child: AppFlowyGroupCard(
        key: ObjectKey(textItem),
        child: CardWidget(
          item: textItem,
          onTap: () async {
            try {
              await _deleteStickyNoteAndRemoveFromGroup(textItem, group);
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
          },
        ),
      ),
    );
  }

  Future<void> _deleteStickyNoteAndRemoveFromGroup(
      TextItem item, AppFlowyGroupData group) async {
    try {
      await stickyRepo.deleteStickyNote(item.id);
      widget.controller.removeGroupItem(group.id, item.id);
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

  Widget _buildFooter(BuildContext context, AppFlowyGroupData columnData) {
    return AppFlowyGroupFooter(
      icon: const Icon(
        Icons.add,
        size: 20,
        color: ColorP.ColorD,
      ),
      title: Text(localizations?.translate("newItem") ?? ""),
      height: 30,
      margin: const EdgeInsets.all(8.0),
      onAddButtonClick: () {
        _showAddItemModal(context, columnData.id);
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppFlowyGroupData columnData) {
    return AppFlowyGroupHeader(
      icon: const Icon(Icons.lightbulb_circle_outlined, color: ColorP.ColorD),
      addIcon: const Icon(Icons.close, size: 20, color: ColorP.ColorD),
      onAddButtonClick: () async {
        try {
          await _deleteBoardAndGroup(columnData);
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
      },
      title: SizedBox(
        width: 140,
        child: TextField(
          style: const TextStyle(color: ColorP.ColorC),
          controller: TextEditingController()
            ..text = columnData.headerData.groupName,
          onSubmitted: (val) async {
            try {
              await _updateBoardTitle(columnData, val);
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
          },
        ),
      ),
      height: 75,
      margin: const EdgeInsets.all(8.0),
    );
  }

  Future<void> _updateBoardTitle(
      AppFlowyGroupData columnData, String value) async {
    try {
      await boardRepo.updateBoard(
          columnData.headerData.groupId, Board(title: value));
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
    widget.controller
        .getGroupController(columnData.headerData.groupId)
        ?.updateGroupName(value);
  }

  Future<void> _deleteBoardAndGroup(AppFlowyGroupData columnData) async {
    widget.controller.removeGroup(columnData.headerData.groupId);
    try {
      await boardRepo.deleteBoard(columnData.headerData.groupId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
    }
  }

  void _showAddItemModal(BuildContext context, String groupId) {
    String title = '';
    String text = '';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                style: const TextStyle(color: ColorP.ColorC),
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: ColorP.ColorC),
                  labelText: localizations?.translate("title") ?? "",
                ),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                style: const TextStyle(color: ColorP.ColorC),
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: localizations?.translate("note") ?? "",
                  labelStyle: const TextStyle(color: ColorP.ColorC),
                ),
                onChanged: (value) {
                  text = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (title.isNotEmpty && text.isNotEmpty) {
                    _addItemToBoard(title, text, groupId);
                    Navigator.pop(context);
                  }
                },
                child: Text(localizations?.translate("add") ?? ""),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItemToBoard(String title, String text, String groupId) async {
    try {
      final st = await stickyRepo.addStickyNote(
        StickyNotes(
          title: title,
          content: text,
          board: Board(id: groupId, title: ""),
          createdTime: DateTime.now(),
        ),
      );

      widget.controller.addGroupItem(
        groupId,
        TextItem(
          st.id ?? "",
          title,
          text,
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
          st.createdTime ?? DateTime.now(),
          st.board?.id ?? "",
        ),
      );
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

  void _showNoteContent(
      BuildContext context, String groupId, TextItem groupItem) {
    String title = groupItem.title;
    String text = groupItem.note;

    TextEditingController titleArea = TextEditingController();
    TextEditingController noteArea = TextEditingController();

    titleArea.text = title;
    noteArea.text = text;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                style: const TextStyle(color: ColorP.ColorC),
                controller: titleArea,
                decoration: InputDecoration(
                  labelText: localizations?.translate("title") ?? "",
                  labelStyle: const TextStyle(color: ColorP.ColorC),
                ),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                style: const TextStyle(color: ColorP.ColorC),
                controller: noteArea,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: localizations?.translate("note") ?? "",
                  labelStyle: const TextStyle(color: ColorP.ColorC),
                ),
                onChanged: (value) {
                  text = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (title.isNotEmpty && text.isNotEmpty) {
                    await _updateStickyNoteContent(groupItem, title, text);

                    widget.onUpdate();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(localizations?.translate("update") ?? ""),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStickyNoteContent(
      TextItem item, String title, String text) async {
    try {
      await stickyRepo.updateStickyNote(
        item.id,
        StickyNotes(
          title: title,
          content: text,
          createdTime: item.created,
          board: Board(id: item.gId, title: ""),
        ),
      );
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
