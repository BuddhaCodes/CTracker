import 'dart:convert';

import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/idea.dart';
import 'package:ctracker/repository/idea_repository_implementation.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/idea_add_page.dart';

class IdeaCard extends StatefulWidget {
  final Idea idea;
  final int index;
  final int selectedTile;
  final Function(int) onExpanded;
  final VoidCallback onDelete;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.index,
    required this.selectedTile,
    required this.onExpanded,
    required this.onDelete,
  });

  @override
  IdeaCardState createState() => IdeaCardState();
}

class IdeaCardState extends State<IdeaCard> {
  late QuillController _controller = QuillController.basic();
  late IdeaRepositoryImplementation ideaRepo;
  MyLocalizations? localizations;
  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    ideaRepo = IdeaRepositoryImplementation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idea.description!.isNotEmpty) {
      Document doc =
          Document.fromJson(jsonDecode(widget.idea.description ?? ""));
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
            Image.asset(
              IconlyC.ideaIdle,
              width: 24,
              height: 28,
              color: Colors.amber,
            ),
            const SizedBox(width: 15),
            Text(
              widget.idea.title,
              style: const TextStyle(
                color: ColorP.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Utils.updateIcon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IdeaAddPage(
                      onIdeaAdded: () => widget.onDelete(),
                      uIdea: widget.idea,
                    ),
                  ),
                ).then((value) => widget.onDelete());
              },
            ),
            Utils.deleteIcon(
              onPressed: () async {
                try {
                  await ideaRepo
                      .deleteIdea(widget.idea.id ?? "")
                      .whenComplete(() => widget.onDelete());
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
          ],
        ),
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  color: ColorP.background,
                  child: SizedBox(
                    height: 300,
                    child: widget.idea.description != null
                        ? QuillEditor.basic(
                            configurations: QuillEditorConfigurations(
                              controller: _controller,
                              readOnly: true,
                              minHeight: 300,
                              padding: const EdgeInsets.all(20),
                              sharedConfigurations:
                                  const QuillSharedConfigurations(
                                locale: Locale('en'),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
                      color: ColorP.ColorD,
                    ),
                    child: Text(
                      tag.title,
                      style: const TextStyle(color: ColorP.textColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
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
