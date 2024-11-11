import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/User_Service.dart';

class AppUser {
  final String uid; // UID 필드 추가
  final String name;
  final int level;
  final int currentExp;
  final int rank;
  final String profileImageUrl;

  AppUser({
    required this.uid, // 생성자에서 UID를 받도록 수정
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
      uid: uid ?? this.uid,
      // copyWith에서 UID를 수정할 수 있도록 추가
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
        scrolledUnderElevation: 0,
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

          AppUser? currentUserData = users.firstWhere(
            (user) => user.uid == currentUser?.uid,
            orElse: () => AppUser(
              uid: 'Unknown',
              name: currentUser?.displayName ?? 'Unknown',
              level: 1,
              currentExp: 0,
              rank: 0,
              profileImageUrl: userService.defaultProfileImageUrl,
            ),
          );

          Color getRankColor(int rank) {
            switch (rank) {
              case 1:
                return const Color(0xFFFFD700); // 금메달 색상
              case 2:
                return const Color(0xFFC0C0C0); // 은메달 색상
              case 3:
                return const Color(0xFFCD7F32); // 동메달 색상
              default:
                return Colors.black; // 일반 색상
            }
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Center(
                  child: Text(
                    "TOP 3",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (topThreeUsers.length > 1) ...[
                      _buildPlayerCard(
                        user: topThreeUsers[1],
                        color: const Color(0xFFC0C0C0), // 은메달 색상 (2등)
                        radius: 30,
                      ),
                    ],
                    if (topThreeUsers.isNotEmpty) ...[
                      _buildPlayerCard(
                        user: topThreeUsers[0],
                        color: const Color(0xFFFFD700), // 금메달 색상 (1등)
                        radius: 30,
                      ),
                    ],
                    if (topThreeUsers.length > 2) ...[
                      _buildPlayerCard(
                        user: topThreeUsers[2],
                        color: const Color(0xFFCD7F32), // 동메달 색상 (3등)
                        radius: 30,
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
                      color: const Color(0xffcae1f6),
                      child: ListTile(
                        leading: Text((index + 4).toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        title: Text(user.name),
                        subtitle: Text(
                            "레벨: ${user.level}, EXP: ${_formatExperience(user.currentExp)}"),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                color: const Color(0xffcae1f6),
                child: ListTile(
                  leading: Text(
                    currentUserData.rank.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: getRankColor(currentUserData.rank),
                    ),
                  ),
                  title: Text(currentUserData.name),
                  subtitle: Text(
                      "레벨: ${currentUserData.level}, EXP: ${_formatExperience(currentUserData.currentExp)}"),
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

// _buildPlayerCard 메서드 추가
Widget _buildPlayerCard({
  required AppUser user,
  required Color color,
  required double radius,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      border: Border.all(color: color, width: 2), // 테두리 색상을 순위에 맞는 색상으로 설정
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.7), // 그림자 색상을 순위에 맞는 색상으로 설정
          spreadRadius: 4,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    width: 110,
    padding: const EdgeInsets.all(8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(user.profileImageUrl),
        ),
        const SizedBox(height: 4),
        Text(
          user.name.length > 4 ? '${user.name.substring(0, 4)}...' : user.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text("레벨: ${user.level}"),
        Text("EXP: ${_formatExperience(user.currentExp)}"),
      ],
    ),
  );
}

// 경험치 포맷팅 함수
String _formatExperience(int exp) {
  if (exp < 10000) return exp.toString();
  if (exp < 100000000) return '${(exp / 10000).toStringAsFixed(1)}만';
  if (exp < 1000000000000) return '${(exp / 100000000).toStringAsFixed(1)}억';
  return '${(exp / 1000000000000).toStringAsFixed(1)}조';
}
