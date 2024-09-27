import 'package:flutter/material.dart';
import '../utils/Themes.Colors.dart';
import 'Post.Detail.dart'; // Import the PostDetailPage

class WroteBoardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  WroteBoardScreen({required this.posts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          '내가 쓴 글', // 플래너 앱 제목을 ToDoBest로 변경
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
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              child: ListTile(
                title: Text(
                  post['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.thumb_up, size: 18),
                    SizedBox(width: 4),
                    Text(post['likes'].toString()),
                    SizedBox(width: 16),
                    Icon(Icons.comment, size: 18),
                    SizedBox(width: 4),
                    Text(post['comments'].length.toString()),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetail(post: post),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
