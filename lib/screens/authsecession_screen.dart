import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/First.Screen.dart';
import '../service/User_Service.dart';

class AuthSeccessionScreen extends StatefulWidget {
  @override
  _AuthSeccessionScreenState createState() => _AuthSeccessionScreenState();
}

class _AuthSeccessionScreenState extends State<AuthSeccessionScreen> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  // 컨트롤러 선언
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 회원 탈퇴 기능
  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        // Firestore에서 사용자 데이터 삭제
        await _userService.deleteUserData(user.uid);

        // Firebase Auth에서 사용자 삭제
        await user.delete();

        // SharedPreferences 초기화 (로그인 상태 삭제)
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 성공적으로 탈퇴 후 FirstScreen으로 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => FirstScreen()),
              (Route<dynamic> route) => false,
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("보안을 위해 다시 로그인해 주세요.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("회원 탈퇴 중 오류가 발생했습니다.")),
          );
        }
      } catch (e) {
        print("Error deleting account: $e");
      }
    }
  }

  // 재인증 및 회원 탈퇴 확인
  Future<void> _reAuthenticateAndDelete() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
      );
      return;
    }

    try {
      // 재인증
      final credential = firebase_auth.EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // 재인증 성공 시 회원 탈퇴 실행
      await _deleteAccount();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("재인증에 실패했습니다. 이메일과 비밀번호를 확인하세요.")),
      );
    }
  }

  // 회원 탈퇴 다이얼로그
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '아이디 (이메일)'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호 확인'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _reAuthenticateAndDelete();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 탈퇴'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showDeleteAccountDialog,
          child: const Text('회원 탈퇴'),
        ),
      ),
    );
  }
}
