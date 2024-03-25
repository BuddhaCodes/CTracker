import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/reminder_add_page.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  int index;
  int selectedTile;
  Function(int) onExpanded;
  VoidCallback onDelete;
  ReminderCard(
      {required this.reminder,
      required this.index,
      required this.selectedTile,
      required this.onExpanded,
      required this.onDelete});

  @override
  _ReminderCardState createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
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
            SvgPicture.asset(IconlyC.reminder,
                width: 18,
                height: 18,
                colorFilter:
                    const ColorFilter.mode(ColorP.reminder, BlendMode.srcIn)),
            const SizedBox(
              width: 20,
            ),
            Text(
              widget.reminder.title,
              style: const TextStyle(
                  color: ColorP.textColor, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Utils.updateIcon(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReminderAddPage(
                    onReminderAdded: () => {},
                    uReminder: widget.reminder,
                  ),
                ),
              );
            }),
            Utils.deleteIcon(onPressed: () {
              setState(() {
                ReminderData.delete(widget.reminder.id);
                widget.onDelete();
              });
            }),
          ],
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 95,
                            height: 100,
                            child: DatePicker(
                              height: 100,
                              width: 90,
                              daysCount: 1,
                              widget.reminder.duedate,
                              initialSelectedDate: widget.reminder.duedate,
                              selectionColor: Colors.blue,
                              selectedTextColor: Colors.white,
                              onDateChange: (date) {
                                null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('hh:mm a')
                                .format(widget.reminder.duedate),
                            style: const TextStyle(
                              fontSize: 16,
                              color: ColorP.textColorSubtitle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: RichText(
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
                                  color: ColorP.textColorSubtitle),
                              text: ' ${widget.reminder.description}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        widget.reminder.categories.name,
                        style: TextStyle(
                            color: widget.reminder.categories.color,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
