import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/enums/status_enum.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/repository/task_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/task_add_page.dart';
import 'package:ctracker/views/task_view_note_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class TaskCard extends StatefulWidget {
  final Task task;
  int index;
  int selectedTile;
  Function(int) onExpanded;
  VoidCallback onDelete;
  TaskCard(
      {super.key,
      required this.task,
      required this.index,
      required this.selectedTile,
      required this.onExpanded,
      required this.onDelete});

  @override
  TaskCardState createState() => TaskCardState();
}

class TaskCardState extends State<TaskCard> {
  late TaskRepositoryImplementation taskRepo;
  MyLocalizations? localizations;
  @override
  void initState() {
    taskRepo = TaskRepositoryImplementation();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  Widget build(BuildContext context) {
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
            SvgPicture.asset(IconlyC.task,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                    widget.task.status.id == StatusEnum.done.id
                        ? ColorP.reminder
                        : const Color.fromARGB(255, 189, 91, 25),
                    BlendMode.srcIn)),
            const SizedBox(width: 20),
            Text(
              widget.task.title,
              style: const TextStyle(
                color: ColorP.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Utils.updateIcon(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskAddPage(
                    onTaskAdded: () => {},
                    uTask: widget.task,
                  ),
                ),
              ).then((value) => widget.onDelete());
            }),
            Utils.deleteIcon(onPressed: () async {
              try {
                await taskRepo
                    .deleteTask(widget.task.id ?? "")
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
                widget.onDelete();
              }
            }),
            if (widget.task.pomodoro!.note.isNotEmpty)
              Utils.checkNotes(onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskViewNote(
                      uTask: widget.task,
                    ),
                  ),
                );
              }),
          ],
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: ColorP.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      localizations?.translate('description') ??
                                          "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.description}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white70,
                              ),
                            ),
                            child: Text(
                              widget.task.category.name,
                              style: const TextStyle(color: ColorP.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                color: Colors.white70,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: ColorP.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      localizations?.translate('difficulty') ??
                                          "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.difficulty.name}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: ColorP.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      localizations?.translate('effort') ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.effort.name}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: ColorP.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                TextSpan(
                                  text: localizations?.translate('priority') ??
                                      "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.priority.level}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: ColorP.textColorSubtitle),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 10.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.task.status.id == StatusEnum.done.id
                        ? Colors.blue.withAlpha(200)
                        : ColorP.ColorD.withAlpha(200),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white70,
                    ),
                  ),
                  child: Text(
                    widget.task.status.name,
                    style: const TextStyle(color: ColorP.textColor),
                  ),
                ),
              ),
            ],
          ),
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
