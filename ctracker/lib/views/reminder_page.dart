import 'package:ctracker/components/reminder_layout_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/views/all_reminders_page.dart';
import 'package:ctracker/views/reminder_add_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderPage extends StatefulWidget {
  final Function onReminderDeleted;
  late List<Reminder> reminderCompleted;
  late List<Reminder> reminderRemaining;
  late List<Reminder> reminderOfDay;
  bool isInit = false;

  ReminderPage({super.key, required this.onReminderDeleted});
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  @override
  void initState() {
    super.initState();
    widget.isInit = false;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        widget.reminderCompleted =
            ReminderData.getCompletedRemindersThisMonth();

        widget.reminderRemaining =
            ReminderData.getRemainingRemindersThisMonth();

        widget.reminderOfDay = ReminderData.getAllOfToday(4);
        widget.isInit = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    String formattedDay = DateFormat('dd').format(now);
    String formattedMonth = DateFormat('MMMM yyyy').format(now);

    String weekday = DateFormat('EEEE').format(now);

    return Scaffold(
      backgroundColor: ColorP.background,
      body: !widget.isInit
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      formattedDay,
                                      style: const TextStyle(
                                        fontSize: 64.0,
                                        fontWeight: FontWeight.bold,
                                        color: ColorP.textColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      height: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            formattedMonth,
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              color: ColorP.textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            weekday,
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              color: ColorP.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: const BoxDecoration(
                                        color: ColorP.cardBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReminderAddPage(
                                                onReminderAdded: handle,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(25),
                                        child: const Icon(
                                          Icons.add,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 300,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ReminderCard(
                                      title: 'Completed Reminders',
                                      reminders: widget.reminderCompleted,
                                    ),
                                  ),
                                  Expanded(
                                    child: ReminderCard(
                                      title: 'Remaining Reminders',
                                      reminders: widget.reminderRemaining,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.98,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: ColorP.cardBackground,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllRemindersPage(
                                        onReminderDeleted:
                                            widget.onReminderDeleted,
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      "All reminders",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: ColorP.textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: ColorP.textColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.98,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Next reminders",
                                    style: TextStyle(
                                        color: ColorP.textColor,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 400,
                              child: ListView.builder(
                                itemCount: widget.reminderOfDay.length,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 8,
                                ),
                                itemBuilder: (context, index) => Align(
                                  heightFactor: 0.8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Material(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                        tileColor:
                                            ColorP.ColorsAlternators[index],
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4.0),
                                          child: Text(
                                            widget.reminderOfDay[index].title,
                                            style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: index == 2
                                                    ? Colors.white
                                                    : ColorP.ColorC),
                                          ),
                                        ),
                                        subtitle: Text(
                                          DateFormat("yyyy-MM-dd hh:mm a")
                                              .format(widget
                                                  .reminderOfDay[index]
                                                  .duedate),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: index == 2
                                                      ? Colors.white
                                                      : ColorP.ColorC),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void handle(bool added) {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        widget.isInit = false;
        widget.reminderCompleted =
            ReminderData.getCompletedRemindersThisMonth();

        widget.reminderRemaining =
            ReminderData.getRemainingRemindersThisMonth();

        widget.reminderOfDay = ReminderData.getAllOfToday(4);
        widget.isInit = true;
      });
    });
  }
}
