import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/Themes.Colors.dart';
import 'post_detail.dart';

class ScrapPage extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5), // 배경 색상 설정
      appBar: AppBar(
        title: Text(
          '스크랩한 게시글',
          style: TextStyle(fontSize: 26, color: Theme1Colors.textColor),
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
              .collection('scraps')
              .doc(userId) // 현재 로그인한 사용자만의 스크랩된 게시글 가져오기
              .collection('posts')
              .orderBy('timestamp', descending: true) // 스크랩한 시간 기준으로 정렬
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('스크랩한 게시글이 없습니다.'));
            }

            final scraps = snapshot.data!.docs;

            return ListView.builder(
              itemCount: scraps.length,
              itemBuilder: (context, index) {
                final postId = scraps[index].id;

                // 각 스크랩된 게시글의 상세 정보를 posts 컬렉션에서 가져옴
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
                  builder: (context, postSnapshot) {
                    if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                      return const SizedBox.shrink(); // 게시글이 삭제된 경우 빈 공간
                    }

                    final post = postSnapshot.data!.data() as Map<String, dynamic>;

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
                              builder: (context) => PostDetail(postId: postId),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(post['userImage'] ?? ''),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['userName'] ?? '익명',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat('yyyy-MM-dd HH:mm').format(
                                          (post['timestamp'] as Timestamp).toDate(),
                                        ),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post['title'] ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post['content'] ?? '',
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.thumb_up, size: 18, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(post['likes']?.toString() ?? '0'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.comment, size: 18, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(post['commentsCount']?.toString() ?? '0'),
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
            );
          },
        ),
      ),
    );
  }
}
