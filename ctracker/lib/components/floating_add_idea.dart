import 'package:ctracker/components/idea_dialog.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';

class FloatingAddIdea extends StatelessWidget {
  final Function(bool) onIdeaAdded;

  const FloatingAddIdea({super.key, required this.onIdeaAdded});

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddIdeaDialog(
              onIdeaAdded: onIdeaAdded,
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
