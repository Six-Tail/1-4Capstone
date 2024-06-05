import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsScreen(),
      theme: ThemeData.dark(), // 다크 테마 적용
      routes: {
        '/change-phone-number': (context) => ChangePhoneNumberScreen(),
        '/change-email': (context) => ChangeEmailScreen(),
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        children: [
          // 프로필 섹션 추가
          ProfileSection(
            profileImage: _profileImage,
            onImageTap: _pickImage,
          ),
          Divider(),
          SettingsItem(
            icon: Icons.account_circle,
            title: '계정',
            subtitle: 'peterishappy@naver.com', // 이메일 추가
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.security,
            title: '개인정보 보호',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacySettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.screen_share,
            title: '화면',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScreenSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.notifications,
            title: '알림',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.campaign,
            title: '공지사항',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnnouncementSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.emoji_emotions,
            title: '내 스티커',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StickerSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.star,
            title: 'Premium',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PremiumSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.info,
            title: '정보',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.help,
            title: '문의하기',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InquirySettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.person_add,
            title: '친구초대',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InviteFriendsSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.widgets,
            title: '위젯 설정',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WidgetSettings()),
              );
            },
          ),
          SettingsItem(
            icon: Icons.science,
            title: '실험실',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LabSettings()),
              );
            },
          ),
          ListTile(
            title: Text('버전 5.7.6', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  SettingsItem({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white), // 아이콘 색상 변경
            SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: Colors.white)), // 타이틀 텍스트 색상 변경
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyle(color: Colors.white70)), // 이메일 텍스트 색상 변경
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final File? profileImage;
  final VoidCallback onImageTap;

  ProfileSection({required this.profileImage, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : AssetImage('assets/profile_picture.png') as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onImageTap,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '정세운', // 사용자 이름
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/change-phone-number');
                  },
                  child: Text(
                    '+82 10-2730-4759', // 전화번호
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/change-email');
                  },
                  child: Text(
                    'peterishappy@naver.com', // 이메일
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white), // 프로필 설정 아이콘
            onPressed: () {
              // 프로필 설정 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 관리'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('전화번호', style: TextStyle(color: Colors.white)),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/change-phone-number');
              },
              child: Text(
                '+82 10-2730-4759',
                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ),
          ListTile(
            title: Text('이메일', style: TextStyle(color: Colors.white)),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/change-email');
              },
              child: Text(
                'peterishappy@naver.com',
                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ),
          ListTile(
            title: Text('계정 관리', style: TextStyle(color: Colors.white)),
            subtitle: Text('계정 정보를 변경합니다.', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSettings()),
              );
            },
          ),
          SwitchListTile(
            title: Text('생일 알림', style: TextStyle(color: Colors.white)),
            subtitle: Text('내 프로필에 생일 아이콘을 표시하고, 친구목록 혹은 생일을 활용한 톡 서비스를 통해 내 생일 소식을 알려줍니다.', style: TextStyle(color: Colors.white70)),
            value: true,
            onChanged: (bool value) {},
            activeColor: Colors.blue,
          ),
          SwitchListTile(
            title: Text('Wi-Fi에서만 배경 자동재생', style: TextStyle(color: Colors.white)),
            subtitle: Text('프로필의 배경 동영상을 Wi-Fi 환경에서만 자동 재생합니다. 같은 동영상은 최초 1회 재생 시에만 데이터가 소모됩니다.', style: TextStyle(color: Colors.white70)),
            value: false,
            onChanged: (bool value) {},
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class ChangePhoneNumberScreen extends StatelessWidget {
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전화번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: '새 전화번호',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String newPhoneNumber = _phoneNumberController.text;
                // 여기에서 전화번호 업데이트 로직 추가
                Navigator.pop(context);
              },
              child: Text('변경'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeEmailScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이메일 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '새 이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String newEmail = _emailController.text;
                // 여기에서 이메일 업데이트 로직 추가
                Navigator.pop(context);
              },
              child: Text('변경'),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 설정'),
      ),
      body: Center(
        child: Text('계정 설정 화면입니다.'),
      ),
    );
  }
}

class PrivacySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개인정보 보호 설정'),
      ),
      body: Center(
        child: Text('개인정보 보호 설정 화면입니다.'),
      ),
    );
  }
}

class ScreenSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('화면 설정'),
      ),
      body: Center(
        child: Text('화면 설정 화면입니다.'),
      ),
    );
  }
}

class NotificationSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 설정'),
      ),
      body: Center(
        child: Text('알림 설정 화면입니다.'),
      ),
    );
  }
}

class AnnouncementSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공지사항 설정'),
      ),
      body: Center(
        child: Text('공지사항 설정 화면입니다.'),
      ),
    );
  }
}

class StickerSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('스티커 설정'),
      ),
      body: Center(
        child: Text('스티커 설정 화면입니다.'),
      ),
    );
  }
}

class PremiumSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프리미엄 설정'),
      ),
      body: Center(
        child: Text('프리미엄 설정 화면입니다.'),
      ),
    );
  }
}

class InfoSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정보 설정'),
      ),
      body: Center(
        child: Text('정보 설정 화면입니다.'),
      ),
    );
  }
}

class InquirySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문의하기 설정'),
      ),
      body: Center(
        child: Text('문의하기 설정 화면입니다.'),
      ),
    );
  }
}

class InviteFriendsSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 초대 설정'),
      ),
      body: Center(
        child: Text('친구 초대 설정 화면입니다.'),
      ),
    );
  }
}

class WidgetSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위젯 설정'),
      ),
      body: Center(
        child: Text('위젯 설정 화면입니다.'),
      ),
    );
  }
}

class LabSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('실험실 설정'),
      ),
      body: Center(
        child: Text('실험실 설정 화면입니다.'),
      ),
    );
  }
}