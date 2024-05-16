// https://github.com/EduardaGarangau/Pomodoro-App?tab=readme-ov-file

import 'package:flutter/material.dart';
import 'package:pomodoro_timer/database_helper.dart';
import 'package:pomodoro_timer/models/timer.dart';
import 'package:pomodoro_timer/routes/create_timer.dart';

class Home extends StatefulWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Timer>> timers;
  int? selectedItemIndex;
  int totalSeconds = 0;
  bool isRunning = false;


  @override
  void initState() {
    super.initState();
    timers = widget.dbHelper.getTimers();
    setAsyncStates(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pomodoro Timer"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTimer(),
                ),
              );
              setState(() {
                timers = widget.dbHelper.getTimers();
                if (selectedItemIndex == null) {
                  setAsyncStates(0);
                }
              });
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          Opacity(
            opacity: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                format(totalSeconds),
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          FutureBuilder(
            future: timers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                List<Timer> timerList = snapshot.data as List<Timer>;
                return Expanded(
                  child: ListView.builder(
                    itemCount: timerList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Center(
                            child: Text("${timerList[index].minutes} min.")),
                        tileColor: selectedItemIndex == index
                            ? const Color(0xffFFEEF8)
                            : null,
                        onTap: () {
                          setAsyncStates(index);
                        },
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    content:
                                        timersMenu(timerList[index], index));
                              });
                        },
                      );
                    },
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: IconButton(
              icon: Icon(
                isRunning ? Icons.stop : Icons.play_arrow,
              ),
              iconSize: 40,
              style: IconButton.styleFrom(side: const BorderSide()),
              onPressed: 
                isRunning ? onPausePressed : onStartPressed,
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget timersMenu(Timer timer, int itemIndex) {
    return SizedBox(
      width: 312,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: const Text("Delete"),
              onTap: () async {
                await widget.dbHelper.deleteTimer(timer.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                }
                setState(() {
                  timers = widget.dbHelper.getTimers();
                  if (itemIndex == 0) {
                    selectedItemIndex = null;
                    totalSeconds = 0;
                  } else if (itemIndex == selectedItemIndex &&
                      selectedItemIndex != null) {
                    setAsyncStates(selectedItemIndex! - 1);
                  }
                });
              },
            );
          }),
    );
  }

  String format(int totalSeconds) {
    return Duration(seconds: totalSeconds)
        .toString()
        .split(".")
        .first
        .substring(2, 7);
  }

  void setAsyncStates(index) async {
    await timers.then((timers) => {
          if (timers.isNotEmpty)
            {
              setState(() {
                selectedItemIndex = index;
                totalSeconds = timers[index].minutes * 60;
              })
            }
        });
  }

  void onPausePressed() {
    //TODO
  }

  void onStartPressed() {
    //TODO
  }
}
