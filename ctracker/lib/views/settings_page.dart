import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ctracker/constant/values.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int workingMinutes = ValuesConst.workingMinutes;
  int shortRestMinutes = ValuesConst.shortRestMinutes;
  int longRestMinutes = ValuesConst.longRestMinutes;
  int second = ValuesConst.second;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              color: ColorConst.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(80.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildNumberPicker(
                      'Working Minutes',
                      workingMinutes,
                      (value) => setState(() => workingMinutes = value),
                    ),
                    buildNumberPicker(
                      'Short Rest Minutes',
                      shortRestMinutes,
                      (value) => setState(() => shortRestMinutes = value),
                    ),
                    buildNumberPicker(
                      'Long Rest Minutes',
                      longRestMinutes,
                      (value) => setState(() => longRestMinutes = value),
                    ),
                    buildNumberPicker(
                      'Seconds',
                      second,
                      (value) => setState(() => second = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ValuesConst.boxSeparatorSize),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20), // button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // rounded corners
                ),
                elevation: 5,
              ),
              onPressed: () {
                saveSettings();
                //Navigator.pop(context);
              },
              child: const Text(
                Strings.save,
                style: TextStyle(
                    fontSize: 24, color: ColorConst.contrastedTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNumberPicker(
      String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 8.0),
        NumberPicker(
          value: value,
          haptics: true,
          minValue: 1,
          maxValue: 60,
          onChanged: onChanged,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Future<void> saveSettings() async {
    ValuesConst.workingMinutes = workingMinutes;
    ValuesConst.shortRestMinutes = shortRestMinutes;
    ValuesConst.longRestMinutes = longRestMinutes;
    ValuesConst.second = second;
    await ValuesConst.saveSettings();
  }
}
