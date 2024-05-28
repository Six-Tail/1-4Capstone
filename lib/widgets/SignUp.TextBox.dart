import 'package:flutter/material.dart';

class SignUpTextBox extends StatefulWidget {
  const SignUpTextBox({super.key});

  @override
  _SignUpTextBoxState createState() => _SignUpTextBoxState();
}

class _SignUpTextBoxState extends State<SignUpTextBox> {
  bool _obscureText = true;
  bool isSignUpScreen = true;
  final _formKey = GlobalKey<FormState>();

  String userName = '';
  String userEmail = '';
  String userPassword = '';

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if(isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //이메일 텍스트 박스
          TextFormField(
            key: const ValueKey(2),
            validator: (value) {
              if(value!.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            onSaved: (value) {
              userEmail = value!;
            },
            onChanged: (value) {
              userEmail = value;
            },
            decoration: const InputDecoration(
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
          TextFormField(
            key: const ValueKey(3),
            validator: (value) {
              if(value!.isEmpty || value.length < 6) {
                return 'Password must be at least 6 characters long.';
              }
              return null;
            },
            onSaved: (value) {
              userPassword = value!;
            },
            onChanged: (value) {
              userPassword = value;
            },
            obscureText: _obscureText,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
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
          const SizedBox(height: 20.0),
          //비밀번호 확인 텍스트 박스
          TextFormField(
            key: const ValueKey(3),
            validator: (value) {
              if(value!.isEmpty || value.length < 6) {
                return 'Password must be at least 6 characters long.';
              }
              return null;
            },
            onSaved: (value) {
              userPassword = value!;
            },
            onChanged: (value) {
              userPassword = value;
            },
            obscureText: _obscureText,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.vpn_key),
              hintText: '비밀번호 확인',
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
          //닉네임 텍스트 박스
          TextFormField(
            key: const ValueKey(1),
            validator: (value) {
              if(value!.isEmpty || value.length < 4) {
                return 'Please enter at least 4 character';
              }
              return null;
            },
            onSaved: (value) {
              userName = value!;
            },
            onChanged: (value) {
              userName  = value;
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: '닉네임',
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
        ],
      ),
    );
  }
}
