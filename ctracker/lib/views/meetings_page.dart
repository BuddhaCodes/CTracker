import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/meeting_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/meeting_details.dart';
import 'package:ctracker/views/meetings_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:intl/intl.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  MeetingsPageState createState() => MeetingsPageState();
}

class MeetingsPageState extends State<MeetingsPage> {
  late bool isInitialized = false;
  MyLocalizations? localizations;
  late List<Meeting> meetings;
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  late MeetingRepositoryImplementation meetingRepo;
  late List<NeatCleanCalendarEvent> _eventList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations =
        MyLocalizations.of(context); // Initialize localizations here
  }

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  Future<void> initializeData() async {
    setState(() {
      isInitialized = false;
    });
    meetingRepo = MeetingRepositoryImplementation();
    List<Meeting> fetch = [];

    try {
      fetch = await meetingRepo.getByYearAndMonth(year, month);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
    }
    meetings = fetch;
    setState(() {
      _eventList = meetings.map((meeting) {
        Map<String, dynamic> metadata = {
          'meetId': meeting.id,
          'participants': meeting.participants,
          'content': meeting.content,
        };
        return NeatCleanCalendarEvent(meeting.title,
            startTime: meeting.start_date,
            endTime: meeting.end_date,
            color: Colors.indigo,
            metadata: metadata);
      }).toList();

      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorP.background,
      body: !isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    localizations?.translate('meetingp') ?? "",
                                    style: const TextStyle(
                                      fontSize: 36.0,
                                      color: ColorP.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    localizations?.translate('meetingpsub') ??
                                        "",
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      color: ColorP.textColorSubtitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: ColorP.cardBackground,
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeetingsAddPage(
                                        onMeetAdded: () => {},
                                      ),
                                    ),
                                  ).then((value) => initializeData());
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 650,
                      width: MediaQuery.of(context).size.width * 0.6,
                      color: Colors.white,
                      child: Theme(
                        data: ThemeData(
                          primaryColor: ColorP.ColorC,
                          iconTheme: const IconThemeData(color: ColorP.ColorC),
                          textTheme: Theme.of(context).textTheme.apply(
                              bodyColor: ColorP.ColorC,
                              displayColor: ColorP.ColorC,
                              fontFamily: 'Poppins'),
                        ),
                        child: Calendar(
                          startOnMonday: true,
                          eventsList: _eventList,
                          isExpandable: true,
                          bottomBarColor: ColorP.ColorD,
                          selectedColor: Colors.green,
                          todayColor: Colors.blue,
                          eventColor: Colors.pink,
                          bottomBarArrowColor: ColorP.textColor,
                          eventTileHeight: 60,
                          eventListBuilder: (context, events) {
                            if (events.isNotEmpty) {
                              events = Utils.getObjectsInRange(
                                  events.first.startTime, _eventList);
                            }
                            return Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(0.0),
                                itemBuilder: (BuildContext context, int index) {
                                  final String start = DateFormat('HH:mm')
                                      .format(events[index].startTime)
                                      .toString();
                                  final String end = DateFormat('HH:mm')
                                      .format(events[index].endTime)
                                      .toString();
                                  return SizedBox(
                                    height: 70,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: events[index].wide != null &&
                                                    events[index].wide! == true
                                                ? 25
                                                : 5,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: events[index].isDone
                                                      ? Colors.green
                                                      : events[index].color,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: null,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Expanded(
                                            flex: 60,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(events[index].summary,
                                                      style: const TextStyle(
                                                          color:
                                                              ColorP.ColorC)),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        localizations?.translate(
                                                                'participants') ??
                                                            "",
                                                        style: const TextStyle(
                                                          color: ColorP.ColorC,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Wrap(
                                                          children: [
                                                            for (Participant participant
                                                                in events[index]
                                                                            .metadata?[
                                                                        'participants']
                                                                    as List<
                                                                        Participant>)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0),
                                                                child: Text(
                                                                  participant
                                                                      .name,
                                                                  style: const TextStyle(
                                                                      color: ColorP
                                                                          .ColorC),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 30,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "${localizations?.translate('startdate') ?? ""} $start",
                                                      style: const TextStyle(
                                                          color:
                                                              ColorP.ColorC)),
                                                  Text(
                                                      "${localizations?.translate('enddate') ?? ""} $end",
                                                      style: const TextStyle(
                                                          color:
                                                              ColorP.ColorC)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 30,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Utils.updateIcon(
                                                      onPressed: () async {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MeetingsAddPage(
                                                          onMeetAdded: () => {},
                                                          uMeetingId: events[
                                                                      index]
                                                                  .metadata?[
                                                              "meetId"],
                                                        ),
                                                      ),
                                                    ).then((value) =>
                                                        initializeData());
                                                  }),
                                                  Utils.deleteIcon(
                                                      onPressed: () async {
                                                    try {
                                                      await meetingRepo
                                                          .deleteMeeting(events[
                                                                      index]
                                                                  .metadata?[
                                                              "meetId"]);
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  localizations
                                                                          ?.translate(
                                                                              "error") ??
                                                                      "",
                                                                  style: const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255)))),
                                                        );
                                                      }
                                                    }

                                                    initializeData();
                                                  }),
                                                  Utils.workIcon(onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MeetingDetailsPage(
                                                          meetingId: events[
                                                                      index]
                                                                  .metadata?[
                                                              "meetId"],
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: events.length,
                              ),
                            );
                          },
                          onDateSelected: (value) async {
                            List<Meeting> fetch = [];
                            try {
                              fetch = await meetingRepo.getByYearAndMonth(
                                  value.year, value.month);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          localizations?.translate("error") ??
                                              "",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255)))),
                                );
                              }
                            }
                            setState(() {
                              meetings = fetch;

                              _eventList = meetings.map((meeting) {
                                DateTime endTime = meeting.end_date;
                                Map<String, dynamic> metadata = {
                                  'meetId': meeting.id,
                                  'participants': meeting.participants,
                                  'content': meeting.content,
                                };
                                return NeatCleanCalendarEvent(meeting.title,
                                    startTime: meeting.start_date,
                                    endTime: endTime,
                                    color: Colors.indigo,
                                    metadata: metadata);
                              }).toList();
                            });
                          },
                          locale: 'en',
                          todayButtonText: 'Today',
                          isExpanded: true,
                          expandableDateFormat: 'EEEE, dd. MMMM yyyy',
                          datePickerType: DatePickerType.date,
                          initialDate:
                              DateTime(year, month, DateTime.now().day),
                          hideArrows: false,
                          dayOfWeekStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
