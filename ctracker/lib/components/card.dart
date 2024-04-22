import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class CardWidget extends StatefulWidget {
  final TextItem item;
  final Function() onTap;
  const CardWidget({super.key, required this.item, required this.onTap});

  @override
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardWidget> {
  Color badgeColor = ColorP.ColorD;
  bool isHover = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -10, end: -12),
      showBadge: true,
      ignorePointer: false,
      onTap: widget.onTap,
      badgeContent: const Icon(Icons.close, color: ColorP.textColor, size: 15),
      badgeAnimation: badges.BadgeAnimation.rotation(
        toAnimate: isHover,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: badgeColor,
        padding: const EdgeInsets.all(5),
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.white, width: 2),
        elevation: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Text(
                widget.item.title,
                style: const TextStyle(color: ColorP.textColorSubtitle),
              ),
              const SizedBox(height: 10),
              Text(
                widget.item.subTitle,
                style: const TextStyle(
                    fontSize: 12, color: ColorP.textColorSubtitle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
