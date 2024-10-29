import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoProfileScreen extends StatefulWidget {
  @override
  _KakaoProfileScreenState createState() => _KakaoProfileScreenState();
}

class _KakaoProfileScreenState extends State<KakaoProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getKakaoProfile();
  }

  Future<void> _getKakaoProfile() async {
    try {
      bool isKakaoTalkInstalled = (await KakaoTalkInstalled()) as bool;
      OAuthToken token = isKakaoTalkInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      User user = await UserApi.instance.me();
      setState(() {
        _user = user;
      });
    } catch (error) {
      print("카카오 로그인 실패: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카카오 프로필 연동')),
      body: _user != null
          ? Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(_user!.kakaoAccount?.profile?.profileImageUrl ?? ''),
            ),
            title: Text(_user!.kakaoAccount?.profile?.nickname ?? ''),
            subtitle: Text(_user!.kakaoAccount?.email ?? ''),
          ),
          ListTile(
            title: Text('전화번호'),
            subtitle: Text('+82 10-2730-4759'),
          ),
          ListTile(
            title: Text('이메일'),
            subtitle: Text(_user!.kakaoAccount?.email ?? ''),
          ),
        ],
      )
          : Center(
        child: ElevatedButton(
          child: Text('카카오 로그인'),
          onPressed: _getKakaoProfile,
        ),
      ),
    );
  }
}

class KakaoTalkInstalled {
}
