import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/meeting.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/views/meetings_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:intl/intl.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  _MeetingsPageState createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  late bool isInitialized = false;
  late List<Meeting> meetings;
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  late List<NeatCleanCalendarEvent> _eventList;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isInitialized = false;
        meetings = MeetingData.getAllMeetingsByMonthAndYear(month, year);
        isInitialized = true;

        _eventList = meetings.map((meeting) {
          DateTime endTime = meeting.duedate.add(meeting.meetingDuration);
          Map<String, dynamic> metadata = {
            'id': meeting.id,
            'participants': meeting.participants,
            'content': meeting.content,
          };
          return NeatCleanCalendarEvent(meeting.title,
              startTime: meeting.duedate,
              endTime: endTime,
              color: Colors.indigo,
              metadata: metadata);
        }).toList();
      });
    });
    super.initState();
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
                            const SizedBox(
                              height: 90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Meetings",
                                    style: TextStyle(
                                      fontSize: 36.0,
                                      color: ColorP.textColor,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "Planification is important",
                                    style: TextStyle(
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
                                        onMeetAdded: handleTaskAdded,
                                      ),
                                    ),
                                  );
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
                      height: 1012,
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
                            return SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(0.0),
                                itemBuilder: (BuildContext context, int index) {
                                  final NeatCleanCalendarEvent event =
                                      events[index];
                                  final String start = DateFormat('HH:mm')
                                      .format(event.startTime)
                                      .toString();
                                  final String end = DateFormat('HH:mm')
                                      .format(event.endTime)
                                      .toString();
                                  return Container(
                                    height: 70,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MeetingsAddPage(
                                              onMeetAdded: handleTaskAdded,
                                              uMeeting: MeetingData.getById(
                                                  events[index].metadata?['id']),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: event.wide != null &&
                                                    event.wide! == true
                                                ? 25
                                                : 5,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: event.isDone
                                                      ? Colors.green ??
                                                          Theme.of(context)
                                                              .primaryColor
                                                      : event.color,
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
                                                  Text(event.summary,
                                                      style: TextStyle(
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
                                                        'Participants: ',
                                                        style: TextStyle(
                                                          color: ColorP.ColorC,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Wrap(
                                                          children: [
                                                            for (Participant participant
                                                                in events[index]
                                                                        .metadata?[
                                                                    'participants'])
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
                                                  Text(start,
                                                      style: TextStyle(
                                                          color:
                                                              ColorP.ColorC)),
                                                  Text(end,
                                                      style: TextStyle(
                                                          color:
                                                              ColorP.ColorC)),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                itemCount: events.length,
                              ),
                            );
                          },
                          onDateSelected: (value) {
                            setState(() {
                              meetings =
                                  MeetingData.getAllMeetingsByMonthAndYear(
                                      value.month, value.year);
                              _eventList = meetings.map((meeting) {
                                DateTime endTime = meeting.duedate
                                    .add(meeting.meetingDuration);
                                Map<String, dynamic> metadata = {
                                  'participants': meeting.participants,
                                  'content': meeting.content,
                                };
                                return NeatCleanCalendarEvent(meeting.title,
                                    startTime: meeting.duedate,
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

  void handleTaskAdded(bool success) {
    // if (success) {
    //   setState(() {
    //     isInitialized = false;
    //     Future.delayed(const Duration(seconds: 2), () {
    //       tasks = TaskData.getAllTasks();
    //       totalTaks = TaskData.getTotalTasks();
    //       completedTasks = TaskData.getCompletedTotal();
    //     });
    //     isInitialized = true;
    //   });
    // } else {}
  }
}
