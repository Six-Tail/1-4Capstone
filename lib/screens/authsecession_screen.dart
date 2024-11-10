import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../screen/First.Screen.dart';
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';

class AuthSeccessionScreen extends StatefulWidget {
  const AuthSeccessionScreen({super.key});

  @override
  _AuthSeccessionScreenState createState() => _AuthSeccessionScreenState();
}

class _AuthSeccessionScreenState extends State<AuthSeccessionScreen> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  Map<String, dynamic>? _userInfo;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  String userPassword = '';
  String confirmPassword = '';
  bool _obscureText = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      _userInfo = await _userService.getUserInfo(user.uid);
      _userInfo ??= {};
      _userInfo!['email'] ??= user.email;

      setState(() {});
    }
  }

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  Future<void> _reAuthenticateAndDelete() async {
    if (userPassword != confirmPassword) {
      setState(() {
        _errorMessage = "비밀번호가 일치하지 않습니다.";
        _hasError = true;
      });
      return;
    }

    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: _userInfo!['email'],
        password: userPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      await _deleteAccount();
    } catch (e) {
      setState(() {
        _errorMessage = "재인증에 실패했습니다. 이메일과 비밀번호를 확인하세요.";
        _hasError = true;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _userService.deleteUserData(user.uid);
        await user.delete();

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          Get.offAll(() => const FirstScreen());
        }
      } catch (e) {
        setState(() {
          _errorMessage = "회원 탈퇴 중 오류가 발생했습니다.";
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        appBar: AppBar(
          backgroundColor: const Color(0xffffffff),
          title: const Text('회원 탈퇴', style: TextStyle(color: Colors.black)),
        ),
        body: SingleChildScrollView( // <-- 이 부분을 추가하여 스크롤 가능하게 만듭니다.
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_userInfo != null) ...[
                      CircleAvatar(
                        backgroundImage: NetworkImage(_userInfo!['userImage']),
                        radius: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userInfo!['userName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 70,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 4.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.email, color: Colors.grey),
                            const SizedBox(width: 10),
                            Text(
                              _userInfo!['email'] ?? '이메일 정보를 가져올 수 없습니다.',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        key: const ValueKey(1),
                        focusNode: _passwordFocusNode,
                        onSaved: (value) {
                          userPassword = value!;
                        },
                        onChanged: (value) {
                          userPassword = value;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                        },
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.vpn_key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
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
                    const SizedBox(height: 10.0),
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        key: const ValueKey(2),
                        focusNode: _confirmPasswordFocusNode,
                        onSaved: (value) {
                          confirmPassword = value!;
                        },
                        onChanged: (value) {
                          confirmPassword = value;
                        },
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.vpn_key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          hintText: '비밀번호 확인',
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
                    const SizedBox(height: 20),
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
                        await _reAuthenticateAndDelete();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: screenHeight * 0.068,
                        width: screenWidth * 0.8,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 3, color: Theme1Colors.textColor),
                            borderRadius: BorderRadius.circular(33),
                          ),
                        ),
                        child: Text(
                          '회원 탈퇴',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme1Colors.textColor,
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
      ),
    );
  }
}
