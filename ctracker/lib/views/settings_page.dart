import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ctracker/constant/values.dart';

class SettingsView extends StatefulWidget {
  final Function(Locale) changeLanguage;
  const SettingsView({super.key, required this.changeLanguage});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  int workingMinutes = ValuesConst.workingMinutes;
  int shortRestMinutes = ValuesConst.shortRestMinutes;
  int longRestMinutes = ValuesConst.longRestMinutes;
  int second = ValuesConst.second;
  MyLocalizations? localizations;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorP.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Card(
                      elevation: 2,
                      color: ColorP.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(80.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildNumberPicker(
                              localizations?.translate("workTimeMessage") ?? "",
                              workingMinutes,
                              (value) => setState(() => workingMinutes = value),
                            ),
                            buildNumberPicker(
                              localizations?.translate("shortRest") ?? "",
                              shortRestMinutes,
                              (value) =>
                                  setState(() => shortRestMinutes = value),
                            ),
                            buildNumberPicker(
                              localizations?.translate("longRest") ?? "",
                              longRestMinutes,
                              (value) =>
                                  setState(() => longRestMinutes = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 32.0,
                  right: 32.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorP.ColorD,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10), // button padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // rounded corners
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      saveSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                localizations?.translate("saveS") ?? "",
                                style: const TextStyle(
                                    color:
                                        Color.fromARGB(255, 255, 255, 255)))),
                      );
                    },
                    child: Text(
                      localizations?.translate("save") ?? "",
                      style: const TextStyle(
                          fontSize: 18, color: ColorP.textColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ValuesConst.boxSeparatorSize),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                localizations?.translate('localization') ?? "",
                style: const TextStyle(
                    color: ColorP.textColorSubtitle, fontSize: 14),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: ColorP.cardBackground,
              ),
              child: DropdownButtonFormField(
                value: Localizations.localeOf(context),
                borderRadius: BorderRadius.circular(20.0),
                onChanged: (Locale? newValue) {
                  if (newValue != null) {
                    widget.changeLanguage(
                        newValue); // Pass selected locale back to parent
                  }
                },
                items: <Locale>[
                  const Locale('en', 'US'),
                  const Locale('es', 'ES'),
                ].map<DropdownMenuItem<Locale>>((Locale value) {
                  String languageName =
                      value.languageCode == 'en' ? 'English' : 'Spanish';
                  return DropdownMenuItem<Locale>(
                    value: value,
                    child: Text(
                      languageName,
                      style: const TextStyle(
                        color: ColorP.textColor, // Change color as needed
                      ),
                    ),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  filled: true,
                  fillColor: ColorP.cardBackground,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: ValuesConst.boxSeparatorSize),
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
            border: Border.all(color: ColorP.textColorSubtitle),
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
