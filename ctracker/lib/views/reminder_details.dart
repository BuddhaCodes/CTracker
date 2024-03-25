import 'package:calendar_view/calendar_view.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderDetailsPage extends StatefulWidget {
  final int reminderId;

  const ReminderDetailsPage({super.key, required this.reminderId});

  @override
  _ReminderDetailsPageState createState() => _ReminderDetailsPageState();
}

class _ReminderDetailsPageState extends State<ReminderDetailsPage> {
  late Future<Reminder?> _reminderFuture;

  @override
  void initState() {
    super.initState();
    _reminderFuture = fetchReminderFromDatabase(widget.reminderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _reminderFuture,
        builder: (BuildContext context, AsyncSnapshot<Reminder?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              Reminder? reminder = snapshot.data;
              if (reminder != null) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return buildSingleColumnLayout(reminder, true);
                    } else {
                      return buildTwoColumnLayout(reminder);
                    }
                  },
                );
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            }
          }
        },
      ),
    );
  }

  Future<Reminder?> fetchReminderFromDatabase(int reminderId) {
    return Future.delayed(const Duration(seconds: 2), () {
      return ReminderData.getById(reminderId);
    });
  }

  Widget buildSingleColumnLayout(Reminder reminder, bool smallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ColorP.ColorC,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          reminder.categories.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .black, // Using the textColor from the palette
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reminder.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors
                            .black, // Using the textColor from the palette
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!smallScreen)
                      SizedBox(
                        width: 500,
                        height: 500,
                        child: MonthView(
                          controller: EventController()
                            ..add(
                              CalendarEventData(
                                date: reminder.duedate,
                                title: reminder.title,
                                description: reminder.description,
                                startTime: DateTime(
                                    reminder.duedate.year,
                                    reminder.duedate.month,
                                    reminder.duedate.day,
                                    reminder.duedate.hour,
                                    reminder.duedate.minute),
                                endTime: DateTime(
                                    reminder.duedate.year,
                                    reminder.duedate.month,
                                    reminder.duedate.day),
                              ),
                            ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTwoColumnLayout(Reminder reminder) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: buildSingleColumnLayout(reminder, true),
        ),
        const VerticalDivider(
          thickness: 1,
          color: ColorP.textColorSubtitle,
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    width: 500,
                    height: 800,
                    child: MonthView(
                      onEventTap: (events, date) => {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Reminders'),
                              content: Text("${events.description}"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      },
                      controller: EventController()
                        ..add(
                          CalendarEventData(
                            date: reminder.duedate,
                            title: reminder.title,
                            description: reminder.description,
                            startTime: DateTime(
                                reminder.duedate.year,
                                reminder.duedate.month,
                                reminder.duedate.day,
                                reminder.duedate.hour,
                                reminder.duedate.minute),
                            endTime: DateTime(reminder.duedate.year,
                                reminder.duedate.month, reminder.duedate.day),
                          ),
                        ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
