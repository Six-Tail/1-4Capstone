import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Only initialize uni links when there's a login attempt
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
    Get.to(() => const CalenderScreen());
  }

  Future<void> signInWithNaver() async {
    setState(() {
      isLoginAttempt = true; // Set login attempt state to true
    });

    String clientID = '3zEWgueywUQAaMf0tcK7';
    String redirectUri = 'https://us-central1-to-do-best-72308.cloudfunctions.net/naverLoginCallback';
    String state = base64Url.encode(List<int>.generate(16, (_) => Random().nextInt(255)));
    Uri url = Uri.parse('https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$clientID&redirect_uri=$redirectUri&state=$state');
    print("네이버 로그인 열기 & 클라우드 함수 호출");
    await launchUrl(url);

    initUniLinks();
  }

  Future<void> initUniLinks() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) _handleDeepLink(initialLink);

    _linkSubscription = linkStream.listen((String? link) {
      if (isLoginAttempt) { // Check if a login attempt is active
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

      if (kDebugMode) {
        print("name $name");
      }

      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken!).then((value) {
        navigatorToMainPage();
        setState(() {
          isLoginAttempt = false; // Reset login attempt state
        });
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print("error $error");
        }
        setState(() {
          isLoginAttempt = false; // Reset login attempt state
        });
      });
    }
  }

  Future<void> signInWithKakao() async {
    setState(() {
      isLoginAttempt = true; // Set login attempt state to true
    });

    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk().then((value) {
          if (kDebugMode) {
            print('value from kakao $value');
          }
          navigatorToMainPage();
          setState(() {
            isLoginAttempt = false; // Reset login attempt state
          });
        });
        if (kDebugMode) {
          print('카카오톡으로 로그인 성공');
        }
      } catch (error) {
        if (kDebugMode) {
          print('카카오톡으로 로그인 실패 $error');
        }

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          setState(() {
            isLoginAttempt = false; // Reset login attempt state
          });
          return;
        }

        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount().then((value) {
            print('value from kakao $value');
            navigatorToMainPage();
            setState(() {
              isLoginAttempt = false; // Reset login attempt state
            });
          });
          if (kDebugMode) {
            print('카카오계정으로 로그인 성공');
          }
        } catch (error) {
          if (kDebugMode) {
            print('카카오계정으로 로그인 실패 $error');
          }
          setState(() {
            isLoginAttempt = false; // Reset login attempt state
          });
        }
      }
    } else {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        var provider = OAuthProvider('oidc.todobest');
        var credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );
        FirebaseAuth.instance.signInWithCredential(credential);
        navigatorToMainPage();
        setState(() {
          isLoginAttempt = false; // Reset login attempt state
        });
        if (kDebugMode) {
          print('카카오계정으로 로그인 성공');
        }
      } catch (error) {
        if (kDebugMode) {
          print('카카오계정으로 로그인 실패 $error');
        }
        setState(() {
          isLoginAttempt = false; // Reset login attempt state
        });
      }
    }

    initUniLinks();
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
