import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';
import 'post_detail.dart';

class HotBoardScreen extends StatelessWidget {
  final UserService userService = UserService();

  HotBoardScreen({super.key}); // UserService 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5), // 배경 색상 설정
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          'HOT 게시판',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where('likes',
                  isGreaterThanOrEqualTo: 10) // 좋아요가 10 이상인 게시글만 가져오기
              .orderBy('likes', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('게시글이 없습니다.'));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                final postId = posts[index].id;
                final userId = post['userId']; // 게시글 작성자의 UID
                final Timestamp timestamp = post['timestamp'];
                final String formattedDate =
                    DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostDetail(postId: postId), // postId 전달
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<Map<String, dynamic>?>(
                            future: userService.getUserInfo(userId),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return const Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    SizedBox(width: 8),
                                    Text("로딩 중...",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                );
                              }

                              final userData = userSnapshot.data!;
                              final userName = userData['userName'] ?? '익명';
                              final userImage = userData['userImage'] ??
                                  userService.defaultProfileImageUrl;

                              return Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post['userImage'] ?? ''),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post['content'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up,
                                  size: 18, color: Colors.blue),
                              // 좋아요 아이콘 파란색 설정
                              const SizedBox(width: 4),
                              Text(post['likes'].toString()),
                              const SizedBox(width: 16),
                              const Icon(Icons.comment,
                                  size: 18, color: Colors.green),
                              // 댓글 아이콘 초록색 설정
                              const SizedBox(width: 4),
                              Text(post['commentsCount'].toString()),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  post['category'] ?? 'HOT',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
