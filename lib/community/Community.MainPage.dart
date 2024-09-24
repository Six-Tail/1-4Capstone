import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';
import 'WritePost.Screen.dart';
import 'FreeBoard.Screen.dart';
import 'GoalshareBoard.Screen.dart';
import 'TipBoard.Screen.dart';
import 'MentoringBoard.Screen.dart';
import 'PromotionBoard.Screen.dart';
import 'HotBoard.Screen.dart';
import 'WroteBoard.Screen.dart';

final Map<String, List<Map<String, dynamic>>> boardPosts = {
  '자유 게시판': [],
  '목표 공유 게시판': [],
  '자기계발 팁 게시판': [],
  '멘토링 요청 게시판': [],
  '홍보 게시판': [],
  '내가 쓴 글': [],
};

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
      appBar: AppBar(
        title: const Text('게시판'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => CalenderScreen());
          },
        ),
      ),
      body: Padding(
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
                          builder: (context) => HotBoardScreen(posts: getHotPosts()),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isHotSelected ? Colors.brown.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.whatshot, size: 40, color: Colors.brown),
                          SizedBox(height: 30),
                          Text('HOT 게시판', style: TextStyle(fontSize: 16)),
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
                          builder: (context) => WroteBoardScreen(posts: boardPosts['내가 쓴 글']!),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMyPostsSelected ? Colors.brown.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.notes, size: 40, color: Colors.black),
                          SizedBox(height: 30),
                          Text('내가 쓴 글', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // "게시판" 텍스트와 접기/펼치기 기능 추가 (선 없앰)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  '게시판',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: true,  // 기본값을 펼치기로 설정
                tilePadding: const EdgeInsets.symmetric(horizontal: 0),  // 패딩 조정
                childrenPadding: const EdgeInsets.symmetric(horizontal: 0),  // 패딩 조정
                children: [
                  ListTile(
                    title: const Text('자유 게시판'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FreeBoardScreen(posts: boardPosts['자유 게시판']!),
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
                          builder: (context) => GoalShareBoardScreen(posts: boardPosts['목표 공유 게시판']!),
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
                          builder: (context) => SdTipBoardScreen(posts: boardPosts['자기계발 팁 게시판']!),
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
                          builder: (context) => MentoringBoardScreen(posts: boardPosts['멘토링 요청 게시판']!),
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
                          builder: (context) => PromotionBoardScreen(posts: boardPosts['홍보 게시판']!),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WritePostScreen()),
          );
          if (result != null && result['board'] != null) {
            setState(() {
              boardPosts[result['board']]!.add({
                'title': result['title'],
                'content': result['content'],
                'likes': 0,
                'comments': [], // 댓글 리스트 초기화
              });
              // '내가 쓴 글'에 추가
              boardPosts['내가 쓴 글']!.add({
                'title': result['title'],
                'content': result['content'],
                'likes': 0,
                'comments': [], // 댓글 리스트 초기화
              });
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }



  List<Map<String, dynamic>> getHotPosts() {
    return boardPosts.values
        .expand((posts) => posts)
        .where((post) => post['likes'] >= 10)
        .toList();
  }

  ListTile buildListTile(BuildContext context, String boardName, Widget page) {
    return ListTile(
      title: Text(boardName),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}