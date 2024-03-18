import 'package:appflowy_board/appflowy_board.dart';
import 'package:ctracker/utils/text_item.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class CardWidget extends StatefulWidget {
  final TextItem item;
  final Function() onTap;

  CardWidget({required this.item, required this.onTap});

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  Color badgeColor = Colors.blue;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -10, end: -12),
      showBadge: true,
      ignorePointer: false,
      onTap: widget.onTap,
      badgeContent: MouseRegion(
        onHover: (_) {
          setState(() {
            badgeColor = Colors.orange;
            Future.delayed(const Duration(seconds: 1), () {
              // isHover = true;
              badgeColor = Colors.blue;
            });
          });
        },
        onExit: (_) {
          setState(() {
            badgeColor = Colors.blue;
            Future.delayed(const Duration(seconds: 1), () {
              isHover = false;
            });
          });
        },
        child: Icon(Icons.close, color: Colors.white, size: 15),
      ),
      badgeAnimation: badges.BadgeAnimation.rotation(
        toAnimate: isHover,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: badgeColor,
        padding: EdgeInsets.all(5),
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.white, width: 2),
        elevation: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Text(widget.item.id),
              const SizedBox(height: 10),
              Text(
                widget.item.subTitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ExternalCardWidget extends StatefulWidget {
  final AppFlowyGroupItem item;
  final Function() onTap;

  ExternalCardWidget({required this.item, required this.onTap});

  @override
  _ExternalCardWidgetState createState() => _ExternalCardWidgetState();
}

class _ExternalCardWidgetState extends State<ExternalCardWidget> {
  Color badgeColor = Colors.blue;
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: -10, end: -12),
      showBadge: true,
      ignorePointer: false,
      onTap: widget.onTap,
      badgeContent: MouseRegion(
        onHover: (_) {
          setState(() {
            badgeColor = Colors.orange;
            Future.delayed(const Duration(seconds: 1), () {
              // isHover = true;
              badgeColor = Colors.blue;
            });
          });
        },
        onExit: (_) {
          setState(() {
            badgeColor = Colors.blue;
            Future.delayed(const Duration(seconds: 1), () {
              isHover = false;
            });
          });
        },
        child: Icon(Icons.close, color: Colors.white, size: 15),
      ),
      badgeAnimation: badges.BadgeAnimation.rotation(
        toAnimate: isHover,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: badgeColor,
        padding: EdgeInsets.all(5),
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.white, width: 2),
        elevation: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            children: [
              Text(widget.item.id),
              const SizedBox(height: 10),
              if (widget.item is TextItem)
                Text(
                  (widget.item as TextItem).subTitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (widget.item is IdeaTextItem)
                Text(
                  (widget.item as IdeaTextItem).tags.join(','),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (widget.item is MeetingTextItem)
                Text(
                  'Cantidad de acciones: ${(widget.item as MeetingTextItem).actionItems.length.toString()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
            ],
          ),
        ),
      ),
    );
  }
}
