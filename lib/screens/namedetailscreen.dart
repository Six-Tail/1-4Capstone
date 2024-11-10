import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/User_Service.dart';
import 'birthdayselectionscreen.dart';
import 'genderselectionscreen.dart';
import 'editnicknamescreen.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();
  String userName = 'Unknown';
  String gender = '선택안함';
  String birthday = '미설정';
  String phoneNumber = '미설정';
  String profileImageUrl = 'https://example.com/profile_image.jpg';
  User? _firebaseUser;

  @override
  void initState() {
    super.initState();
    _firebaseUser = FirebaseAuth.instance.currentUser;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (_firebaseUser != null) {
      final userInfo = await _userService.getUserInfo(_firebaseUser!.uid);
      if (userInfo != null) {
        setState(() {
          userName = userInfo['userName'] ?? 'Unknown';
          gender = userInfo['gender'] ?? '선택안함';
          birthday = userInfo['birthday'] ?? '미설정';
          phoneNumber = userInfo['phoneNumber'] ?? '미설정';
          profileImageUrl = userInfo['userImage'] ?? profileImageUrl;
        });
      }
    }
  }

  Future<void> _updatePhoneNumber(String newPhoneNumber) async {
    if (_firebaseUser != null) {
      await _userService.updateUserPhoneNumber(_firebaseUser!.uid, newPhoneNumber);
    }
  }

  Future<String?> _showPhoneNumberDialog() async {
    String newPhoneNumber = phoneNumber;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('전화번호 입력'),
          content: TextField(
            onChanged: (value) {
              newPhoneNumber = value;
            },
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: "전화번호를 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(newPhoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      
      try {
        final downloadUrl = await _uploadProfileImage(_firebaseUser!.uid, _profileImage!);
        
        if (downloadUrl != null) {
         // 이미지 URL을 사용자 정보에 업데이트
         await _userService.updateUserInfo(_firebaseUser!.uid, profileImageUrl: downloadUrl);

         setState(() {
           profileImageUrl = downloadUrl; // 프로필 이미지 URL을 업데이트
         });
        } else {
          throw Exception("이미지 업로드 실패");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error uploading image: $e");
        }
      }
    }
  }

  // Firebase Storage에 이미지를 업로드하고 다운로드 URL을 반환하는 함수
  Future<String?> _uploadProfileImage(String userId, File profileImage) async {
    try {
      // Firebase Storage에 업로드할 경로 설정
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('$userId.png');

      // 이미지 파일을 Firebase Storage에 업로드
      await storageRef.putFile(profileImage);

      // 업로드된 이미지의 다운로드 URL 가져오기
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      return null;
    }
  }


  Future<void> _updateUserName(String newUserName) async {
    if (_firebaseUser != null) {
      await _userService.updateUserInfo(_firebaseUser!.uid, userName: newUserName);
    }
  }

  Future<void> _updateBirthday(String newBirthday) async {
    if (_firebaseUser != null) {
      await _userService.updateUserInfo(_firebaseUser!.uid, birthday: newBirthday);
    }
  }

  Future<void> _updateGender(String newGender) async {
    if (_firebaseUser != null) {
      await _userService.updateUserInfo(_firebaseUser!.uid, gender: newGender);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text('내 정보 관리', style: TextStyle(color: Colors.black)), // 텍스트를 검정색으로 설정
        backgroundColor: const Color(0xffffffff),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xffffffff), // 프로필 배경 색상을 하얀색으로 설정
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : NetworkImage(profileImageUrl) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('사용자 이름', style: TextStyle(fontSize: 16, color: Colors.black ,fontWeight: FontWeight.bold)), // 검정색으로 변경
            trailing: Text(userName, style: const TextStyle(fontSize:14 , color: Colors.grey)),
            onTap: () async {
              final newUserName = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditNicknameScreen()),
              );
              if (newUserName != null) {
                setState(() {
                  userName = newUserName;
                });
                await _updateUserName(newUserName);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('생일', style: TextStyle(fontSize: 16, color: Colors.black ,fontWeight: FontWeight.bold)), // 검정색으로 변경
            trailing: Text(birthday, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            onTap: () async {
              final newBirthday = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BirthdaySelectionScreen()),
              );
              if (newBirthday != null) {
                setState(() {
                  birthday = newBirthday;
                });
                await _updateBirthday(newBirthday);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.safety_divider),
            title: const Text('성별', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)), // 검정색으로 변경
            trailing: Text(gender, style: const TextStyle(fontSize: 14,color: Colors.grey)),
            onTap: () async {
              final newGender = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenderSelectionScreen(currentGender: gender)),
              );
              if (newGender != null) {
                setState(() {
                  gender = newGender;
                });
                await _updateGender(newGender);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('전화번호', style: TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.bold)), // 텍스트를 검정색으로 설정
            trailing: Text(phoneNumber, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            onTap: () async {
              final newPhoneNumber = await _showPhoneNumberDialog(); // 전화번호 입력 대화상자 호출
              if (newPhoneNumber != null) {
                setState(() {
                  phoneNumber = newPhoneNumber;
                });
                await _updatePhoneNumber(newPhoneNumber); // 전화번호 업데이트
              }
            },
          ),
        ],
      ),
    );
  }
}
