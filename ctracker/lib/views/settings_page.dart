import 'package:ctracker/constant/color.dart';
import 'package:ctracker/utils/localization.dart';
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
    final localizations = MyLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              color: ColorConst.cardBackground,
              child: Padding(
                padding: const EdgeInsets.all(80.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildNumberPicker(
                      localizations.translate("workTimeMessage"),
                      workingMinutes,
                      (value) => setState(() => workingMinutes = value),
                    ),
                    buildNumberPicker(
                      localizations.translate("shortRest"),
                      shortRestMinutes,
                      (value) => setState(() => shortRestMinutes = value),
                    ),
                    buildNumberPicker(
                      localizations.translate("longRest"),
                      longRestMinutes,
                      (value) => setState(() => longRestMinutes = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ValuesConst.boxSeparatorSize),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.buttonColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20), // button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // rounded corners
                ),
                elevation: 5,
              ),
              onPressed: () {
                saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(localizations.translate("saveS"),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)))),
                );
              },
              child: Text(
                localizations.translate("save"),
                style: const TextStyle(
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
            border: Border.all(color: ColorConst.pomodorSettingsBorder),
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
