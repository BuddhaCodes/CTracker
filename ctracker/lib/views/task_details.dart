import 'package:appflowy_board/appflowy_board.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:ctracker/components/note_board.dart';
import 'package:ctracker/constant/color.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/values.dart';
import 'package:ctracker/models/task.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';

class TaskDetailsPage extends StatefulWidget {
  final int taskId;
  const TaskDetailsPage({super.key, required this.taskId});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late Future<Task?> _taskFuture;
  final AppFlowyBoardController controller = AppFlowyBoardController();
  late AppFlowyBoardScrollController boardController;

  @override
  void initState() {
    super.initState();
    _taskFuture = fetchReminderFromDatabase(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MyLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: _taskFuture,
        builder: (BuildContext context, AsyncSnapshot<Task?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              Task? task = snapshot.data;
              if (task != null) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return buildSingleColumnLayout(task, true);
                    } else {
                      return buildTwoColumnLayout(task);
                    }
                  },
                );
              } else {
                return Center(
                  child: Text(localizations.translate("noData")),
                );
              }
            }
          }
        },
      ),
    );
  }

  Future<Task?> fetchReminderFromDatabase(int taskId) {
    return Future.delayed(const Duration(seconds: 2), () {
      return TaskData.getById(taskId);
    });
  }

  Widget buildSingleColumnLayout(Task task, bool smallScreen) {
    final localizations = MyLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: ColorP.textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          task.category,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          'Difficulty: ${task.difficulty}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.green,
                      child: Center(
                        child: Text(
                          'Priority: ${task.priority}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.orange,
                      child: Center(
                        child: Text(
                          'Effort: ${task.effort} ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (smallScreen)
                      Stack(
                        children: [
                          SizedBox(
                            width: 500,
                            child: Card.filled(
                              elevation: 2,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              child: SizedBox(
                                height: ValuesConst.noteBoardContainer,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: NoteBoard(
                                    task: task,
                                    controller: controller,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16.0,
                            right: 16.0,
                            child: FloatingActionButton(
                              onPressed: () {
                                String title = '';
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          TextField(
                                            decoration: InputDecoration(
                                                labelStyle: const TextStyle(
                                                    color: ColorP.ColorC),
                                                labelText: localizations
                                                    .translate("title")),
                                            onChanged: (value) {
                                              title = value;
                                            },
                                          ),
                                          const SizedBox(
                                              height:
                                                  ValuesConst.boxSeparatorSize),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (title.isNotEmpty) {
                                                final group = AppFlowyGroupData(
                                                    id: title,
                                                    name: title,
                                                    items: []);
                                                controller.addGroup(group);
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text(
                                                localizations.translate("add")),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              backgroundColor: ColorP.buttonColor,
                              child: const Icon(
                                Icons.add,
                                color: ColorP.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (smallScreen)
                      const SizedBox(height: ValuesConst.boxSeparatorSize),
                    if (smallScreen)
                      SizedBox(
                        height: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              const images = <String>[
                                'images/1.png',
                                'images/2.png',
                                'images/3.png',
                              ];
                              return Image.asset(
                                images[index],
                                height: 200,
                                width: 200,
                              );
                            },
                            itemCount: 3,
                            pagination: SwiperPagination(),
                            control: SwiperControl(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTwoColumnLayout(Task task) {
    final localizations = MyLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: buildSingleColumnLayout(task, false),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 500,
                        child: Card.filled(
                          elevation: 2,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: SizedBox(
                            height: ValuesConst.noteBoardContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: NoteBoard(
                                task: task,
                                controller: controller,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: FloatingActionButton(
                          onPressed: () {
                            String title = '';
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TextField(
                                        decoration: InputDecoration(
                                            labelStyle:
                                                TextStyle(color: ColorP.ColorC),
                                            labelText: localizations
                                                .translate("title")),
                                        onChanged: (value) {
                                          title = value;
                                        },
                                      ),
                                      const SizedBox(
                                          height: ValuesConst.boxSeparatorSize),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (title.isNotEmpty) {
                                            final group = AppFlowyGroupData(
                                                id: title,
                                                name: title,
                                                items: []);
                                            controller.addGroup(group);
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text(
                                            localizations.translate("add")),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          backgroundColor: ColorP.buttonColor,
                          child: const Icon(
                            Icons.add,
                            color: ColorP.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ValuesConst.boxSeparatorSize),
                  SizedBox(
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          const images = <String>[
                            'images/1.png',
                            'images/2.png',
                            'images/3.png',
                          ];
                          return Image.asset(
                            images[index],
                            height: 200,
                            width: 200,
                          );
                        },
                        itemCount: 3,
                        pagination: SwiperPagination(),
                        control: SwiperControl(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
