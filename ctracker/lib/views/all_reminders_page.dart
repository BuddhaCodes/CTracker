import 'package:ctracker/components/menu_item.dart';
import 'package:ctracker/components/reminder_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:flutter/material.dart';

class AllRemindersPage extends StatefulWidget {
  final Function onReminderDeleted;
  int selectedIndex;
  bool isInit = false;
  AllRemindersPage({
    super.key,
    required this.onReminderDeleted,
    this.selectedIndex = 0,
  });

  @override
  State<AllRemindersPage> createState() => _AllRemindersPageState();
}

class _AllRemindersPageState extends State<AllRemindersPage> {
  late List<Reminder> reminders;
  int selectedTile = -1;

  @override
  void initState() {
    super.initState();
    widget.isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _onMenuItemClicked(widget.selectedIndex);
      });
      widget.isInit = true;
    });
  }

  void _onMenuItemClicked(int index) {
    setState(() {
      widget.selectedIndex = index;
      selectedTile = -1;
      if (widget.selectedIndex == 0) {
        reminders = ReminderData.getAllReminders();
      }
      if (widget.selectedIndex == 1) {
        reminders = ReminderData.allNeareast();
      }
      if (widget.selectedIndex == 2) {
        reminders = ReminderData.getAllOfToday();
      }
      if (widget.selectedIndex == 3) {
        reminders = ReminderData.getAllOfWeek();
      }
      if (widget.selectedIndex == 4) {
        reminders = ReminderData.getAllOfMonth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorP.background,
        foregroundColor: ColorP.textColor,
      ),
      backgroundColor: ColorP.background,
      body: !widget.isInit
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          MenuItem(
                            text: 'All',
                            isSelected: widget.selectedIndex == 0,
                            onTap: () => _onMenuItemClicked(0),
                          ),
                          MenuItem(
                            text: 'Overdue',
                            isSelected: widget.selectedIndex == 1,
                            onTap: () => _onMenuItemClicked(1),
                          ),
                          MenuItem(
                            text: 'Today',
                            isSelected: widget.selectedIndex == 2,
                            onTap: () => _onMenuItemClicked(2),
                          ),
                          MenuItem(
                            text: 'Current Week',
                            isSelected: widget.selectedIndex == 3,
                            onTap: () => _onMenuItemClicked(3),
                          ),
                          MenuItem(
                            text: 'Current Month',
                            isSelected: widget.selectedIndex == 4,
                            onTap: () => _onMenuItemClicked(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.98,
                      child: SizedBox(
                        height: 500,
                        child: ListView.builder(
                          itemCount: reminders.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ReminderCard(
                              reminder: reminders[index],
                              selectedTile: selectedTile,
                              index: index,
                              onExpanded: (int sel) {
                                setState(() {
                                  selectedTile = sel;
                                });
                              },
                              onDelete: () {
                                widget.onReminderDeleted();
                                _onMenuItemClicked(widget.selectedIndex);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
