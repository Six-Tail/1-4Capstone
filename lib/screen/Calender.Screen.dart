import 'package:flutter/material.dart';
import 'package:todobest_home/widgets/LogOut.Button.dart';

class CalenderScreen extends StatelessWidget {
  const CalenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Padding(
            padding: EdgeInsets.all(100.0),
          child: LogOutButton(),
        ),
      ),
    );
  }
}
