import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/Themes.Colors.dart';
import 'post_detail.dart'; // 상세 페이지 import
import '../service/User_Service.dart'; // UserService import

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

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
        scrolledUnderElevation: 0,
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
      ),
      body: SingleChildScrollView( // 키보드가 올라올 때 스크롤 가능하게 설정
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedBoard,
                hint: const Text('게시판을 선택하세요'),
                onChanged: (value) {
                  setState(() {
                    selectedBoard = value;
                  });
                },
                validator: (value) => value == null ? '게시판을 선택하세요' : null,
                dropdownColor: Colors.white, // 드롭다운 메뉴의 배경색을 흰색으로 설정
                decoration: InputDecoration(
                  fillColor: Colors.white, // 배경색을 하얀색으로 설정
                  filled: true, // fillColor 적용을 위해 true로 설정
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue), // 포커스 시 줄 색상을 파란색으로 설정
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey), // 기본 줄 색상을 회색으로 설정
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                items: [
                  '자유 게시판',
                  '목표 공유 게시판',
                  '자기계발 팁 게시판',
                  '멘토링 요청 게시판',
                  '홍보 게시판'
                ]
                    .map((board) => DropdownMenuItem(
                  value: board,
                  child: Text(board),
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  fillColor: Colors.white, // 배경색을 하얀색으로 설정
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // 포커스 시 줄 색상을 파란색으로 설정
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // 기본 줄 색상을 회색으로 설정
                  ),
                ),
                validator: (value) => value!.isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  fillColor: Colors.white, // 배경색을 하얀색으로 설정
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue), // 포커스 시 줄 색상을 파란색으로 설정
                    borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 설정
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey), // 기본 줄 색상을 회색으로 설정
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // 내부 여백 설정
                  labelStyle: const TextStyle(color: Colors.black54), // 라벨 텍스트 색상 설정
                ),
                maxLines: 10,
                validator: (value) => value!.isEmpty ? '내용을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 여기서 배경색을 설정합니다.
                  ),
                  child: const Text('완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPostToFirestore(
      String board, String title, String content) async {
    try {
      if (userId == null || userName == null || userImage == null) {
        // 알림 추가: 유저 정보가 없는 경우 사용자에게 경고
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('유저 정보가 누락되었습니다. 다시 로그인해 주세요.')),
          );
        }
        return;
      }

      // Firestore의 'posts' 컬렉션에 새 문서를 추가
      DocumentReference postRef = await FirebaseFirestore.instance
          .collection('posts')
          .add({
        'board': board,
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'commentsCount': 0,
        'userId': userId,
        'userName': userName,
        'userImage': userImage,
      });

      if (kDebugMode) {
        print('게시글 Firestore에 성공적으로 저장되었습니다. postId: ${postRef.id}');
      }

      // 게시글 저장 후 텍스트 초기화
      titleController.clear();
      contentController.clear();

      // 위젯이 여전히 활성 상태인지 확인 후 상세 페이지로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetail(postId: postRef.id),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('게시글 Firestore 저장 오류: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 저장에 실패했습니다. 다시 시도해 주세요.')),
        );
      }
    }
  }

  // 완료 버튼 클릭 시 Firestore에 저장
  void handleComplete() {
    if (_formKey.currentState!.validate() && selectedBoard != null) {
      _addPostToFirestore(
          selectedBoard!, titleController.text, contentController.text);
    } else if (selectedBoard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시판을 선택해주세요.')),
      );
    }
  }
}
