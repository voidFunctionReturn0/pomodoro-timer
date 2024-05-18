import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomodoro_timer/database_helper.dart';
import 'package:pomodoro_timer/models/timer_item.dart';
import 'package:pomodoro_timer/screens/create_timer_item.dart';
import 'package:vibration/vibration.dart';

class Home extends StatefulWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<TimerItem>> timers;
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  List<TimerItem> timerList = snapshot.data as List<TimerItem>;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: timerList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Center(
                              child: Text("${timerList[index].minutes} min.")),
                          tileColor: (selectedItemIndex == index) &&
                                  (isRunning == false)
                              ? const Color(0xffFFEEF8)
                              : (selectedItemIndex == index) &&
                                      (isRunning == true)
                                  ? const Color(0x55FFEEF8)
                                  : null,
                          textColor: isRunning == false
                              ? const Color(0xff000000)
                              : const Color(0x55000000),
                          enabled: isRunning == true ? false : true,
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
                  isRunning ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 40,
                style: IconButton.styleFrom(side: const BorderSide()),
                onPressed: isRunning ? onPausePressed : onStartPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timersMenu(TimerItem timer, int itemIndex) {
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
        },
      ),
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
    await timers.then((timers) {
      if (timers.isNotEmpty) {
        setState(() {
          selectedItemIndex = index;
          totalSeconds = timers[index].minutes * 60;
        });
      }
    });
  }

  void onStartPressed() {
    Vibration.cancel();
    setState(() {
      isRunning = true;
    });
    onTick();
  }

  void onTick() async {
    if (totalSeconds == 0) {
      isRunning = false;
      setNextTimer();
      Vibration.vibrate(pattern: [1000, 500, 1000, 500]);
    } else if (isRunning) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          totalSeconds = totalSeconds - 1;
        });
        onTick();
      });
    }
  }

  void onPausePressed() {
    Vibration.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void setNextTimer() async {
    timers.then((timers) {
      if (selectedItemIndex == lastIndex(timers)) {
        setState(() {
          setAsyncStates(0);
        });
      } else {
        setState(() {
          setAsyncStates(selectedItemIndex! + 1);
        });
      }
    });
  }

  int lastIndex(List list) {
    return list.length - 1;
  }
}
