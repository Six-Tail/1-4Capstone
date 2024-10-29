import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:todobest_home/Setting.MainPage.dart';
import 'package:todobest_home/community/Community.MainPage.dart';
import 'package:todobest_home/rank/RankMore.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';
import 'package:todobest_home/screens/manage_screen.dart';

class RouterPage extends StatefulWidget {
  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    const CalenderScreen(),
    CommunityMainPage(),
    const RankMore(),
    ManageScreen(toggleTheme: (bool) {  }, isDarkMode : false,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Color(0xff73b1e7),
        backgroundColor: const Color(0xffffffff)
        , // 네비게이션 바 배경색을 설정
        key: _bottomNavigationKey,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.chat, size: 30),
          Icon(Icons.star_border, size: 30),
          Icon(Icons.more_horiz, size: 30),
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
