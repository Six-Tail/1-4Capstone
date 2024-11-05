import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/User_Service.dart';
import 'birthdayselectionscreen.dart';
import 'genderselectionscreen.dart';
import 'editnicknamescreen.dart';

class ProfileDetailScreen extends StatefulWidget {
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
          profileImageUrl = userInfo['userImage'] ?? profileImageUrl;
        });
      }
    }
  }

  Future<void> _changeProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      final downloadUrl = await _userService.uploadProfileImage(_firebaseUser!.uid, _profileImage!);
      if (downloadUrl != null) {
        await _userService.updateUserInfo(_firebaseUser!.uid, profileImageUrl: downloadUrl);
        setState(() {
          profileImageUrl = downloadUrl;
        });
      }
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
        title: Text('내 정보 관리', style: TextStyle(color: Colors.black)), // 텍스트를 검정색으로 설정
        backgroundColor: Color(0xffffffff),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
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
          SizedBox(height: 16.0),
          Divider(),
          ListTile(
            title: Text('사용자 이름', style: TextStyle(color: Colors.black)), // 검정색으로 변경
            trailing: Text(userName, style: TextStyle(color: Colors.black)),
            onTap: () async {
              final newUserName = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditNicknameScreen()),
              );
              if (newUserName != null) {
                setState(() {
                  userName = newUserName;
                });
                await _updateUserName(newUserName);
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('생일', style: TextStyle(color: Colors.black)), // 검정색으로 변경
            trailing: Text(birthday, style: TextStyle(color: Colors.black)),
            onTap: () async {
              final newBirthday = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BirthdaySelectionScreen()),
              );
              if (newBirthday != null) {
                setState(() {
                  birthday = newBirthday;
                });
                await _updateBirthday(newBirthday);
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('성별', style: TextStyle(color: Colors.black)), // 검정색으로 변경
            trailing: Text(gender, style: TextStyle(color: Colors.black)),
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
        ],
      ),
    );
  }
}
