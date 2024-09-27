import 'package:flutter/material.dart';

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<Challenge> challenges = [
    Challenge(name: 'Run 10km in one go', isCompleted: false, xp: 500),
    Challenge(name: 'Read 3 books in a week', isCompleted: false, xp: 400),
    Challenge(name: 'Meditate every day for a month', isCompleted: false, xp: 300),
  ];

  void completeChallenge(int index) {
    setState(() {
      challenges[index].isCompleted = !challenges[index].isCompleted;
      if (challenges[index].isCompleted) {
        // 경험치 지급 로직 추가
        print('Experience Points Earned: ${challenges[index].xp}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Challenges')),
      body: ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(challenges[index].name),
            trailing: Checkbox(
              value: challenges[index].isCompleted,
              onChanged: (bool? value) {
                completeChallenge(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class Challenge {
  String name;
  bool isCompleted;
  int xp;

  Challenge({required this.name, required this.isCompleted, required this.xp});
}
