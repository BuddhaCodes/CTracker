import 'package:ctracker/components/dialog.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';

class FloatingAdd extends StatelessWidget {
  final Function(bool) onTaskAdded;

  const FloatingAdd({super.key, required this.onTaskAdded});

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddDialog(
              onTaskAdded: onTaskAdded,
            );
          },
        );
      },
      shape: const CircleBorder(),
      tooltip: localizations.translate("add"),
      hoverColor: ColorConst.buttonColor,
      backgroundColor: ColorConst.buttonHoverColor,
      child: const Icon(
        Icons.add,
        color: ColorConst.white,
      ),
    );
  }
}
