import 'package:ctracker/components/menu_item.dart';
import 'package:ctracker/components/reminder_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/repository/reminder_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/pocketbase_provider.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
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
  MyLocalizations? localizations;
  bool isLoading = true;
  int selectedTile = -1;
  late ReminderRepositoryImplementation reminderRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  void initState() {
    super.initState();
    widget.isInit = false;
    reminders = [];
    reminderRepo = locator<ReminderRepositoryImplementation>();
    _onMenuItemClicked(widget.selectedIndex);
    widget.isInit = true;
  }

  Future<void> _onMenuItemClicked(int index) async {
    List<Reminder> fetch = [];
    setState(() {
      widget.selectedIndex = index;
      selectedTile = -1;
    });
    if (widget.selectedIndex == 0) {
      try {
        fetch = await reminderRepo.getAllReminder();
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
    if (widget.selectedIndex == 1) {
      try {
        fetch = await reminderRepo.getAllRemindersOfDateToDate(DateTime.now());
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
    if (widget.selectedIndex == 2) {
      try {
        DateTime present = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        fetch = await reminderRepo.getAllRemindersOfDateToDate(present,
            toDate: present.add(const Duration(days: 1)));
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
    if (widget.selectedIndex == 3) {
      try {
        List<DateTime> dates = Utils.getWeekRange(DateTime.now());
        fetch = await reminderRepo.getAllRemindersOfDateToDate(dates.first,
            toDate: dates.elementAt(1));
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
    if (widget.selectedIndex == 4) {
      try {
        fetch = await reminderRepo.getAllRemindersOfDateToDate(
            DateTime(DateTime.now().year, DateTime.now().month, 1),
            toDate: Utils.getLastDayOfMonth(DateTime.now()));
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

    setState(() {
      reminders = fetch;
      isLoading = false;
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
                            text: localizations?.translate('all') ?? "",
                            isSelected: widget.selectedIndex == 0,
                            onTap: () async => await _onMenuItemClicked(0),
                          ),
                          MenuItem(
                            text: localizations?.translate('overdue') ?? "",
                            isSelected: widget.selectedIndex == 1,
                            onTap: () async {
                              await _onMenuItemClicked(1);
                            },
                          ),
                          MenuItem(
                            text: localizations?.translate('today') ?? "",
                            isSelected: widget.selectedIndex == 2,
                            onTap: () async => await _onMenuItemClicked(2),
                          ),
                          MenuItem(
                            text: localizations?.translate('cweek') ?? "",
                            isSelected: widget.selectedIndex == 3,
                            onTap: () async => await _onMenuItemClicked(3),
                          ),
                          MenuItem(
                            text: localizations?.translate('cmonth') ?? "",
                            isSelected: widget.selectedIndex == 4,
                            onTap: () async => await _onMenuItemClicked(4),
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
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
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
