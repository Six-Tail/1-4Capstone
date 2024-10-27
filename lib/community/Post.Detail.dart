import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';

class PostDetail extends StatefulWidget {
  final String postId;

  const PostDetail({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final Map<String, bool> _isReplying = {};
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _isReplyLoading = {};
  bool _isCommentLoading = false;
  final UserService userService = UserService(); // UserService instance 생성
  String userName = '';
  String userImage = '';

  // UserService를 통해 사용자 정보 가져오기
  Future<void> _fetchUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userInfo = await userService.getUserInfo(currentUser.uid); // UserService 사용
      if (userInfo != null) {
        setState(() {
          userName = userInfo['userName'];
          userImage = userInfo['userImage'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // 초기화 시 사용자 정보 불러오기
  }

  // Firestore에서 게시글 좋아요 업데이트
  Future<void> _togglePostLike(bool isLiked, int currentLikes) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'isLiked': !isLiked,
        'likes': isLiked ? currentLikes - 1 : currentLikes + 1,
      });
    } catch (e) {
      print("좋아요 업데이트 오류: $e");
    }
  }

  // Firestore에 댓글 추가 및 댓글 수 업데이트
  Future<void> _addComment(String content) async {
    if (content.isEmpty) return;
    setState(() => _isCommentLoading = true);
    try {
      final commentsCollection = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments');

      await commentsCollection.add({
        'userName': userName,
        'userImage': userImage,
        'content': content,
        'timeStamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'isLiked': false,
      });

      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      print("댓글 추가 오류: $e");
    } finally {
      setState(() => _isCommentLoading = false);
    }
  }

  // Firestore에서 댓글 좋아요 업데이트
  Future<void> _toggleCommentLike(String commentId, bool isLiked, int currentLikes) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'isLiked': !isLiked,
        'likes': isLiked ? currentLikes - 1 : currentLikes + 1,
      });
    } catch (e) {
      print("댓글 좋아요 업데이트 오류: $e");
    }
  }

  // Firestore에 답글 추가 및 로딩 상태 업데이트
  Future<void> _addReply(String content, String commentId) async {
    if (content.isEmpty) return;
    setState(() => _isReplyLoading[commentId] = true);
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add({
        'userName': userName,
        'userImage': userImage,
        'content': content,
        'timeStamp': FieldValue.serverTimestamp(),
      });

      _replyControllers[commentId]?.clear();
      setState(() {
        _isReplying[commentId] = false;
      });
    } catch (e) {
      print("답글 추가 오류: $e");
    } finally {
      setState(() => _isReplyLoading[commentId] = false);
    }
  }

  String _timeAgo(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final Duration difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    return '${difference.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: const Text('게시글 상세보기'),
        backgroundColor: Theme1Colors.mainColor,
        centerTitle: true,
        leading: BackButton(color: Theme1Colors.textColor),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                          final post = snapshot.data!.data() as Map<String, dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['title'] ?? '',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(post['content'] ?? ''),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post['isLiked'] ?? false
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_off_alt,
                                    ),
                                    onPressed: () => _togglePostLike(
                                        post['isLiked'] ?? false, post['likes'] ?? 0),
                                  ),
                                  Text(post['likes'].toString()),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.comment),
                                  Text(post['commentsCount'].toString()),
                                ],
                              ),
                              const Divider(color: Colors.black),
                            ],
                          );
                        },
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('timeStamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                          final comments = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final commentData = comment.data() as Map<String, dynamic>;
                              final commentId = comment.id;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(commentData['userImage']),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(commentData['userName'] ?? ''),
                                            Text(commentData['content'] ?? ''),
                                            Text(
                                              _timeAgo(commentData['timeStamp']),
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    (commentData['isLiked'] ?? false)
                                                        ? Icons.thumb_up
                                                        : Icons.thumb_up_off_alt,
                                                  ),
                                                  onPressed: () => _toggleCommentLike(
                                                    commentId,
                                                    commentData['isLiked'] ?? false,
                                                    commentData['likes'] ?? 0,
                                                  ),
                                                ),
                                                Text(commentData['likes'].toString()),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _isReplying[commentId] = !(_isReplying[commentId] ?? false);
                                                    });
                                                  },
                                                  child: const Text('답글 달기'),
                                                ),
                                              ],
                                            ),
                                            if (_isReplying[commentId] ?? false)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 40.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _replyControllers[commentId] ??= TextEditingController(),
                                                        decoration: const InputDecoration(labelText: '답글을 입력하세요'),
                                                      ),
                                                    ),
                                                    _isReplyLoading[commentId] == true
                                                        ? const CircularProgressIndicator()
                                                        : IconButton(
                                                      icon: const Icon(Icons.send),
                                                      onPressed: () {
                                                        _addReply(
                                                          _replyControllers[commentId]!.text,
                                                          commentId,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('posts')
                                                  .doc(widget.postId)
                                                  .collection('comments')
                                                  .doc(commentId)
                                                  .collection('replies')
                                                  .orderBy('timeStamp', descending: true)
                                                  .snapshots(),
                                              builder: (context, replySnapshot) {
                                                if (!replySnapshot.hasData) return const SizedBox.shrink();
                                                final replies = replySnapshot.data!.docs;
                                                return ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: replies.length,
                                                  itemBuilder: (context, replyIndex) {
                                                    final replyData = replies[replyIndex].data() as Map<String, dynamic>;
                                                    return Padding(
                                                      padding: const EdgeInsets.only(left: 40.0),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundImage: NetworkImage(replyData['userImage']),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(replyData['userName'] ?? ''),
                                                                Text(replyData['content'] ?? ''),
                                                                Text(
                                                                  _timeAgo(replyData['timeStamp']),
                                                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isCommentLoading) const LinearProgressIndicator(),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _commentFocusNode,
                      controller: _commentController,
                      decoration: const InputDecoration(labelText: '댓글을 입력하세요'),
                      onSubmitted: (content) {
                        _addComment(content);
                        _commentFocusNode.unfocus();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _addComment(_commentController.text);
                      _commentFocusNode.unfocus();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
