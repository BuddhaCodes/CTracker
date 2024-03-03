import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/values.dart';
import 'package:flutter/material.dart';

/*Utils clase para tener los métodos que generan 
Widgets no asociados a una clase o funciones del sistema*/

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
            Icon(Icons.keyboard_arrow_left, color: Colors.white),
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

  //Crear celda
  static DataCell buildCell(String item) {
    return DataCell(
        Text(item, style: const TextStyle(color: ColorConst.textColor)));
  }

  //Crear columna
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
}
