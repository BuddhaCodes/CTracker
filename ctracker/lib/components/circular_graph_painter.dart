import 'dart:math';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';

class CircularGraph extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const CircularGraph({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: Colors.blue,
                ),
                const SizedBox(height: 5),
                Text(localizations.translate('completed')),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: CircularGraphPainter(totalTasks, completedTasks),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: ColorP.ColorD,
                ),
                const SizedBox(height: 5),
                Text(localizations.translate('nocompleted')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CircularGraphPainter extends CustomPainter {
  final int totalTasks;
  final int completedTasks;

  CircularGraphPainter(this.totalTasks, this.completedTasks);

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgCirclePaint = Paint()
      ..color = ColorP.ColorD
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    Paint progressCirclePaint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    double radius = min(size.width, size.height) / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, bgCirclePaint);
    double completedAngle = 0;
    if (totalTasks != 0) {
      completedAngle = (completedTasks / totalTasks) * 2 * pi;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      completedAngle,
      false,
      progressCirclePaint,
    );

    TextSpan span = TextSpan(
      style: const TextStyle(
        color: ColorP.textColor,
        fontSize: 32.0,
      ),
      text: totalTasks == 0 ? "0" : '$completedTasks / $totalTasks',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
