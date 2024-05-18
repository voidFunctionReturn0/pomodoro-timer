import 'package:flutter/material.dart';
import 'package:pomodoro_timer/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Home(),
        ),
      ),
    );
  }
}
