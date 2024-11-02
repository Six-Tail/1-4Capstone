// EditNicknameScreen.dart
import 'package:flutter/material.dart';
import '../service/User_Service.dart'; // UserService import
import 'package:firebase_auth/firebase_auth.dart';

class EditNicknameScreen extends StatefulWidget {
  @override
  _EditNicknameScreenState createState() => _EditNicknameScreenState();
}

class _EditNicknameScreenState extends State<EditNicknameScreen> {
  TextEditingController _nicknameController = TextEditingController();
  final UserService _userService = UserService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = ''; // 초기 닉네임 값 설정 (예: 기존 닉네임)
  }

  // 닉네임 업데이트 함수
  Future<void> _updateNickname() async {
    if (_firebaseUser != null) {
      String newNickname = _nicknameController.text.trim();
      if (newNickname.isNotEmpty) {
        // Firebase에 닉네임 업데이트
        await _userService.updateUserInfo(_firebaseUser!.uid, nickname: newNickname);
        Navigator.pop(context, newNickname); // 새로운 닉네임을 전달하며 화면 닫기
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 설정'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('닉네임을 입력해 주세요.', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _nicknameController,
              maxLength: 20,
              decoration: InputDecoration(hintText: '닉네임 입력'),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _updateNickname, // 버튼 클릭 시 닉네임 업데이트 함수 호출
                child: Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
