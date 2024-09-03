import 'package:flutter/material.dart';

class ChangePhoneNumberScreen extends StatelessWidget {
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전화번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: '새 전화번호',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String newPhoneNumber = _phoneNumberController.text;
                // 여기에서 전화번호 업데이트 로직 추가
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
