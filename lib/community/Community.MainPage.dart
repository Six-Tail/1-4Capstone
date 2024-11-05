import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../screen/ChatScreen.dart';
import '../utils/Themes.Colors.dart';
import 'AllpostScreen.dart';
import 'CommentScreen.dart';
import 'ScrapScreen.dart';
import 'WritePost.Screen.dart';
import 'FreeBoard.Screen.dart';
import 'GoalshareBoard.Screen.dart';
import 'TipBoard.Screen.dart';
import 'MentoringBoard.Screen.dart';
import 'PromotionBoard.Screen.dart';
import 'HotBoard.Screen.dart';
import 'WroteBoard.Screen.dart';

class CommunityMainPage extends StatefulWidget {
  @override
  _CommunityMainPageState createState() => _CommunityMainPageState();
}

class _CommunityMainPageState extends State<CommunityMainPage> {
  bool isHotSelected = false;
  bool isMyPostsSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          'ToDoBest',
          style: TextStyle(fontSize: 26, color: Theme1Colors.textColor),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff73b1e7),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/icon.png'),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notification_add,
              color: Colors.greenAccent,
              size: 20,
            ),
            onPressed: () {
              // 알림 버튼의 동작 정의 (필요하다면 추가)
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline, // 채팅 아이콘 추가
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // 채팅 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(), // 채팅 화면으로 연결
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isHotSelected = true;
                          isMyPostsSelected = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotBoardScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 9), // 아이콘 위치 조정
                            Icon(Icons.local_fire_department, size: 40, color: Colors.deepOrange),
                            SizedBox(height: 10),
                            Text('HOT 게시판', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isHotSelected = false;
                          isMyPostsSelected = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WroteBoardScreen(userId: ''),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 6), // 아이콘을 약간 오른쪽으로 이동
                              child: Icon(Icons.edit_note_sharp, size: 42, color: Colors.blueAccent),
                            ),
                            SizedBox(height: 10),
                            Text('내가 쓴 글', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],

                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllPostsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 8),
                            Icon(Icons.paste, size: 40, color: Colors.blueAccent),
                            SizedBox(height: 15),
                            Text('전체 글', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScrapPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 8),
                            Icon(Icons.bookmark_border_outlined, size: 40, color: Color(0xffefe684)),
                            SizedBox(height: 15),
                            Text('스크랩', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentedPostsPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(height: 10),
                            Icon(Icons.comment, size: 35, color: Colors.blueAccent),
                            SizedBox(height: 15),
                            Text('댓글 단 글', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    '게시판',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
                  children: [
                    ListTile(
                      title: const Text('자유 게시판'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreeBoardScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('목표 공유 게시판'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalShareBoardScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('자기계발 팁 게시판'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SdTipBoardScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('멘토링 요청 게시판'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MentoringBoardScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('홍보 게시판'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PromotionBoardScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff73b1e7),
        onPressed: () async {
          Get.to(() => WritePostScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
