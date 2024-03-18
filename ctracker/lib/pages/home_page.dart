import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/reminder.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/idea_page.dart';
import 'package:ctracker/views/journal_page.dart';
import 'package:ctracker/views/pomodoro_page.dart';
import 'package:ctracker/views/settings_page.dart';
import 'package:ctracker/views/tracker_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String amountNoted = Utils.getDueRemindersCount().toString();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _reminderDeleteHandler() {
    setState(() {
      amountNoted = Utils.getDueRemindersCount().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getBodyWidget() {
      switch (_selectedIndex) {
        case 0:
          return TrackerPage(onReminderDeleted: _reminderDeleteHandler);
        case 1:
          return const IdeaPage();
        case 2:
          return const PomodoroPage();
        case 3:
          return const JournalPage();
        case 4:
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
            icon: SvgPicture.asset(IconlyC.drawerIcon,
                width: 36,
                height: 36,
                colorFilter:
                    const ColorFilter.mode(ColorConst.white, BlendMode.srcIn)),
          );
        }),
        actions: kIsWeb
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showReminderDialog();
                        },
                        icon: const Icon(
                          Icons.notifications,
                          color: ColorConst.white,
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            amountNoted,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
        backgroundColor: ColorConst.topContainer,
      ),
      body: getBodyWidget(),
      drawer: cDrawer(context),
    );
  }

  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminders'),
          content: SingleChildScrollView(
            child: ListBody(
              children: ReminderData.getAllReminders()
                  .map((reminder) => ListTile(
                        title: Text(reminder.title),
                        subtitle:
                            Text('Due on: ${reminder.duedate.toString()}'),
                      ))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateNotifications() {
    setState(() {});
  }

  Widget cDrawer(BuildContext context) {
    final localizations = MyLocalizations.of(context);
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
                    title: localizations.translate("drawerTracker"),
                    icon: IconlyC.trackerIdle,
                    onTap: () => _onItemTapped(0),
                    selected: _selectedIndex == 0,
                  ),
                  Utils.buildListTile(
                    title: localizations.translate("meetings"),
                    icon: IconlyC.meetingIdle,
                    onTap: () => _onItemTapped(1),
                    selected: _selectedIndex == 1,
                  ),
                  Utils.buildListTile(
                    title: localizations.translate("drawerPomodoro"),
                    icon: IconlyC.pomodoroIdle,
                    onTap: () => _onItemTapped(2),
                    selected: _selectedIndex == 2,
                  ),
                  Utils.buildListTile(
                    title: localizations.translate("journal"),
                    icon: IconlyC.journalIdle,
                    onTap: () => _onItemTapped(3),
                    selected: _selectedIndex == 3,
                  ),
                  Utils.buildListTile(
                    title: localizations.translate("drawerSettings"),
                    icon: IconlyC.settingsIdle,
                    onTap: () => _onItemTapped(4),
                    selected: _selectedIndex == 4,
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
