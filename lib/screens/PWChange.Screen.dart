import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';

class PWChangeScreen extends StatefulWidget {
  const PWChangeScreen({super.key});

  @override
  _PWChangeScreenState createState() => _PWChangeScreenState();
}

class _PWChangeScreenState extends State<PWChangeScreen> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  Map<String, dynamic>? _userInfo;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
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
      // Firestore에서 사용자 정보 가져오기
      _userInfo = await _userService.getUserInfo(user.uid) ?? {};

      // Firestore의 'userName'이 없다면 Firebase Auth의 displayName을 사용
      _userInfo!['userName'] ??= user.displayName ?? 'Unknown';
      _userInfo!['userImage'] ??= _userService.defaultProfileImageUrl;
      _userInfo!['email'] ??= user.email ?? '이메일 정보 없음';

      setState(() {}); // 데이터를 불러온 후 UI 업데이트
    }
  }


  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = _auth.currentUser;

        final cred = firebase_auth.EmailAuthProvider.credential(
          email: _userInfo?['email'] ?? "",
          password: _currentPasswordController.text,
        );
        await user?.reauthenticateWithCredential(cred);

        if (_newPasswordController.text == _confirmNewPasswordController.text) {
          await user?.updatePassword(_newPasswordController.text);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _errorMessage = "새 비밀번호가 일치하지 않습니다.";
            _hasError = true;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "비밀번호 변경 실패: $e";
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
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
          title: const Text('비밀번호 변경', style: TextStyle(color: Colors.black)),
        ),
        body: SingleChildScrollView(
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
                    // 현재 비밀번호 입력
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        controller: _currentPasswordController,
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
                          hintText: '현재 비밀번호',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '현재 비밀번호를 입력하세요';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 새 비밀번호 입력
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        controller: _newPasswordController,
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
                          hintText: '새 비밀번호',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '새 비밀번호를 입력하세요';
                          } else if (value.length < 6) {
                            return '비밀번호는 최소 6자 이상이어야 합니다';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 새 비밀번호 확인 입력
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        controller: _confirmNewPasswordController,
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
                          hintText: '새 비밀번호 확인',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '새 비밀번호를 다시 입력하세요';
                          } else if (value != _newPasswordController.text) {
                            return '새 비밀번호가 일치하지 않습니다';
                          }
                          return null;
                        },
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
                      onTap: _changePassword,
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
                          '비밀번호 변경',
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
