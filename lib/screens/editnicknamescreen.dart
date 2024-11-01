import 'package:flutter/material.dart';

class EditNicknameScreen extends StatefulWidget {
  @override
  _EditNicknameScreenState createState() => _EditNicknameScreenState();
}

class _EditNicknameScreenState extends State<EditNicknameScreen> {
  TextEditingController _nicknameController = TextEditingController();
  int _nicknameLength = 0; // 닉네임 글자 수

  @override
  void initState() {
    super.initState();
    _nicknameController.text = '정세운'; // 기본 닉네임 설정
    _nicknameLength = _nicknameController.text.length;

    _nicknameController.addListener(() {
      setState(() {
        _nicknameLength = _nicknameController.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoBest계정'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ToDoBest계정 프로필을 설정해 주세요.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text('닉네임', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            TextField(
              controller: _nicknameController,
              maxLength: 20, // 닉네임 최대 길이 제한
              decoration: InputDecoration(
                hintText: '닉네임 입력',
                counterText: '$_nicknameLength/20',
                suffixIcon: _nicknameController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _nicknameController.clear();
                  },
                )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.yellow, // 버튼 텍스트 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 크기
                ),
                onPressed: () {
                  // 닉네임 저장 로직
                  Navigator.pop(context, _nicknameController.text);
                },
                child: Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
