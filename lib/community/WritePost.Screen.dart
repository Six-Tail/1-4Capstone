import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/Themes.Colors.dart';
import 'Post.Detail.dart'; // 상세 페이지 import
import '../service/User_Service.dart'; // UserService import

class WritePostScreen extends StatefulWidget {
  @override
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? selectedBoard;
  final UserService userService = UserService();

  // 유저 정보 변수
  String? userId;
  String? userName;
  String? userImage;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // 현재 유저의 정보를 가져오는 함수
  Future<void> _fetchUserInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
      final userInfo = await userService.getUserInfo(userId!);
      if (userInfo != null) {
        setState(() {
          userName = userInfo['userName'] ?? 'Unknown';
          userImage = userInfo['userImage'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          '게시글 작성',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme1Colors.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme1Colors.mainColor,
        leading: BackButton(
          color: Theme1Colors.textColor,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 기능 추가 가능
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedBoard,
                hint: Text('게시판을 선택하세요'),
                onChanged: (value) {
                  setState(() {
                    selectedBoard = value;
                  });
                },
                validator: (value) => value == null ? '게시판을 선택하세요' : null,
                items: ['자유 게시판', '목표 공유 게시판', '자기계발 팁 게시판', '멘토링 요청 게시판', '홍보 게시판']
                    .map((board) => DropdownMenuItem(
                  value: board,
                  child: Text(board),
                )).toList(),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: '제목'),
                validator: (value) => value!.isEmpty ? '제목을 입력하세요' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(labelText: '내용'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? '내용을 입력하세요' : null,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: handleComplete,
                  child: Text('완료'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Firestore에 게시글 저장 함수
  Future<void> _addPostToFirestore(String board, String title, String content) async {
    try {
      if (userId == null || userName == null || userImage == null) {
        print("유저 정보가 누락되었습니다.");
        return;
      }

      // Firestore의 'posts' 컬렉션에 새 문서를 추가
      DocumentReference postRef = await FirebaseFirestore.instance.collection('posts').add({
        'board': board,
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'commentsCount': 0, // 댓글 수 필드 추가
        'userId': userId, // 실제 유저 ID
        'userName': userName, // 실제 유저 이름
        'userImage': userImage, // 실제 유저 이미지
      });

      print('게시글 Firestore에 성공적으로 저장되었습니다. postId: ${postRef.id}');

      // 게시글 저장 후 상세 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetail(postId: postRef.id), // postId 전달
        ),
      );
    } catch (e) {
      print('게시글 Firestore 저장 오류: $e');
    }
  }

  // 완료 버튼 클릭 시 Firestore에 저장
  void handleComplete() {
    if (_formKey.currentState!.validate() && selectedBoard != null) {
      _addPostToFirestore(selectedBoard!, titleController.text, contentController.text);
    }
  }
}
