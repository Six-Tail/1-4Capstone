import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/User_Service.dart';

class AppUser {
  final String uid;  // UID 필드 추가
  final String name;
  final int level;
  final int currentExp;
  final int rank;
  final String profileImageUrl;

  AppUser({
    required this.uid,  // 생성자에서 UID를 받도록 수정
    required this.name,
    required this.level,
    required this.currentExp,
    required this.rank,
    required this.profileImageUrl,
  });

  // copyWith 메서드
  AppUser copyWith({
    String? uid,
    String? name,
    int? level,
    int? currentExp,
    int? rank,
    String? profileImageUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,  // copyWith에서 UID를 수정할 수 있도록 추가
      name: name ?? this.name,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      rank: rank ?? this.rank,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}


class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("랭킹"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<AppUser>>(
        future: userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('사용자 데이터가 없습니다.'));
          }

          List<AppUser> users = snapshot.data!;
          users.sort((a, b) {
            int levelComparison = b.level.compareTo(a.level);
            if (levelComparison != 0) return levelComparison;

            return b.currentExp.compareTo(a.currentExp);
          });

          List<AppUser> topThreeUsers = users.take(3).toList();
          List<AppUser> remainingUsers = users.skip(3).take(97).toList();

          // 현재 사용자 데이터를 UID를 통해 찾기
          AppUser? currentUserData = users.firstWhere(
                (user) => user.uid == currentUser?.uid,  // user.uid를 사용하여 현재 사용자 UID와 비교
            orElse: () => AppUser(
              uid: 'Unknown',
              name: currentUser?.displayName ?? 'Unknown',
              level: 1,
              currentExp: 0,
              rank: 0,
              profileImageUrl: userService.defaultProfileImageUrl,
            ),
          );

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Center(
                  child: Text(
                    "TOP 3",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      left: MediaQuery.of(context).size.width / 3,
                      child: Container(width: 1, height: 200, color: Colors.grey),
                    ),
                    Positioned(
                      right: MediaQuery.of(context).size.width / 3,
                      child: Container(width: 1, height: 200, color: Colors.grey),
                    ),
                    if (topThreeUsers.length > 2) ...[
                      Positioned(
                        bottom: 0,
                        right: 40,
                        child: Column(
                          children: [
                            CircleAvatar(radius: 20, backgroundImage: NetworkImage(topThreeUsers[2].profileImageUrl)),
                            const SizedBox(height: 4),
                            Text(
                              topThreeUsers[2].name.length > 4 ? '${topThreeUsers[2].name.substring(0, 4)}...' : topThreeUsers[2].name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFCD7F32)),
                            ),
                            Text("레벨: ${topThreeUsers[2].level}"),
                            Text("경험치: ${_formatExperience(topThreeUsers[2].currentExp)}"),
                          ],
                        ),
                      ),
                    ],
                    if (topThreeUsers.length > 1) ...[
                      Positioned(
                        bottom: 20,
                        left: 40,
                        child: Column(
                          children: [
                            CircleAvatar(radius: 25, backgroundImage: NetworkImage(topThreeUsers[1].profileImageUrl)),
                            const SizedBox(height: 4),
                            Text(
                              topThreeUsers[1].name.length > 4 ? '${topThreeUsers[1].name.substring(0, 4)}...' : topThreeUsers[1].name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC0C0C0)),
                            ),
                            Text("레벨: ${topThreeUsers[1].level}"),
                            Text("경험치: ${_formatExperience(topThreeUsers[1].currentExp)}"),
                          ],
                        ),
                      ),
                    ],
                    if (topThreeUsers.isNotEmpty) ...[
                      Positioned(
                        bottom: 40,
                        child: Column(
                          children: [
                            CircleAvatar(radius: 30, backgroundImage: NetworkImage(topThreeUsers[0].profileImageUrl)),
                            const SizedBox(height: 4),
                            Text(
                              topThreeUsers[0].name.length > 4 ? '${topThreeUsers[0].name.substring(0, 4)}...' : topThreeUsers[0].name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                            ),
                            Text("레벨: ${topThreeUsers[0].level}"),
                            Text("경험치: ${_formatExperience(topThreeUsers[0].currentExp)}"),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  itemCount: remainingUsers.length,
                  itemBuilder: (context, index) {
                    final user = remainingUsers[index];
                    return Card(
                      child: ListTile(
                        leading: Text((index + 4).toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        title: Text(user.name),
                        subtitle: Text("레벨: ${user.level}, 경험치: ${_formatExperience(user.currentExp)}"),
                        trailing: const Icon(Icons.emoji_events),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  "내 순위",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Text(currentUserData.rank.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  title: Text(currentUserData.name),
                  subtitle: Text("레벨: ${currentUserData.level}, 경험치: ${_formatExperience(currentUserData.currentExp)}"),
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

// 경험치 포맷팅 함수
String _formatExperience(int exp) {
  if (exp < 10000) return exp.toString();
  if (exp < 100000000) return '${(exp / 10000).toStringAsFixed(1)}만';
  if (exp < 1000000000000) return '${(exp / 100000000).toStringAsFixed(1)}억';
  return '${(exp / 1000000000000).toStringAsFixed(1)}조';
}
