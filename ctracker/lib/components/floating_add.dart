import 'package:ctracker/components/dialog.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:flutter/material.dart';

class FloatingAdd extends StatelessWidget {
  const FloatingAdd({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddDialog();
          },
        );
      },
      shape: const CircleBorder(),
      tooltip: Strings.add,
      hoverColor: ColorConst.sendButtonColor,
      backgroundColor: ColorConst.primary,
      child: const Icon(
        Icons.add,
        color: ColorConst.white,
      ),
    );
  }
}
