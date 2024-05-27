import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({super.key});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
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
              onTap: () {
                if (kDebugMode) {
                  signInWithGoogle();
                  print('google');
                }
              },
              child: Container(
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
                  'assets/images/google.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (kDebugMode) {
                  print('kakao');
                }
              },
              child: Container(
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
                  'assets/images/kakao.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (kDebugMode) {
                  print('naver');
                }
              },
              child: Container(
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
                  'assets/images/naver.svg',
                  fit: BoxFit.cover,
                ),
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
            // Changed from 0.09 to 1.5 for proper line height
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }
  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      if (kDebugMode) {
        print(value.user?.email);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const CalenderScreen(),
        ));
      }
    }).onError((error, stackTrace){
      if (kDebugMode) {
        print("error $error");
      }
    });
  }
}
