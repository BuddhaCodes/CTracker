import 'dart:io';
import 'dart:typed_data';

import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  //Gesture Detector para cerrar el drawer
  static GestureDetector renderGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: ColorConst.background,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_arrow_left, color: ColorConst.white),
          ],
        ),
      ),
    );
  }

  //Construir elemento del drawer
  static Widget buildListTile({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ValuesConst.tilePaddingHorizontal,
          vertical: ValuesConst.tilePaddingVertical),
      child: ListTile(
        selectedColor: ColorConst.textColor,
        title: Text(
          title,
          selectionColor: ColorConst.textColor,
        ),
        leading: SizedBox(
          height: ValuesConst.tileSeparatorSize,
          width: ValuesConst.tileSeparatorSize,
          child: Image.asset(icon),
        ),
        selected: selected,
        onTap: onTap,
      ),
    );
  }

  static Color getColorFromIcon(String icon) {
    switch (icon) {
      case IconlyC.sad:
        return ColorConst.sadColor;
      case IconlyC.crying:
        return ColorConst.cryingColor;
      case IconlyC.coughing:
        return ColorConst.coughingColor;
      case IconlyC.calm:
        return ColorConst.calmColor;
      case IconlyC.happy:
        return ColorConst.happyColor;
      case IconlyC.angry:
        return ColorConst.angryColor;
      default:
        return ColorConst.white;
    }
  }

  static bool isToday(DateTime dateToCheck) {
    DateTime today = DateTime.now();
    if (dateToCheck.year == today.year &&
        dateToCheck.month == today.month &&
        dateToCheck.day == today.day) {
      return true;
    } else {
      return false;
    }
  }

  bool isInCurrentMonth(DateTime date) {
    DateTime today = DateTime.now();
    return date.year == today.year && date.month == today.month;
  }

  static DataCell buildCell(String item) {
    return DataCell(
        Text(item, style: const TextStyle(color: ColorConst.textColor)));
  }

  static DataColumn buildColumn(String item, {Function(int, bool)? onSort}) {
    return DataColumn(
        label: Text(item, style: const TextStyle(color: ColorConst.textColor)),
        onSort: onSort);
  }

  static IconButton deleteIcon({Function()? onPressed}) {
    return IconButton(
      icon: const Icon(Icons.delete, color: ColorConst.delete),
      onPressed: onPressed,
    );
  }

  static IconButton updateIcon({Function()? onPressed}) {
    return IconButton(
      icon: const Icon(Icons.edit, color: ColorConst.update),
      onPressed: onPressed,
    );
  }

  static IconButton detailsIcon({Function()? onPressed}) {
    return IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.visibility,
          color: ColorConst.buttonColor,
        ));
  }

  // Function to check if the file is an image (you may extend this for other file types)
  static bool _isImageFile(String fileName) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
    return imageExtensions
        .any((extension) => fileName.toLowerCase().endsWith(extension));
  }

  static Future<void> _saveImageToFolder(
      Uint8List bytes, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();

    File destinationFile = File('${directory.path}/$fileName');
    await destinationFile.writeAsBytes(bytes);
  }

  static int getDueRemindersCount() {
    DateTime now = DateTime.now();
    return ReminderData.getAllReminders()
        .where((reminder) =>
            reminder.duedate.year == now.year &&
            reminder.duedate.month == now.month &&
            reminder.duedate.day == now.day)
        .length;
  }

  static Future<void> checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}
