import 'package:flutter/material.dart';
import '../service/User_Service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenderSelectionScreen extends StatefulWidget {
  final String currentGender;

  const GenderSelectionScreen({super.key, required this.currentGender});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  late String selectedGender;
  final UserService _userService = UserService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면 탭 시 키보드 숨김
      },
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: const Color(0xffffffff),
          title: const Text('성별 선택', style: TextStyle(color: Colors.black)),
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
                    '성별을 알려 주세요.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  // 성별 선택 라디오 버튼
                  RadioListTile<String>(
                    title: const Text('여성'),
                    value: '여성',
                    groupValue: selectedGender,
                    activeColor: Colors.blue, // 체크 표시 색상을 버튼과 동일한 파란색으로 설정
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
                    activeColor: Colors.blue, // 체크 표시 색상을 파란색으로 설정
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
                    activeColor: Colors.blue, // 체크 표시 색상을 파란색으로 설정
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // 확인 버튼
                  GestureDetector(
                    onTap: _updateGender,
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
