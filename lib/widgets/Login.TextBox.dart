import 'package:flutter/material.dart';

class LoginTextBox extends StatefulWidget {
  const LoginTextBox({super.key});

  @override
  _LoginTextBoxState createState() => _LoginTextBoxState();
}

class _LoginTextBoxState extends State<LoginTextBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //이메일 텍스트 박스
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              hintText: '이메일',
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(width: 4.0, color: Colors.grey), // 밑줄의 굵기와 색상 설정
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    width: 4.0, color: Colors.black), // 포커스된 밑줄의 굵기와 색상 설정
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          //비밀번호 텍스트 박스
          TextField(
            obscureText: _obscureText,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              hintText: '비밀번호',
              enabledBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(width: 4.0, color: Colors.grey), // 밑줄의 굵기와 색상 설정
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                    width: 4.0, color: Colors.black), // 포커스된 밑줄의 굵기와 색상 설정
              ),
            ),
          ),
        ],
      ),
    );
  }
}
