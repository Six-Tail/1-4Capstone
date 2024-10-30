import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  GoogleSignInAccount? _currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 관리'),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _handleSignOut,
            ),
        ],
      ),
      body: user != null
          ? Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl ?? ''),
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          ListTile(
            title: Text('전화번호'),
            subtitle: Text('+82 10-2730-4759'),
          ),
          ListTile(
            title: Text('이메일'),
            subtitle: Text(user.email),
          ),
          ListTile(
            title: Text('계정 관리'),
            subtitle: Text('계정 정보를 변경합니다.'),
            onTap: () {
              Navigator.pushNamed(context, '/change-account-settings');
            },
          ),
        ],
      )
          : Center(
        child: ElevatedButton(
          child: Text('구글 로그인'),
          onPressed: _handleSignIn,
        ),
      ),
    );
  }
}
