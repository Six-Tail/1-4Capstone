// GenderSelectionScreen.dart
import 'package:flutter/material.dart';
import '../service/User_Service.dart'; // UserService import
import 'package:firebase_auth/firebase_auth.dart';

class GenderSelectionScreen extends StatefulWidget {
  final String currentGender;

  const GenderSelectionScreen({super.key, required this.currentGender});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  late String selectedGender;
  final UserService _userService = UserService(); // UserService 인스턴스 생성
  final User? _firebaseUser = FirebaseAuth.instance.currentUser; // 현재 사용자 가져오기

  @override
  void initState() {
    super.initState();
    selectedGender = widget.currentGender;
  }

  Future<void> _updateGender() async {
    if (_firebaseUser != null) {
      // Firebase에 성별 업데이트
      await _userService.updateUserInfo(_firebaseUser.uid, gender: selectedGender);

      // 위젯이 여전히 활성 상태인지 확인 후 화면 닫기
      if (mounted) {
        Navigator.pop(context, selectedGender); // 선택한 성별을 반환하며 화면 닫기
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text('ToDoBest계정'),
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
            const Text(
              '성별을 알려 주세요.',
              style: TextStyle(fontSize: 16),
            ),
            RadioListTile<String>(
              title: const Text('여성'),
              value: '여성',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('남성'),
              value: '남성',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('선택안함'),
              value: '선택안함',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow, // 버튼 텍스트 색상
                  minimumSize: const Size(double.infinity, 50), // 버튼 크기
                ),
                onPressed: _updateGender, // 성별 업데이트 함수 호출
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
