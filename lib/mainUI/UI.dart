import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _page = 0; // 네비게이션 페이지 인덱스
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // 각 페이지에 표시될 위젯 리스트
  List<Widget> _pageOptions = [];

  @override
  void initState() {
    super.initState();
    _pageOptions = [
      _buildCalendarPage(), // 캘린더 화면
      _buildChatPage(),     // 채팅 화면
      _buildFavoritesPage(), // 즐겨찾기 화면
      _buildMorePage(),     // 기타 페이지
    ];
  }

  // 캘린더 페이지 빌드 함수
  Widget _buildCalendarPage() {
    return Column(
      children: [
        // 상단 탭 전환 부분
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _calendarFormat = CalendarFormat.month;
                  });
                },
                child: Text(
                  '월간',
                  style: TextStyle(
                    color: _calendarFormat == CalendarFormat.month
                        ? Colors.blueGrey
                        : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _calendarFormat = CalendarFormat.week;
                  });
                },
                child: Text(
                  '주간',
                  style: TextStyle(
                    color: _calendarFormat == CalendarFormat.week
                        ? Colors.blueGrey
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 캘린더 위젯
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Color(0xff73b1e7),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xff73b1e7),
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 10),
        // 할일 리스트
        Expanded(
          child: ListView(
            children: const [
              TaskTile(task: '운동하기(어깨)', time: '8:00~10:00', isCompleted: true),
              TaskTile(task: '회의 준비', time: '10:30~11:30', isCompleted: false),
              TaskTile(task: '점심 식사', time: '12:00~13:00', isCompleted: false),
            ],
          ),
        ),
      ],
    );
  }

  // 채팅 페이지 (예시)
  Widget _buildChatPage() {
    return const Center(child: Text('채팅 페이지'));
  }

  // 즐겨찾기 페이지 (예시)
  Widget _buildFavoritesPage() {
    return const Center(child: Text('즐겨찾기 페이지'));
  }

  // 기타 페이지 (예시)
  Widget _buildMorePage() {
    return const Center(child: Text('기타 페이지'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My App'), // 앱바 제목
          backgroundColor: const Color(0xff73b1e7),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png', // 여기에 이미지를 넣을 경로를 지정하세요
              fit: BoxFit.cover,
            ),
          ), // 왼쪽에 이미지 삽입
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: const Color(0xffc6dff5), // 네비게이션 바 배경색을 설정
          key: _bottomNavigationKey,
          items: const <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.chat, size: 30),
            Icon(Icons.star_border, size: 30),
            Icon(Icons.more_horiz, size: 30),
          ],
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        body: Container(
          color: const Color(0xffc6dff5), // 전체 배경색을 설정
          child: _pageOptions[_page], // 현재 페이지에 맞는 위젯을 표시
        ),
      ),
    );
  }
}

// 할일 리스트 아이템
class TaskTile extends StatelessWidget {
  final String task;
  final String time;
  final bool isCompleted;

  const TaskTile({super.key, required this.task, required this.time, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            Checkbox(
              value: isCompleted,
              onChanged: (bool? value) {},
              activeColor: const Color(0xff73b1e7),
            ),
          ],
        ),
      ),
    );
  }
}
