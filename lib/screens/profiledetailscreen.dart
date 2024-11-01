// ProfileDetailScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'editnicknamescreen.dart';
import 'birthdayselectionscreen.dart';
import 'genderselectionscreen.dart';

class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _nickname = '정세운';
  String _birthday = '2003년 4월 23일';
  String _gender = '남성';

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : NetworkImage('https://example.com/profile_image.jpg') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
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
          Divider(),
          ListTile(
            title: Text('닉네임'),
            trailing: Text(_nickname, style: TextStyle(color: Colors.blue)),
            onTap: () async {
              final newNickname = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditNicknameScreen()),
              );
              if (newNickname != null) {
                setState(() {
                  _nickname = newNickname;
                });
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('생일'),
            trailing: Text(_birthday, style: TextStyle(color: Colors.blue)),
            onTap: () async {
              final selectedBirthday = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BirthdaySelectionScreen()),
              );
              if (selectedBirthday != null) {
                setState(() {
                  _birthday = selectedBirthday;
                });
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('성별'),
            trailing: Text(_gender, style: TextStyle(color: Colors.blue)),
            onTap: () async {
              final selectedGender = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GenderSelectionScreen(currentGender: _gender)),
              );
              if (selectedGender != null) {
                setState(() {
                  _gender = selectedGender;
                });
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('이름'),
            subtitle: Text('본인 확인 정보로 사용할 수 있는 이름을 관리합니다. 본인 인증받은 이름이 등록됩니다.'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
}
