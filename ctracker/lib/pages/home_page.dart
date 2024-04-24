import 'package:ctracker/constant/values.dart';
import 'package:ctracker/views/contacts_page.dart';
import 'package:ctracker/views/journal_overview.dart';
import 'package:ctracker/views/task_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/all_reminders_page.dart';
import 'package:ctracker/views/general_note_page.dart';
import 'package:ctracker/views/idea_page.dart';
import 'package:ctracker/views/journal_page.dart';
import 'package:ctracker/views/meetings_page.dart';
import 'package:ctracker/views/pomodoro_page.dart';
import 'package:ctracker/views/reminder_page.dart';
import 'package:ctracker/views/settings_page.dart';
import 'package:ctracker/views/tracker_page.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) changeLanguage;

  const HomePage({super.key, required this.changeLanguage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorP.background,
      appBar: _buildAppBar(context),
      body: _getBodyWidget(),
      drawer: _buildDrawer(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 5,
      leading: Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          hoverColor: const Color.fromARGB(48, 255, 255, 255),
          icon: SvgPicture.asset(
            IconlyC.drawerIcon,
            width: 36,
            height: 36,
            colorFilter: const ColorFilter.mode(
              ColorP.white,
              BlendMode.srcIn,
            ),
          ),
        );
      }),
      backgroundColor: ColorP.background,
    );
  }

  void _changeLanguage(Locale locale) {
    widget.changeLanguage(locale);
  }

  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return ReminderPage();
      case 1:
        return const TrackerPage();
      case 2:
        return const MeetingsPage();
      case 3:
        return const PomodoroPage();
      case 4:
        return const JournalPage();
      case 5:
        return const GeneralNotes();
      case 6:
        return IdeaPage();
      case 7:
        return SettingsView(changeLanguage: _changeLanguage);
      case 8:
        return const JournalOverview();
      case 9:
        return const TaskOverview();
      case 10:
        return ContactsPage();
      default:
        return Container();
    }
  }

  Widget _buildDrawer(BuildContext context) {
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
                  ExpansionTile(
                    title: Text(localizations.translate("drawerTracker")),
                    leading: const SizedBox(
                      height: ValuesConst.tileSeparatorSize,
                      width: ValuesConst.tileSeparatorSize,
                    ),
                    children: [
                      _buildListTile(
                        title: localizations.translate("manage"),
                        icon: IconlyC.trackerIdle,
                        onTap: () => _onItemTapped(1),
                        selected: _selectedIndex == 1,
                      ),
                      _buildListTile(
                        title: localizations.translate("overview"),
                        icon: IconlyC.overview,
                        onTap: () => _onItemTapped(9),
                        selected: _selectedIndex == 9,
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(localizations.translate("journal")),
                    leading: const SizedBox(
                      height: ValuesConst.tileSeparatorSize,
                      width: ValuesConst.tileSeparatorSize,
                    ),
                    children: [
                      _buildListTile(
                        title: localizations.translate("manage"),
                        icon: IconlyC.journalIdle,
                        onTap: () => _onItemTapped(4),
                        selected: _selectedIndex == 4,
                      ),
                      _buildListTile(
                        title: localizations.translate("overview"),
                        icon: IconlyC.overview,
                        onTap: () => _onItemTapped(8),
                        selected: _selectedIndex == 8,
                      ),
                    ],
                  ),
                  _buildListTile(
                    title: localizations.translate("meetings"),
                    icon: IconlyC.meetingIdle,
                    onTap: () => _onItemTapped(2),
                    selected: _selectedIndex == 2,
                  ),
                  _buildListTile(
                    title: localizations.translate("idea"),
                    icon: IconlyC.ideaIdle,
                    onTap: () => _onItemTapped(6),
                    selected: _selectedIndex == 6,
                  ),
                  _buildListTile(
                    title: localizations.translate("reminders"),
                    icon: IconlyC.reminderIdle,
                    onTap: () => _onItemTapped(0),
                    selected: _selectedIndex == 0,
                  ),
                  _buildListTile(
                    title: localizations.translate("drawerPomodoro"),
                    icon: IconlyC.pomodoroIdle,
                    onTap: () => _onItemTapped(3),
                    selected: _selectedIndex == 3,
                  ),
                  _buildListTile(
                    title: "General Notes",
                    icon: IconlyC.note,
                    onTap: () => _onItemTapped(5),
                    selected: _selectedIndex == 5,
                  ),
                  _buildListTile(
                    title: localizations.translate("contact"),
                    icon: IconlyC.contactsIdle,
                    onTap: () => _onItemTapped(10),
                    selected: _selectedIndex == 10,
                  ),
                  _buildListTile(
                    title: localizations.translate("drawerSettings"),
                    icon: IconlyC.settingsIdle,
                    onTap: () => _onItemTapped(7),
                    selected: _selectedIndex == 7,
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

  Widget _buildListTile({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return Utils.buildListTile(
      title: title,
      icon: icon,
      onTap: onTap,
      selected: selected,
    );
  }
}
