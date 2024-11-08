import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import 추가
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todobest_home/Router.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({super.key});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  StreamSubscription<String?>? _linkSubscription;
  bool isLoginAttempt = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    if (isLoggedIn) {
      navigatorToMainPage();
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.14;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await signInWithGoogle();
              },
              child: SocialIcon(
                assetName: 'assets/images/google.svg',
                iconSize: iconSize,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await signInWithKakao();
              },
              child: SocialIcon(
                assetName: 'assets/images/kakao.svg',
                iconSize: iconSize,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await signInWithNaver();
              },
              child: SocialIcon(
                assetName: 'assets/images/naver.svg',
                iconSize: iconSize,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.03),
        const Text(
          '간편 로그인',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black26,
            fontSize: 13,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }

  void navigatorToMainPage() {
    Get.off(() => RouterPage());
  }

  Future<void> signInWithNaver() async {
    setState(() {
      isLoginAttempt = true;
    });
    String clientID = '3zEWgueywUQAaMf0tcK7';
    String redirectUri =
        'https://us-central1-to-do-best-72308.cloudfunctions.net/naverLoginCallback';
    String state = base64Url.encode(List<int>.generate(16, (_) => Random().nextInt(255)));
    Uri url = Uri.parse(
        'https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$clientID&redirect_uri=$redirectUri&state=$state');

    if (kDebugMode) {
      print("네이버 로그인 요청: $url");
    }

    await launchUrl(url);
    await initUniLinks();
  }

  Future<void> initUniLinks() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) _handleDeepLink(initialLink);
    _linkSubscription = linkStream.listen((String? link) {
      if (isLoginAttempt) {
        _handleDeepLink(link!);
      }
    }, onError: (err) {
      if (kDebugMode) {
        print("딥링크 수신 오류: $err");
      }
    });
  }

  Future<void> _handleDeepLink(String link) async {
    if (kDebugMode) {
      print("딥링크 수신: $link");
    }
    final Uri uri = Uri.parse(link);
    if (uri.authority == 'login-callback') {
      String? firebaseToken = uri.queryParameters['firebaseToken'];
      String? name = uri.queryParameters['name'];
      String? profileImage = uri.queryParameters['profileImage'];

      await firebase_auth.FirebaseAuth.instance.signInWithCustomToken(firebaseToken!).then((value) async {
        final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(name);
          await user.updatePhotoURL(profileImage);

          await saveUserToFirestore(user.uid, name, profileImage,"Naver 계정"); // Firestore에 사용자 정보 저장
          if (kDebugMode) {
            print('네이버 계정 Firestore 저장 성공');
            print("네이버 로그인 성공: ${user.email}, UID: ${user.uid}");
          }
          await _saveLoginState();
          navigatorToMainPage();
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print("네이버 로그인 실패: $error");
        }
        setState(() {
          isLoginAttempt = false;
        });
      });
    }
  }

  Future<void> saveUserToFirestore(String uid, String? name, String? profileImage, String accountType) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await userRef.set({
      'userName': name ?? '',
      'userImage': profileImage ?? '',
      'accountType': accountType,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge: true 옵션 추가

    if (kDebugMode) {
      print("사용자 정보가 Firestore에 저장되었습니다.");
    }
  }


  Future<void> signInWithKakao() async {
    setState(() {
      isLoginAttempt = true;
    });

    if (await kakao.isKakaoTalkInstalled()) {
      try {
        await kakao.UserApi.instance.loginWithKakaoTalk().then((value) async {
          await _handleSuccessfulLogin(value);
        });
      } catch (error) {
        setState(() {
          isLoginAttempt = false;
        });
      }
    } else {
      try {
        kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
        await _handleSuccessfulLogin(token);
      } catch (error) {
        setState(() {
          isLoginAttempt = false;
        });
      }
    }

    try {
      kakao.User user = await kakao.UserApi.instance.me();
      firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (user.kakaoAccount?.email != null) {
          await currentUser.verifyBeforeUpdateEmail(user.kakaoAccount!.email!);
        }
        if (user.kakaoAccount?.profile?.nickname != null) {
          await currentUser.updateDisplayName(user.kakaoAccount!.profile!.nickname!);
        }
        if (user.kakaoAccount?.profile?.profileImageUrl != null) {
          await currentUser.updatePhotoURL(user.kakaoAccount!.profile!.profileImageUrl);
        }
        await saveUserToFirestore(currentUser.uid, user.kakaoAccount?.profile?.nickname, user.kakaoAccount?.profile?.profileImageUrl, "Kakao 계정");
        if (kDebugMode) {
          print('Firebase 사용자 프로필 업데이트 및 Firestore에 저장 완료');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('사용자 정보 요청 또는 Firebase 프로필 업데이트 실패: $error');
      }
    }

  }

  Future<void> _handleSuccessfulLogin(kakao.OAuthToken token) async {
    try {
      var provider = firebase_auth.OAuthProvider('oidc.todobest');
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      await _saveLoginState();

      final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await saveUserToFirestore(user.uid, user.displayName, user.photoURL, "Kakao 계정");
        if (kDebugMode) {
          print('카카오 계정 Firestore 저장 성공');
        }
      }
      navigatorToMainPage();
    } catch (error) {
      setState(() {
        isLoginAttempt = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoginAttempt = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      if (googleAuth == null) {
        setState(() {
          isLoginAttempt = false;
        });
        return;
      }
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      await _saveLoginState();

      final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await saveUserToFirestore(user.uid, user.displayName, user.photoURL, "Google 계정");
        if (kDebugMode) {
          print('구글 계정 Firestore 저장 성공');
        }
      }
      navigatorToMainPage();
    } catch (error) {
      if (kDebugMode) {
        print('Google 로그인 실패 $error');
      }
    }
  }

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await firebase_auth.FirebaseAuth.instance.signOut();
  }
}

class SocialIcon extends StatelessWidget {
  final String assetName;
  final double iconSize;

  const SocialIcon({
    required this.assetName,
    required this.iconSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      width: iconSize,
      height: iconSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 0.6,
          ),
        ],
      ),
      child: SvgPicture.asset(
        assetName,
        fit: BoxFit.cover,
      ),
    );
  }
}
