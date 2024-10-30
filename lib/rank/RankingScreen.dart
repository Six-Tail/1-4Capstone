import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth를 사용하기 위해 추가
import '../service/User_Service.dart';

class AppUser {
  final String name;
  final int level;
  final int currentExp;
  final int rank; // 랭크 추가
  final String profileImageUrl; // 프로필 이미지 URL 추가

  AppUser({
    required this.name,
    required this.level,
    required this.currentExp,
    required this.rank,
    required this.profileImageUrl, // 프로필 이미지 URL 초기화
  });

  // copyWith 메서드 추가
  AppUser copyWith({
    String? name,
    int? level,
    int? currentExp,
    int? rank,
    String? profileImageUrl,
  }) {
    return AppUser(
      name: name ?? this.name,
      level: level ?? this.level,
      currentExp: currentExp ?? this.currentExp,
      rank: rank ?? this.rank,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl, // 프로필 이미지 URL 복사
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
        backgroundColor: Colors.white, // 원하는 색상으로 설정
      ),
      backgroundColor: Colors.white,
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

          // 상위 3명 선택
          List<AppUser> topThreeUsers = users.take(3).toList();
          // 4등부터 100등까지의 사용자
          List<AppUser> remainingUsers = users.skip(3).take(97).toList();

          // 현재 사용자의 정보 찾기
          AppUser? currentUserData;
          for (var user in users) {
            if (user.name == currentUser?.displayName) {
              currentUserData = user;
              break;
            }
          }

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
              // 시상대 형태로 상위 3명 표시
              // 시상대 형태로 상위 3명 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 2등 (왼쪽)
                  if (topThreeUsers.length > 1) ...[
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25, // 아이콘 크기 설정
                            backgroundImage: NetworkImage(topThreeUsers[1].profileImageUrl), // 프로필 이미지 사용
                          ),
                          const SizedBox(height: 4), // 아이콘과 이름 사이의 간격 추가
                          Text(
                            topThreeUsers[1].name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFC0C0C0)), // 은색
                          ),
                          Text("레벨: ${topThreeUsers[1].level}"),
                          Text("경험치: ${topThreeUsers[1].currentExp}"), // 경험치 추가
                        ],
                      ),
                    ),
                  ],
                  // 1등 (가운데)
                  if (topThreeUsers.isNotEmpty) ...[
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30, // 아이콘 크기 설정
                            backgroundImage: NetworkImage(topThreeUsers[0].profileImageUrl), // 프로필 이미지 사용
                          ),
                          const SizedBox(height: 4), // 아이콘과 이름 사이의 간격 추가
                          Text(
                            topThreeUsers[0].name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)), // 금색
                          ),
                          Text("레벨: ${topThreeUsers[0].level}"),
                          Text("경험치: ${topThreeUsers[0].currentExp}"), // 경험치 추가
                        ],
                      ),
                    ),
                  ],
                  // 3등 (오른쪽)
                  if (topThreeUsers.length > 2) ...[
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20, // 아이콘 크기 설정
                            backgroundImage: NetworkImage(topThreeUsers[2].profileImageUrl), // 프로필 이미지 사용
                          ),
                          const SizedBox(height: 4), // 아이콘과 이름 사이의 간격 추가
                          Text(
                            topThreeUsers[2].name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFCD7F32)), // 동색
                          ),
                          Text("레벨: ${topThreeUsers[2].level}"),
                          Text("경험치: ${topThreeUsers[2].currentExp}"), // 경험치 추가
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(),
              // 스크롤 영역 줄이기
              SizedBox(
                height: 320, // 원하는 높이로 설정
                child: ListView.builder(
                  itemCount: remainingUsers.length,
                  itemBuilder: (context, index) {
                    final user = remainingUsers[index];
                    return Card(
                      child: ListTile(
                        leading: Text(
                          (index + 4).toString(), // 4등부터 시작하므로 인덱스에 4를 더함
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        title: Text(user.name),
                        subtitle: Text("레벨: ${user.level}, 경험치: ${user.currentExp}"),
                        trailing: const Icon(Icons.emoji_events), // 우승 메달 표시
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // 내 순위 섹션
              const Padding(
                padding: EdgeInsets.all(2.0),
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
