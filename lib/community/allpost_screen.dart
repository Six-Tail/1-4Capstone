import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/Themes.Colors.dart';
import 'post_detail.dart';

class AllPostsScreen extends StatefulWidget {
  const AllPostsScreen({super.key});

  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  String searchQuery = "";
  String searchType = "title"; // 기본 검색 타입을 '제목'으로 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5), // 배경 색상 설정
      appBar: AppBar(
        title: Text(
          '모든 게시글',
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
        child: Column(
          children: [
            // 검색창
            Row(
              children: [
                // 검색 조건 선택 Dropdown
                DropdownButton<String>(
                  value: searchType,
                  items: const [
                    DropdownMenuItem(
                      value: "title",
                      child: Text("제목만 검색"),
                    ),
                    DropdownMenuItem(
                      value: "userName",
                      child: Text("작성자만 검색"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      searchType = value!;
                    });
                  },
                ),
                const SizedBox(width: 8),
                // 검색 입력창
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "검색어를 입력하세요",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getPostStream(),
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
                      final Timestamp timestamp = post['timestamp'];
                      final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
                      final board = post['board'] ?? '알 수 없음'; // 게시판 이름

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
                                          formattedDate,
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        board,
                                        style: const TextStyle(fontSize: 12),
                                      ),
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
                                    Icon(
                                      Icons.thumb_up,
                                      size: 18,
                                      color: post['likedBy'] != null &&
                                          (post['likedBy'] as List).contains(
                                              FirebaseAuth.instance.currentUser?.uid)
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 검색 필터에 따른 Firestore 쿼리 설정
  Stream<QuerySnapshot> _getPostStream() {
    final collectionRef = FirebaseFirestore.instance.collection('posts');

    if (searchQuery.isNotEmpty) {
      // 검색어가 입력된 경우, 해당 조건에 맞춰 필터링
      return collectionRef
          .where(searchType, isGreaterThanOrEqualTo: searchQuery)
          .where(searchType, isLessThan: '$searchQuery\uf8ff') // 파이어베이스에서 텍스트 필터링을 위해 사용하는 코드
          .orderBy(searchType)
          .snapshots();
    } else {
      // 검색어가 없을 경우 전체 게시글 불러오기
      return collectionRef.orderBy('timestamp', descending: true).snapshots();
    }
  }
}
