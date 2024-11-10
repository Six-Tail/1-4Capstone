import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screen/ChatScreen.dart';
import '../utils/Themes.Colors.dart';
import 'allpost_screen.dart';
import 'comment_screen.dart';
import 'scrap_screen.dart';
import 'writepost_screen.dart';
import 'freeboard_screen.dart';
import 'goalshareboard_screen.dart';
import 'tipboard_screen.dart';
import 'mentoringboard_screen.dart';
import 'promotionboard_screen.dart';
import 'hotboard_screen.dart';
import 'wroteboard_screen.dart';

class CommunityMainPage extends StatefulWidget {
  const CommunityMainPage({super.key});

  @override
  _CommunityMainPageState createState() => _CommunityMainPageState();
}

class _CommunityMainPageState extends State<CommunityMainPage> {
  bool isHotSelected = false;
  bool isMyPostsSelected = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Image.asset(
          'assets/images/icon.png',
          width: screenWidth * 0.12, // 아이콘 크기
          height: screenHeight * 0.12,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffffffff),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline, // 채팅 아이콘 추가
              color: Color(0xff4496de),
              size: 30,
            ),
            onPressed: () {
              // 채팅 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(), // 채팅 화면으로 연결
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
                            Icon(Icons.local_fire_department,
                                size: 40, color: Colors.deepOrange),
                            SizedBox(height: 10),
                            Text('HOT 게시판',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                            builder: (context) =>
                                const WroteBoardScreen(userId: ''),
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
                              padding: EdgeInsets.only(left: 6),
                              // 아이콘을 약간 오른쪽으로 이동
                              child: Icon(Icons.edit_note_sharp,
                                  size: 42, color: Colors.blueAccent),
                            ),
                            SizedBox(height: 10),
                            Text('내가 쓴 글',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                            builder: (context) => const AllPostsScreen(),
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
                            Icon(Icons.paste,
                                size: 40, color: Colors.blueAccent),
                            SizedBox(height: 15),
                            Text('전체 글',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                            Icon(Icons.bookmark_border_outlined,
                                size: 40, color: Color(0xffefe684)),
                            SizedBox(height: 15),
                            Text('스크랩',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                            Icon(Icons.comment,
                                size: 35, color: Colors.blueAccent),
                            SizedBox(height: 15),
                            Text('댓글 단 글',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
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
        backgroundColor: const Color(0xff4496de),
        onPressed: () async {
          Get.to(() => const WritePostScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
