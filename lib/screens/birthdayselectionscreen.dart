// BirthdaySelectionScreen.dart
import 'package:flutter/material.dart';
import '../service/User_Service.dart'; // UserService import
import 'package:firebase_auth/firebase_auth.dart';

class BirthdaySelectionScreen extends StatefulWidget {
  const BirthdaySelectionScreen({super.key});

  @override
  _BirthdaySelectionScreenState createState() => _BirthdaySelectionScreenState();
}

class _BirthdaySelectionScreenState extends State<BirthdaySelectionScreen> {
  int _selectedYear = 2003;
  int _selectedMonth = 4;
  int _selectedDay = 23;

  final UserService _userService = UserService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  // 생일 업데이트 함수
  Future<void> _updateBirthday() async {
    if (_firebaseUser != null) {
      String birthday = '$_selectedYear년 $_selectedMonth월 $_selectedDay일';
      // Firebase에 생일 업데이트
      await _userService.updateUserInfo(_firebaseUser.uid, birthday: birthday);
      Navigator.pop(context, birthday); // 새로운 생일 정보 전달하며 화면 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text('생일 선택'),
        backgroundColor: const Color(0xffffffff),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('생일을 알려 주세요.', style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(100, (index) => 1920 + index)
                      .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((month) => DropdownMenuItem(value: month, child: Text('$month')))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: _selectedDay,
                  items: List.generate(31, (index) => index + 1)
                      .map((day) => DropdownMenuItem(value: day, child: Text('$day')))
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
            Center(
              child: ElevatedButton(
                onPressed: _updateBirthday, // 버튼 클릭 시 생일 업데이트 함수 호출
                child: const Text('확인',style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
