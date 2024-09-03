import 'package:flutter/material.dart';

class ChangeEmailScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이메일 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '새 이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String newEmail = _emailController.text;
                // 여기에서 이메일 업데이트 로직 추가
                Navigator.pop(context);
              },
              child: Text('변경'),
            ),
          ],
        ),
      ),
    );
  }
}
