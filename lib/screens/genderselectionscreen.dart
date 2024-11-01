import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todobest_home/screens/birthdayselectionscreen.dart';
import 'editnicknamescreen.dart';

class ProfileDetailScreen extends StatefulWidget {
  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isHovered = false;
  String _gender = '남성';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoBest계정'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
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
          ),
          SizedBox(height: 16.0),
          Divider(),
          ListTile(
            title: Text('닉네임'),
            trailing: Text('정세운', style: TextStyle(color: Colors.blue)),
            onTap: () async {
              final newNickname = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditNicknameScreen()),
              );
              if (newNickname != null) {
                setState(() {
                  // 닉네임 업데이트 로직
                });
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('생일'),
            trailing: Text('2003년 4월 23일', style: TextStyle(color: Colors.blue)),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BirthdaySelectionScreen()),
              );
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

class GenderSelectionScreen extends StatefulWidget {
  final String currentGender;

  GenderSelectionScreen({required this.currentGender});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  late String selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.currentGender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoBest계정'),
        centerTitle: true,
    actions: [
    IconButton(
    icon: Icon(Icons.close),
    onPressed: () {
      Navigator.pop(context);
    },
      ),
      ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    '성별을 알려 주세요.',
    style: TextStyle(fontSize: 16),
    ),

          RadioListTile<String>(
            title: Text('여성'),
            value: '여성',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('남성'),
            value: '남성',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('선택안함'),
            value: '선택안함',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellow, // 버튼 텍스트 색상
                minimumSize: Size(double.infinity, 50), // 버튼 크기
              ),
              onPressed: () { Navigator.pop(context); },
              child: Text('확인'),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
