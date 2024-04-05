import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final List<Reminder> reminders;

  const ReminderCard({super.key, required this.title, required this.reminders});

  @override
  Widget build(BuildContext context) {
    int amount = reminders.length;

    return Card(
      color: ColorP.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Adjust the value as needed
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: ColorP.textColor),
              ),
            ),
          ),
          Text(
            amount.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColorP.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 150,
            ),
          ),
        ],
      ),
    );
  }
}
