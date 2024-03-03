import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/constant/string.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/pomodoro_page.dart';
import 'package:ctracker/views/settings_page.dart';
import 'package:ctracker/views/tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../components/floating_add.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getBodyWidget() {
      switch (_selectedIndex) {
        case 0:
          return const TrackerPage();
        case 1:
          return PomodoroPage();
        case 2:
          return SettingsView();
        default:
          return Container();
      }
    }

    return Scaffold(
      backgroundColor: ColorConst.background,
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            hoverColor: const Color.fromARGB(48, 255, 255, 255),
            icon: SvgPicture.asset('assets/icons/drawer.svg',
                width: 36, // Adjust the size as needed
                height: 36,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          );
        }),
        backgroundColor: ColorConst.topContainer,
      ),
      body: getBodyWidget(),
      drawer: cDrawer(context),
      floatingActionButton: _selectedIndex == 0 ? const FloatingAdd() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget cDrawer(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 40,
                ),
                children: [
                  Utils.buildListTile(
                    title: Strings.drawerTracker,
                    icon: _selectedIndex == 0
                        ? IconlyC.trackerOn
                        : IconlyC.trackerIdle,
                    onTap: () => _onItemTapped(0),
                    selected: _selectedIndex == 0,
                  ),
                  Utils.buildListTile(
                    title: Strings.drawerPomodoro,
                    icon: _selectedIndex == 1
                        ? IconlyC.pomodoroOn
                        : IconlyC.pomodoroIdle,
                    onTap: () => _onItemTapped(1),
                    selected: _selectedIndex == 1,
                  ),
                  Utils.buildListTile(
                    title: Strings.drawerSettings,
                    icon: _selectedIndex == 2
                        ? IconlyC.settingsOn
                        : IconlyC.settingsIdle,
                    onTap: () => _onItemTapped(2),
                    selected: _selectedIndex == 2,
                  ),
                ],
              ),
            ),
            Utils.renderGestureDetector(context),
          ],
        ),
      ),
    );
  }
}
