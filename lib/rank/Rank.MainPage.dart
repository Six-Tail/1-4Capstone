import 'package:flutter/material.dart';

class User {
  final String name;
  final int level;
  final int rank;

  User({required this.name, required this.level, required this.rank});
}


// 샘플 사용자 데이터
List<User> users = [
  User(name: "경쾌한 콜리", level: 10, rank: 1),
  User(name: "깜찍한 강아지", level: 9, rank: 2),
  User(name: "섬세한 허브", level: 8, rank: 3),
  User(name: "정교한 산수유", level: 8, rank: 4),
  User(name: "특별한 브런치", level: 7, rank: 5),
  User(name: "무서운 불독", level: 1, rank: 64574),
];

void main() {
  runApp(MaterialApp(
    home: RankingPage(),
  ));
}

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("랭킹"),
      ),
      body: ListView(
        children: [
          // TOP 100 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "TOP 100",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
            itemCount: 5, // 상위 5명만 표시
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  leading: Text(
                    user.rank.toString(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  title: Text(user.name),
                  subtitle: Text("레벨: ${user.level}"),
                  trailing: Icon(Icons.emoji_events), // 우승 메달 표시
                ),
              );
            },
          ),
          Divider(),
          // 내 순위 섹션
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "내 순위",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              leading: Text(
                users[5].rank.toString(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              title: Text(users[5].name),
              subtitle: Text("레벨: ${users[5].level}"),
              trailing: Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }
}
