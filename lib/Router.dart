import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:todobest_home/community/Community.MainPage.dart';
import 'package:todobest_home/rank/RankMore.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';
import 'package:todobest_home/screens/manage_screen.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    const CalenderScreen(),
    const CommunityMainPage(),
    const RankMore(),
    const ManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        animationDuration: const Duration(milliseconds: 500),
        color: const Color(0xffcae1f6),
        // 네비게이션 바 배경색
        buttonBackgroundColor: const Color(0xff4496de),
        backgroundColor: const Color(0xffffffff),
        // 네비게이션 바 배경색을 설정
        key: _bottomNavigationKey,
        items: <Widget>[
          Icon(
            Icons.calendar_today,
            size: 28,
            color: _selectedIndex == 0
                ? Colors.black
                : const Color(0xff4496de), // 선택된 아이템 색상
          ),
          Icon(
            Icons.dashboard,
            size: 30,
            color: _selectedIndex == 1
                ? Colors.black
                : const Color(0xff4496de), // 선택된 아이템 색상
          ),
          Icon(
            Icons.emoji_events,
            size: 30,
            color: _selectedIndex == 2
                ? Colors.black
                : const Color(0xff4496de), // 선택된 아이템 색상
          ),
          Icon(
            Icons.more_horiz,
            size: 30,
            color: _selectedIndex == 3
                ? Colors.black
                : const Color(0xff4496de), // 선택된 아이템 색상
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
