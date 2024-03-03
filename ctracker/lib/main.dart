import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/string.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const appTitle = Strings.appName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
            bodyColor: ColorConst.textColor,
            displayColor: ColorConst.textColor,
            fontFamily: 'Poppins'),
      ),
      home: const HomePage(),
    );
  }
}
