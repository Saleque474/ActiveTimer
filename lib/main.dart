import 'package:active_timer/timer_body.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ActiveTimerApp());
}

class ActiveTimerApp extends StatelessWidget {
  const ActiveTimerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ActiveTimer(),
    );
  }
}

class ActiveTimer extends StatelessWidget {
  const ActiveTimer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF73d6ff),
      appBar: AppBar(
        title: Text("Active Timer"),
        backgroundColor: Color(0xFF1c7589),
        centerTitle: true,
      ),
      body: Body(),
    );
  }
}
