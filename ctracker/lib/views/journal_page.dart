import 'package:calendar_view/calendar_view.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/journal.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/jounral_entry_page.dart';
import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late Future<List<Journal>?> _journalFuture;

  List<CalendarEventData> _events = [];

  @override
  void initState() {
    super.initState();
    _journalFuture = fetchReminderFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorP.background,
      body: FutureBuilder(
        future: _journalFuture,
        builder:
            (BuildContext context, AsyncSnapshot<List<Journal>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              List<Journal>? journals = snapshot.data;
              if (journals != null) {
                _events = journals
                    .map((e) => CalendarEventData(
                          title: e.moodIcon,
                          date: e.date,
                        ))
                    .toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SizedBox(
                        width: width * 0.7,
                        child: MonthView(
                          headerStyle: const HeaderStyle(
                            decoration: BoxDecoration(
                              color: ColorP.cardBackground,
                            ),
                            leftIcon: Icon(
                              Icons.arrow_circle_left_outlined,
                              color: ColorP.textColor,
                            ),
                            rightIcon: Icon(
                              Icons.arrow_circle_right_outlined,
                              color: ColorP.textColor,
                            ),
                          ),
                          borderColor: ColorP.textColorSubtitle,
                          controller: EventController()..addAll(_events),
                          cellBuilder: (date, events, isToday, isInMonth) {
                            events = events.reversed.toList();
                            return Container(
                              child: events.isEmpty
                                  ? FilledCell(
                                      highlightColor: ColorP.ColorD,
                                      date: date,
                                      events: events,
                                      titleColor: ColorP.ColorC,
                                      shouldHighlight: isToday,
                                      backgroundColor: isInMonth
                                          ? ColorP.ColorB
                                          : ColorP.ColorB.withOpacity(0.8),
                                    )
                                  : Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5.0),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: const BoxDecoration(
                                                    color: ColorP.ColorB),
                                                child: SingleChildScrollView(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: List.generate(
                                                      events.length,
                                                      (index) =>
                                                          GestureDetector(
                                                        onTap: () => {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => JournalEntryPage(
                                                                    id: journals[
                                                                            index]
                                                                        .id,
                                                                    date: events[
                                                                            index]
                                                                        .date,
                                                                    entryHandle:
                                                                        fetchReminderFromDatabase)),
                                                          ).then((res) =>
                                                              refreshState()),
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Utils
                                                                .getColorFromIcon(
                                                                    events[index]
                                                                        .title),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 2.0,
                                                                  horizontal:
                                                                      3.0),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Image.asset(
                                                                  events[index]
                                                                      .title,
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0),
                                                                  height: 36,
                                                                  width: 36,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          bottom: 5.0,
                                          right: 5.0,
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: FloatingActionButton(
                                              backgroundColor: ColorP.ColorD,
                                              foregroundColor: ColorP.textColor,
                                              elevation: 1,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          JournalEntryPage(
                                                              id: null,
                                                              date: date,
                                                              entryHandle:
                                                                  fetchReminderFromDatabase)),
                                                ).then((res) => refreshState());
                                              },
                                              child: Icon(Icons.add),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                          onCellTap: (events, date) {
                            if (events.isEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => JournalEntryPage(
                                        id: null,
                                        date: date,
                                        entryHandle:
                                            fetchReminderFromDatabase)),
                              ).then((res) => refreshState());
                            } else {
                              null;
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            }
          }
        },
      ),
    );
  }

  Future<List<Journal>?> fetchReminderFromDatabase() {
    return Future.delayed(const Duration(seconds: 2), () {
      return JournalData.getAllJournals();
    });
  }

  void refreshState() {
    setState(() {
      _journalFuture = fetchReminderFromDatabase();
    });
  }
}
