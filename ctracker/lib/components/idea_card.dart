import 'dart:convert';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/idea_add_page.dart';
import 'package:ctracker/views/reminder_add_page.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class IdeaCard extends StatefulWidget {
  final Idea idea;
  int index;
  int selectedTile;
  Function(int) onExpanded;
  VoidCallback onDelete;
  IdeaCard(
      {required this.idea,
      required this.index,
      required this.selectedTile,
      required this.onExpanded,
      required this.onDelete});

  @override
  _IdeaCardState createState() => _IdeaCardState();
}

class _IdeaCardState extends State<IdeaCard> {
  late QuillController _controller = QuillController.basic();

  @override
  void initState() {
    _controller = QuillController.basic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idea.description.isNotEmpty) {
      Document doc = Document.fromJson(jsonDecode(widget.idea.description));
      _controller.document = doc;
    }

    return Card(
      color: ColorP.cardBackground,
      child: ExpansionTile(
        key: UniqueKey(),
        initiallyExpanded: widget.index == widget.selectedTile,
        collapsedIconColor: ColorP.textColor,
        iconColor: ColorP.textColor,
        backgroundColor: ColorP.cardBackground,
        title: Row(
          children: [
            Image.asset(IconlyC.ideaIdle,
                width: 24, height: 28, color: Colors.amber),
            const SizedBox(
              width: 15,
            ),
            Text(
              widget.idea.title,
              style: const TextStyle(
                  color: ColorP.textColor, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Utils.updateIcon(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IdeaAddPage(
                    onIdeaAdded: () => {},
                    uIdea: widget.idea,
                  ),
                ),
              );
            }),
            Utils.deleteIcon(onPressed: () {
              setState(() {
                IdeaData.delete(widget.idea.id);
                widget.onDelete();
              });
            }),
          ],
        ),
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card.filled(
                  elevation: 2,
                  color: ColorP.background,
                  child: SizedBox(
                    height: 300,
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        controller: _controller,
                        readOnly: true,
                        minHeight: 300,
                        padding: const EdgeInsets.all(20),
                        sharedConfigurations: const QuillSharedConfigurations(
                          locale: Locale('en'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.idea.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white70,
                        ),
                        color: ColorP.ColorD),
                    child: Text(
                      tag.name,
                      style: const TextStyle(color: ColorP.textColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          )
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              widget.onExpanded(widget.index);
            } else {
              widget.onExpanded(-1);
            }
          });
        },
      ),
    );
  }
}
