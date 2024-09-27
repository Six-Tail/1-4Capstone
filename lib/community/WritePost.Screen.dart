import 'package:flutter/material.dart';

import '../utils/Themes.Colors.dart';

class WritePostScreen extends StatefulWidget {
  @override
  _WritePostScreenState createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? selectedBoard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme1Colors.mainColor,
        appBar: AppBar(
          title: Text(
            '게시글 작성', // 플래너 앱 제목을 ToDoBest로 변경
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme1Colors.textColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme1Colors.mainColor,
          leading: BackButton(
            color: Theme1Colors.textColor, // 뒤로가기 버튼 색상
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
                ))
                    .toList(),
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

  void handleComplete() {
    if (_formKey.currentState!.validate() && selectedBoard != null) {
      Navigator.pop(context, {
        'board': selectedBoard,
        'title': titleController.text,
        'content': contentController.text,
        'likes': 0,
        'comments': [], // 댓글 리스트 초기화
      });
    }
  }
}
