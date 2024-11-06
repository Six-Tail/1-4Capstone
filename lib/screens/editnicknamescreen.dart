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
    _nicknameController.text = ''; // 초기 사용자 이름 값 설정 (예: 기존 사용자 이름)
  }

  // 사용자 이름 업데이트 함수
  Future<void> _updateUserName() async {
    if (_firebaseUser != null) {
      String newUserName = _nicknameController.text.trim();
      if (newUserName.isNotEmpty) {
        // Firebase에 사용자 이름 업데이트
        await _userService.updateUserInfo(_firebaseUser!.uid, userName: newUserName);
        Navigator.pop(context, newUserName); // 새로운 사용자 이름을 전달하며 화면 닫기
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: Text('사용자 이름 설정'),
          backgroundColor: const Color(0xffffffff),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('사용자 이름을 입력해 주세요.', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _nicknameController,
              maxLength: 20,
              decoration: InputDecoration(hintText: '사용자 이름 입력'),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _updateUserName, // 버튼 클릭 시 사용자 이름 업데이트 함수 호출
                child: Text('저장',style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
