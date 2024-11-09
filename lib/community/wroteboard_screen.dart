import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/Themes.Colors.dart';
import 'post_detail.dart';

class WroteBoardScreen extends StatelessWidget {
  final String? userId;

  const WroteBoardScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인된 사용자의 ID를 가져옴
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          '내가 쓴 글',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('userId', isEqualTo: currentUserId) // 로그인된 사용자 ID로 필터링
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('내가 쓴 게시글이 없습니다.'));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                final postId = posts[index].id; // 각 게시글의 postId

                return Card(
                  color: Theme1Colors.mainColor,
                  child: ListTile(
                    title: Text(
                      post['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.thumb_up, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(post['likes']?.toString() ?? '0'),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(post['commentsCount']?.toString() ?? '0'), // 댓글 수
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetail(postId: postId), // postId 전달
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
