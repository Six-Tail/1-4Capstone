import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todobest_home/screens/birthdayselectionscreen.dart';
import 'package:todobest_home/screens/genderselectionscreen.dart';
import 'package:todobest_home/screens/namedetailscreen.dart';

import 'editnicknamescreen.dart';


class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  File? _profileImage; // 프로필 이미지 파일을 저장할 변수
  final ImagePicker _picker = ImagePicker();
  bool _isHovered = false; // hover 상태를 관리하는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 관리'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) // 선택한 이미지를 프로필로 설정
                        : NetworkImage('https://example.com/profile_image.jpg') as ImageProvider, // 기본 프로필 이미지 URL
                  ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _changeProfileImage, // 프로필 사진 변경 메소드 호출
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Divider(),
          ListTile(
            title: Text('닉네임'),
            trailing: Text('정세운', style: TextStyle(color: Colors.blue)),
            onTap: () async {
              // 닉네임 변경 화면으로 이동
              final newNickname = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditNicknameScreen()),
              );
              if (newNickname != null) {
                // 닉네임이 변경되었으면 업데이트 처리
                setState(() {
                  // 예: 닉네임 업데이트 로직
                });
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('생일'),
            trailing: Text('2003년 4월 23일', style: TextStyle(color: Colors.blue)),
    onTap: () async {
      // 닉네임 변경 화면으로 이동
      final newNickname = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BirthdaySelectionScreen()),
      );
    },
          ),
          Divider(),
          ListTile(
            title: Text('성별'),
            trailing: Text('남성', style: TextStyle(color: Colors.blue)),
            onTap: () async {
              // 닉네임 변경 화면으로 이동
              final newNickname = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenderSelectionScreen(currentGender: '',)),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('이름'),
            onTap: () async {
              // 닉네임 변경 화면으로 이동
              final newNickname = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NameDetailScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // 선택한 파일을 프로필 이미지로 설정
      });
    }
  }
}


