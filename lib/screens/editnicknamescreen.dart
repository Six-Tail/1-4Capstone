// EditNicknameScreen.dart
import 'package:flutter/material.dart';

class EditNicknameScreen extends StatefulWidget {
  @override
  _EditNicknameScreenState createState() => _EditNicknameScreenState();
}

class _EditNicknameScreenState extends State<EditNicknameScreen> {
  TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nicknameController.text = '정세운';
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
                onPressed: () {
                  Navigator.pop(context, _nicknameController.text);
                },
                child: Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
