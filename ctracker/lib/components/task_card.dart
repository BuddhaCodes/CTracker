import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/task_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  int index;
  int selectedTile;
  Function(int) onExpanded;
  VoidCallback onDelete;
  TaskCard(
      {required this.task,
      required this.index,
      required this.selectedTile,
      required this.onExpanded,
      required this.onDelete});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  void initState() {
    super.initState();
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
                    widget.task.hasFinished
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
              );
            }),
            Utils.deleteIcon(onPressed: () {
              setState(() {
                TaskData.delete(widget.task.id);
                widget.onDelete();
              });
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
                                const TextSpan(
                                  text: 'Description:',
                                  style: TextStyle(
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
                              widget.task.category,
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
                                const TextSpan(
                                  text: 'Difficulty:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.difficulty}',
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
                                const TextSpan(
                                  text: 'Effort:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.effort}',
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
                                const TextSpan(
                                  text: 'Priority:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  style: const TextStyle(
                                    color: ColorP.textColorSubtitle,
                                  ),
                                  text: ' ${widget.task.priority}',
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
                    color: widget.task.hasFinished
                        ? Colors.blue.withAlpha(200)
                        : ColorP.ColorD.withAlpha(200),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white70,
                    ),
                  ),
                  child: Text(
                    widget.task.hasFinished ? "Finished" : "Not yet",
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
