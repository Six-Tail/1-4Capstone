import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _image; // 선택된 이미지 파일
  String? _imageUrl; // 업로드된 이미지 URL

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

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
      body: SingleChildScrollView(
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
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        floatingLabelStyle: TextStyle(color: Colors.blue),
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? '제목을 입력하세요' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_image != null) // 선택된 이미지가 있을 때 미리보기
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "이미지 미리보기",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.file(
                      _image!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  floatingLabelStyle: const TextStyle(color: Colors.blue),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  labelStyle: const TextStyle(color: Colors.black54),
                ),
                maxLines: 10,
                validator: (value) => value!.isEmpty ? '내용을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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

  Future<void> _addPostToFirestore(String board, String title, String content) async {
    try {
      if (userId == null || userName == null || userImage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('유저 정보가 누락되었습니다. 다시 로그인해 주세요.')),
          );
        }
        return;
      }

      // 이미지 업로드
      if (_image != null) {
        _imageUrl = await _uploadImageToStorage(_image!);
      }

      DocumentReference postRef = await FirebaseFirestore.instance.collection('posts').add({
        'board': board,
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'commentsCount': 0,
        'userId': userId,
        'userName': userName,
        'userImage': userImage,
        'postImage': _imageUrl, // 업로드된 이미지 URL을 Firestore에 저장
      });

      titleController.clear();
      contentController.clear();

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

  // 이미지 업로드 함수
  Future<String?> _uploadImageToStorage(File image) async {
    try {
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref(fileName).putFile(image);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print("Image upload error: $e");
      }
      return null;
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
