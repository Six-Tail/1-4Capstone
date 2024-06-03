import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';

import '../utils/Main.Colors.dart';

class LoginTextBox extends StatefulWidget {
  const LoginTextBox({super.key});

  @override
  _LoginTextBoxState createState() => _LoginTextBoxState();
}

class _LoginTextBoxState extends State<LoginTextBox> {
  final _authentication = FirebaseAuth.instance;
  bool isSignupScreen = true;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  String userEmail = '';
  String userPassword = '';
  String _errorMessage = '';
  bool _hasError = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이메일 텍스트 박스
              SizedBox(
                height: 70,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  key: const ValueKey(1),
                  focusNode: _emailFocusNode,
                  onSaved: (value) {
                    userEmail = value!;
                  },
                  onChanged: (value) {
                    userEmail = value;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: '이메일',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 4.0,
                        color: _hasError ? Colors.red : Colors.grey,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 4.0,
                        color: _hasError ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              // 비밀번호 텍스트 박스
              SizedBox(
                height: 70,
                child: TextFormField(
                  key: const ValueKey(2),
                  focusNode: _passwordFocusNode,
                  onSaved: (value) {
                    userPassword = value!;
                  },
                  onChanged: (value) {
                    userPassword = value;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    hintText: '비밀번호',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 4.0,
                        color: _hasError ? Colors.red : Colors.grey,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 4.0,
                        color: _hasError ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Error message display
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              GestureDetector(
                onTap: () async {
                  _tryValidation();

                  try {
                    final newUser =
                    await _authentication.signInWithEmailAndPassword(
                      email: userEmail,
                      password: userPassword,
                    );

                    if (newUser.user != null) {
                      Get.to(() => const CalenderScreen());
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                    setState(() {
                      _errorMessage = '아이디 또는 비밀번호가 일치하지 않습니다.';
                      _hasError = true;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: screenHeight * 0.068,
                  width: screenWidth * 0.8,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 3, color: Color(0xFFFDB082)),
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  child: Text(
                    '로그인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MainColors.textColor,
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
    );
  }
}
