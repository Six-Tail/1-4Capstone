import 'package:flutter/material.dart';

class DailyTasksPage extends StatefulWidget {
  @override
  _DailyTasksPageState createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> {
  List<Task> dailyTasks = [
    Task(name: 'Exercise', isCompleted: false, xp: 50),
    Task(name: 'Read a book', isCompleted: false, xp: 30),
    Task(name: 'Meditation', isCompleted: false, xp: 20),
  ];

  void completeTask(int index) {
    setState(() {
      dailyTasks[index].isCompleted = !dailyTasks[index].isCompleted;
      if (dailyTasks[index].isCompleted) {
        // 경험치 지급 로직 추가
        print('Experience Points Earned: ${dailyTasks[index].xp}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Tasks')),
      body: ListView.builder(
        itemCount: dailyTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dailyTasks[index].name),
            trailing: Checkbox(
              value: dailyTasks[index].isCompleted,
              onChanged: (bool? value) {
                completeTask(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class Task {
  String name;
  bool isCompleted;
  int xp;

  Task({required this.name, required this.isCompleted, required this.xp});
}
