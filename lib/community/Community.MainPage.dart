import 'package:flutter/material.dart';
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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView( // 스크롤 가능하게 만듭니다.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 첫 번째 Row: 기존의 두 개의 박스
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
                            Icon(Icons.local_fire_department, size: 40, color: Colors.deepOrange),
                            SizedBox(height: 30),
                            Text('HOT 게시판', style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,)),
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
                            Icon(Icons.edit_note_sharp, size: 40, color: Colors.blueAccent),
                            SizedBox(height: 30),
                            Text('내가 쓴 글', style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 두 번째 Row: 세 번째 박스는 AllPostsScreen로 이동, 네 번째 박스는 ScrapPage로 이동
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // AllPostsScreen 페이지로 이동
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
                            Icon(Icons.paste, size: 40, color: Colors.purple),
                            SizedBox(height: 30),
                            Text('전체 글',
                                style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
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
                            Icon(Icons.star_border_outlined, size: 40, color: Colors.yellow),
                            SizedBox(height: 30),
                            Text('스크랩', style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,)),
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
                            Icon(Icons.comment, size: 40, color: Colors.teal),
                            SizedBox(height: 30),
                            Text('댓글 단 글', style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 기존의 확장형 게시판 목록
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WritePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
