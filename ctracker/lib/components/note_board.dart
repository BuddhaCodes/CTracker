import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/components/card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/inotable.dart';
import 'package:ctracker/models/note.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteBoard extends StatefulWidget {
  late INotable task;
  final AppFlowyBoardController controller;
  late AppFlowyBoardScrollController boardController;

  NoteBoard({super.key, required this.task, required this.controller}) {
    Map<String, List<TextItem>> groupedNotes = {};

    for (var note in task.note) {
      groupedNotes.putIfAbsent(note.board, () => []);
      groupedNotes[note.board]!.add(TextItem(
        note.title,
        note.content,
        DateFormat('yyyy-MM-dd').format(note.createdTime),
      ));
    }

    List<AppFlowyGroupData> groups = groupedNotes.entries.map((entry) {
      return AppFlowyGroupData(
        id: entry.key,
        name: entry.key,
        items: entry.value,
      );
    }).toList();

    boardController = AppFlowyBoardScrollController();

    for (var board in groups) {
      controller.addGroup(board);
    }
  }

  @override
  _NoteBoard createState() => _NoteBoard();
}

class _NoteBoard extends State<NoteBoard> {
  var config = const AppFlowyBoardConfig(
    groupBackgroundColor: ColorP.ColorB,
    stretchGroupHeight: true,
  );

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return AppFlowyBoard(
      controller: widget.controller,
      cardBuilder: (context, group, groupItem) {
        final textItem = groupItem as TextItem;
        return GestureDetector(
          key: ObjectKey(textItem),
          onTap: () {
            _showNoteContent(context, group.id, groupItem);
          },
          child: AppFlowyGroupCard(
            key: ObjectKey(textItem),
            child: CardWidget(
              item: groupItem,
              onTap: () {
                widget.controller.removeGroupItem(group.id, groupItem.id);
              },
            ),
          ),
        );
      },
      boardScrollController: widget.boardController,
      footerBuilder: (context, columnData) {
        return AppFlowyGroupFooter(
          icon: const Icon(
            Icons.add,
            size: 20,
            color: ColorP.ColorD,
          ),
          title: Text(localizations.translate("newItem")),
          height: 30,
          margin: config.groupPadding,
          onAddButtonClick: () {
            _showAddItemModal(context, columnData.id);
          },
        );
      },
      headerBuilder: (context, columnData) {
        return AppFlowyGroupHeader(
          icon: const Icon(Icons.lightbulb_circle, color: ColorP.ColorD),
          addIcon: const Icon(Icons.close, size: 20, color: ColorP.ColorD),
          onAddButtonClick: () {
            widget.controller.removeGroup(columnData.headerData.groupId);
          },
          title: SizedBox(
            width: 140,
            child: TextField(
              style: const TextStyle(color: ColorP.ColorC),
              controller: TextEditingController()
                ..text = columnData.headerData.groupName,
              onSubmitted: (val) {
                widget.controller
                    .getGroupController(columnData.headerData.groupId)!
                    .updateGroupName(val);
              },
            ),
          ),
          height: 75,
          margin: config.groupPadding,
        );
      },
      groupConstraints: const BoxConstraints.tightFor(width: 240),
      config: config,
    );
  }

  void _showAddItemModal(BuildContext context, String groupId) {
    String title = '';
    String text = '';
    final localizations = MyLocalizations.of(context);
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
                    labelStyle: TextStyle(color: ColorP.ColorC),
                    labelText: localizations.translate("title")),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                style: const TextStyle(color: ColorP.ColorC),
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: localizations.translate("note"),
                  labelStyle: TextStyle(color: ColorP.ColorC),
                ),
                onChanged: (value) {
                  text = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty && text.isNotEmpty) {
                    _addItemToBoard(title, text, groupId);
                    Navigator.pop(context); // Close the modal
                  }
                },
                child: Text(localizations.translate("add")),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItemToBoard(String title, String text, String groupId) {
    setState(() {
      widget.task.note.add(Note(
          content: text,
          title: title,
          board: groupId,
          createdTime: DateTime.now(),
          id: 100));
      widget.controller.addGroupItem(
          groupId,
          TextItem(
              title, text, DateFormat('yyyy-MM-dd').format(DateTime.now())));
    });
  }

  void _showNoteContent(
      BuildContext context, String groupId, TextItem groupItem) {
    String title = groupItem.id;
    String text = groupItem.note;
    final localizations = MyLocalizations.of(context);

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
                  labelText: localizations.translate("title"),
                  labelStyle: TextStyle(color: ColorP.ColorC),
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
                  labelText: localizations.translate("note"),
                  labelStyle: TextStyle(color: ColorP.ColorC),
                ),
                onChanged: (value) {
                  text = value;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
