import 'package:flutter/material.dart';
import '../service/User_Service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BirthdaySelectionScreen extends StatefulWidget {
  const BirthdaySelectionScreen({super.key});

  @override
  _BirthdaySelectionScreenState createState() => _BirthdaySelectionScreenState();
}

class _BirthdaySelectionScreenState extends State<BirthdaySelectionScreen> {
  int _selectedYear = 2000;
  int _selectedMonth = 1;
  int _selectedDay = 1;

  final UserService _userService = UserService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  // 생일 업데이트 함수
  Future<void> _updateBirthday() async {
    if (_firebaseUser != null) {
      String birthday = '$_selectedYear년 $_selectedMonth월 $_selectedDay일';

      // Firebase에 생일 업데이트
      await _userService.updateUserInfo(_firebaseUser.uid, birthday: birthday);

      // 위젯이 여전히 활성 상태인지 확인 후 화면 닫기
      if (mounted) {
        Navigator.pop(context, birthday); // 새로운 생일 정보 전달하며 화면 닫기
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면 탭 시 키보드 숨김
      },
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: const Text('생일 선택', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '생일을 알려 주세요.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  // 생일 선택 드롭다운
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<int>(
                        dropdownColor: const Color(0xffffffff), // 드롭다운 메뉴의 배경색 설정
                        value: _selectedYear,
                        items: List.generate(100, (index) => 1920 + index)
                            .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text('$year'),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value!;
                          });
                        },
                      ),
                      DropdownButton<int>(
                        dropdownColor: const Color(0xffffffff), // 드롭다운 메뉴의 배경색 설정
                        value: _selectedMonth,
                        items: List.generate(12, (index) => index + 1)
                            .map((month) => DropdownMenuItem(
                          value: month,
                          child: Text('$month'),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMonth = value!;
                          });
                        },
                      ),
                      DropdownButton<int>(
                        dropdownColor: const Color(0xffffffff), // 드롭다운 메뉴의 배경색 설정
                        value: _selectedDay,
                        items: List.generate(31, (index) => index + 1)
                            .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text('$day'),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDay = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 저장 버튼
                  GestureDetector(
                    onTap: _updateBirthday,
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.068,
                      width: screenWidth * 0.8,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 3, color: Colors.blue),
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      child: Text(
                        '확인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: screenHeight * 0.022,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
