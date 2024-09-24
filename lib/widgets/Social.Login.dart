// Social.Login.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http; // http 패키지 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({super.key});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  StreamSubscription<String?>? _linkSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  bool isLoginAttempt = false; // State variable to track login attempt

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate the size for the icons based on the screen width
    final iconSize = screenWidth * 0.14; // Adjust the factor as needed

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
                // Add your Naver login functionality here
                if (kDebugMode) {
                  print('naver');
                }
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
    Get.off(() => const CalenderScreen());
  }

  Future<void> signInWithNaver() async {
    setState(() {
      isLoginAttempt = true; // Set login attempt state to true
    });

    String clientID = '3zEWgueywUQAaMf0tcK7';
    String redirectUri =
        'https://us-central1-to-do-best-72308.cloudfunctions.net/naverLoginCallback';
    String state =
    base64Url.encode(List<int>.generate(16, (_) => Random().nextInt(255)));
    Uri url = Uri.parse(
        'https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$clientID&redirect_uri=$redirectUri&state=$state');
    if (kDebugMode) {
      print("네이버 로그인 열기 & 클라우드 함수 호출");
    }
    await launchUrl(url);

    initUniLinks();
  }

  Future<void> initUniLinks() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) _handleDeepLink(initialLink);

    _linkSubscription = linkStream.listen((String? link) {
      if (isLoginAttempt) {
        _handleDeepLink(link!);
      }
    }, onError: (err, stacktrace) {
      if (kDebugMode) {
        print("딥링크 에러 $err\n$stacktrace");
      }
    });
  }

  Future<void> _handleDeepLink(String link) async {
    if (kDebugMode) {
      print("딥링크 열기 $link");
    }
    final Uri uri = Uri.parse(link);

    if (uri.authority == 'login-callback') {
      String? firebaseToken = uri.queryParameters['firebaseToken'];
      String? name = uri.queryParameters['name'];
      String? profileImage = uri.queryParameters['profileImage'];

      if (firebaseToken != null) {
        await FirebaseAuth.instance
            .signInWithCustomToken(firebaseToken)
            .then((value) {
          navigatorToMainPage();
        }).onError((error, stackTrace) {
          if (kDebugMode) {
            print("error $error");
          }
        });
      } else {
        if (kDebugMode) {
          print("firebaseToken이 null입니다.");
        }
      }
      setState(() {
        isLoginAttempt = false; // Reset login attempt state
      });
    }
  }

  Future<void> signInWithKakao() async {
    setState(() {
      isLoginAttempt = true; // Set login attempt state to true
    });

    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();

      final response = await http.post(
        Uri.parse('https://us-central1-to-do-best-72308.cloudfunctions.net/kakaoLogin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accessToken': token.accessToken,
        }),
      );

      final responseData = jsonDecode(response.body);
      final String? firebaseToken = responseData['firebaseToken']; // Nullable 처리

      if (firebaseToken != null) {
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        navigatorToMainPage();
        if (kDebugMode) {
          print('카카오 로그인 및 Firebase 연동 성공');
        }
      } else {
        if (kDebugMode) {
          print("firebaseToken이 null입니다.");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('카카오 로그인 실패: $error');
      }
    } finally {
      setState(() {
        isLoginAttempt = false; // Reset login attempt state
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoginAttempt = true; // Set login attempt state to true
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      if (googleAuth == null) {
        setState(() {
          isLoginAttempt = false; // Reset login attempt state
        });
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      navigatorToMainPage();
      if (kDebugMode) {
        print('Google 로그인 성공');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Google 로그인 실패 $error');
      }
    } finally {
      setState(() {
        isLoginAttempt = false; // Reset login attempt state
      });
    }
    initUniLinks();
  }
}

class SocialIcon extends StatelessWidget {
  final String assetName;
  final double iconSize;

  const SocialIcon({
    super.key,
    required this.assetName,
    required this.iconSize,
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
