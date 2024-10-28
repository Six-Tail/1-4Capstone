import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth를 사용하기 위해 추가
import '../service/User_Service.dart';

class AppUser {
  final String name;
  final int level;
  final int currentExp;
  final int rank; // 랭크 추가

  AppUser({
    required this.name,
    required this.level,
    required this.currentExp,
    required this.rank,
  });

  // copyWith 메서드 추가
  AppUser copyWith({
    String? name,
    int? level,
    int? currentExp,
    int? rank,
  }) {
    return AppUser(
      name: name ?? this.name,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      rank: rank ?? this.rank,
    );
  }
}

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService(); // UserService 인스턴스 생성
    final currentUser = FirebaseAuth.instance.currentUser; // 현재 사용자 가져오기

    return Scaffold(
      appBar: AppBar(
        title: const Text("랭킹"),
      ),
      body: FutureBuilder<List<AppUser>>(
        future: userService.getAllUsers(), // getAllUsers() 메서드가 AppUser 리스트 반환
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('사용자 데이터가 없습니다.'));
          }

          // 사용자 데이터를 레벨과 경험치에 따라 내림차순으로 정렬
          List<AppUser> users = snapshot.data!;
          users.sort((a, b) {
            int levelComparison = b.level.compareTo(a.level);
            if (levelComparison != 0) return levelComparison;

            return b.currentExp.compareTo(a.currentExp);
          });

          // 현재 사용자의 정보 찾기
          AppUser? currentUserData;
          for (var user in users) {
            if (user.name == currentUser?.displayName) {
              currentUserData = user;
              break;
            }
          }

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "TOP 100",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                itemCount: users.length > 5 ? 5 : users.length, // 상위 5명만 표시
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      leading: Text(
                        (index + 1).toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      title: Text(user.name),
                      subtitle: Text("레벨: ${user.level}, 경험치: ${user.currentExp}"),
                      trailing: const Icon(Icons.emoji_events), // 우승 메달 표시
                    ),
                  );
                },
              ),
              const Divider(),
              // 내 순위 섹션
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "내 순위",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Text(
                    currentUserData != null ? currentUserData.rank.toString() : '0',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  title: Text(currentUserData != null ? currentUserData.name : 'Unknown'),
                  subtitle: Text(
                    "레벨: ${currentUserData?.level.toString() ?? '0'}, 경험치: ${currentUserData?.currentExp.toString() ?? '0'}", // 경험치량 추가
                  ),
                  trailing: const Icon(Icons.person),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
