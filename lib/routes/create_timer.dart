import 'package:flutter/material.dart';
import 'package:pomodoro_timer/database_helper.dart';
import 'package:pomodoro_timer/models/timer.dart';

class CreateTimer extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController textController = TextEditingController(
    text: "15",
  );

  CreateTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Create a timer"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              int minutes =
                  int.parse(textController.text.replaceAll(RegExp(r"\D"), ""));
              await dbHelper.insertTimer(Timer(minutes: minutes));
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: Center(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: textController,
              ),
            ),
            const Text("min."),
          ],
        ),
      ),
    );
  }
}
