import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';

class PostDetail extends StatefulWidget {
  final String postId;

  const PostDetail({super.key, required this.postId});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final Map<String, bool> _isReplying = {};
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _isReplyLoading = {};
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, TextEditingController> _replyEditControllers = {};
  bool _isCommentLoading = false;
  final UserService userService = UserService();
  String userName = '';
  String userImage = '';
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isScraped = false; // 즐겨찾기 상태 변수

  Future<void> _fetchUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
      final userInfo = await userService.getUserInfo(userId);
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
    _fetchUserDetails();
    _checkIfScraped();
  }

  Future<void> _checkIfScraped() async {
    // Firestore에서 현재 사용자가 이 게시글을 즐겨찾기했는지 확인
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('scraps')
        .doc(userId)
        .collection('posts')
        .doc(widget.postId)
        .get();
    setState(() {
      isScraped = snapshot.exists;
    });
  }

  Future<void> _toggleScrap() async {
    final scrapDoc = FirebaseFirestore.instance
        .collection('scraps')
        .doc(userId)
        .collection('posts')
        .doc(widget.postId);

    if (isScraped) {
      // 즐겨찾기 해제
      await scrapDoc.delete();
    } else {
      // 즐겨찾기 등록
      await scrapDoc.set({
        'postId': widget.postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    setState(() {
      isScraped = !isScraped;
    });
  }

  Future<void> _togglePostLike(bool isLiked) async {
    try {
      final postDoc = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      if (isLiked) {
        // 좋아요를 이미 눌렀으면 UID를 제거
        await postDoc.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likes': FieldValue.increment(-1),
        });
      } else {
        // 좋아요를 누르지 않았다면 UID를 추가
        await postDoc.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likes': FieldValue.increment(1),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("좋아요 업데이트 오류: $e");
      }
    }
  }

  Future<void> _addComment(String content) async {
    if (content.isEmpty) return;
    setState(() => _isCommentLoading = true);
    try {
      final commentsCollection = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments');

      await commentsCollection.add({
        'userId': userId,
        'userName': userName,
        'userImage': userImage,
        'content': content,
        'timeStamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'isLiked': false,
      });

      // 댓글 수 업데이트
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      // 사용자의 commentedPosts 컬렉션에 게시글 ID 추가
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('commentedPosts')
          .doc(widget.postId)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    } catch (e) {
      if (kDebugMode) {
        print("댓글 추가 오류: $e");
      }
    } finally {
      setState(() => _isCommentLoading = false);
    }
  }

  Future<void> _editPost(String newTitle, String newContent) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'title': newTitle,
        'content': newContent,
      });
      if (kDebugMode) {
        print("게시글 수정 완료");
      }
    } catch (e) {
      if (kDebugMode) {
        print("게시글 수정 오류: $e");
      }
    }
  }

  Future<void> _deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();

      // 위젯이 활성 상태인지 확인 후 화면 닫기
      if (mounted) {
        Navigator.pop(context);
      }

      if (kDebugMode) {
        print("게시글 삭제 완료");
      }
    } catch (e) {
      if (kDebugMode) {
        print("게시글 삭제 오류: $e");
      }
    }
  }


  Future<void> _editComment(String commentId, String newContent) async {
    if (newContent.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .update({'content': newContent});
    } catch (e) {
      if (kDebugMode) {
        print("댓글 수정 오류: $e");
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      if (kDebugMode) {
        print("댓글 삭제 오류: $e");
      }
    }
  }

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
        'userId': userId,
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
      if (kDebugMode) {
        print("답글 추가 오류: $e");
      }
    } finally {
      setState(() => _isReplyLoading[commentId] = false);
    }
  }

  Future<void> _editReply(String commentId, String replyId, String newContent) async {
    if (newContent.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .update({'content': newContent});
    } catch (e) {
      if (kDebugMode) {
        print("답글 수정 오류: $e");
      }
    }
  }

  Future<void> _deleteReply(String commentId, String replyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print("답글 삭제 오류: $e");
      }
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
        scrolledUnderElevation: 0,
        title: Text(
            '게시글 상세보기',
          style: TextStyle(fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme1Colors.textColor)
        ),
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
                          // 데이터가 없거나 삭제된 경우
                          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                            return const Center(child: Text("이 게시글은 삭제되었습니다.")); // 또는 Navigator.pop(context)로 이전 화면으로 이동
                          }

                          // 정상적으로 데이터가 있는 경우 처리
                          final post = (snapshot.data!.data() ?? {}) as Map<String, dynamic>;

                          final likedBy = List<String>.from(post['likedBy'] ?? []);
                          final isLiked = likedBy.contains(userId); // 현재 사용자가 좋아요를 눌렀는지 확인

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(post['userImage'] ?? ''),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post['userName'] ?? '알 수 없음',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        post['timestamp'] != null
                                            ? _timeAgo(post['timestamp'])
                                            : '작성 시간 알 수 없음',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      isScraped ? Icons.bookmark_border : Icons.bookmark_border_outlined,
                                      color: isScraped ? Colors.yellow : Colors.grey,
                                    ),
                                    onPressed: _toggleScrap, // 즐겨찾기 토글 함수
                                  ),
                                  if (post['userId'] == userId)
                                  Theme(
                                  data: Theme.of(context).copyWith(
                                    popupMenuTheme: const PopupMenuThemeData(
                                    color: Colors.white, // 팝업 메뉴의 배경색을 흰색으로 설정
                                     ),
                                    ),
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditPostDialog(post['title'], post['content']);
                                        } else if (value == 'delete') {
                                          _deletePost();
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text("수정"),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text("삭제"),
                                        ),
                                      ],
                                      icon: const Icon(Icons.more_vert),
                                    ),
                          )],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post['title'] ?? '',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(post['content'] ?? ''),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                                      color: isLiked ? Colors.blue : Colors.blue,
                                    ),
                                    onPressed: () => _togglePostLike(isLiked),
                                  ),
                                  Text(post['likes']?.toString() ?? '0'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.comment, color: Colors.green),
                                  Text(post['commentsCount']?.toString() ?? '0'),
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
                            .orderBy('timeStamp', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final comments = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final commentData = (comment.data() ?? {}) as Map<String, dynamic>;
                              final commentId = comment.id;
                              final isUserComment = commentData['userId'] == userId;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(commentData['userImage'] ?? ''),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(commentData['userName'] ?? '익명'),
                                            Text(commentData['content'] ?? ''),
                                            Text(
                                              commentData['timeStamp'] != null
                                                  ? _timeAgo(commentData['timeStamp'])
                                                  : '방금 전',
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.reply,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isReplying[commentId] = !(_isReplying[commentId] ?? false);
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            if (_isReplying[commentId] == true)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 40.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _replyControllers[commentId] ??= TextEditingController(),
                                                        decoration: const InputDecoration(
                                                          labelText: '답글을 입력하세요',
                                                          labelStyle: TextStyle(color: Colors.grey), // 기본 상태의 라벨 색상 설정
                                                          floatingLabelStyle: TextStyle(color: Colors.blue), // 포커스 시 라벨 색상 설정
                                                          focusedBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.blue), // 포커스 시 줄 색상을 파란색으로 설정
                                                          ),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.grey), // 기본 줄 색상을 회색으로 설정
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _isReplyLoading[commentId] == true
                                                        ? const CircularProgressIndicator()
                                                        : IconButton(
                                                      icon: const Icon(Icons.send, color: Colors.blue),
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
                                          ],
                                        ),
                                      ),

                                      if (isUserComment)
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            popupMenuTheme: const PopupMenuThemeData(
                                              color: Colors.white, // 팝업 메뉴의 배경색을 흰색으로 설정
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _editControllers[commentId] = TextEditingController(text: commentData['content']);
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                                                  title: const Text("댓글 수정"),
                                                  content: TextField(
                                                    controller: _editControllers[commentId],
                                                    decoration: const InputDecoration(
                                                      hintText: "댓글 수정",
                                                      focusedBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.blue), // 포커스 시 줄 색상을 파란색으로 설정
                                                      ),
                                                      enabledBorder: UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Colors.grey), // 기본 줄 색상을 회색으로 설정
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        _editComment(commentId, _editControllers[commentId]!.text);
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.blue, // 텍스트 색상을 파란색으로 설정
                                                      ),
                                                      child: const Text("저장"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.blue, // 텍스트 색상을 파란색으로 설정
                                                      ),
                                                      child: const Text("취소"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (value == 'delete') {
                                              _deleteComment(commentId);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text("수정"),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text("삭제"),
                                            ),
                                          ],
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                        )],
                                  ),
                                  const SizedBox(height: 10),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(widget.postId)
                                        .collection('comments')
                                        .doc(commentId)
                                        .collection('replies')
                                        .orderBy('timeStamp', descending: false)
                                        .snapshots(),
                                    builder: (context, replySnapshot) {
                                      if (!replySnapshot.hasData) return const SizedBox.shrink();
                                      final replies = replySnapshot.data!.docs;

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: replies.length,
                                        itemBuilder: (context, replyIndex) {
                                          final replyData = (replies[replyIndex].data() ?? {}) as Map<String, dynamic>;
                                          final replyId = replies[replyIndex].id;
                                          final isUserReply = replyData['userId'] == userId;

                                          return Padding(
                                            padding: const EdgeInsets.only(left: 40.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: NetworkImage(replyData['userImage'] ?? ''),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(replyData['userName'] ?? '익명'),
                                                      Text(replyData['content'] ?? ''),
                                                      Text(
                                                        replyData['timeStamp'] != null
                                                            ? _timeAgo(replyData['timeStamp'])
                                                            : '방금 전',
                                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (isUserReply)
                                                 Theme(
                                                data: Theme.of(context).copyWith(
                                                popupMenuTheme: const PopupMenuThemeData(
                                                 color: Colors.white, // 팝업 메뉴의 배경색을 흰색으로 설정
                                                   ),
                                          ),
                                          child: PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _replyEditControllers[replyId] = TextEditingController(text: replyData['content']);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                                                            title: const Text("답글 수정"),
                                                            content: TextField(
                                                              controller: _replyEditControllers[replyId],
                                                              decoration: const InputDecoration(
                                                                hintText: "답글 수정",
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: Colors.blue), // 포커스 시 줄 색상을 파란색으로 설정
                                                                ),
                                                                enabledBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: Colors.grey), // 기본 줄 색상을 회색으로 설정
                                                                ),
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  _editReply(commentId, replyId, _replyEditControllers[replyId]!.text);
                                                                  Navigator.of(context).pop();
                                                                },
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor: Colors.blue, // 텍스트 색상을 파란색으로 설정
                                                                ),
                                                                child: const Text("저장"),
                                                              ),
                                                              TextButton(
                                                                onPressed: () => Navigator.of(context).pop(),
                                                                style: TextButton.styleFrom(
                                                                  foregroundColor: Colors.blue, // 텍스트 색상을 파란색으로 설정
                                                                ),
                                                                child: const Text("취소"),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else if (value == 'delete') {
                                                        _deleteReply(commentId, replyId);
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Text("수정"),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text("삭제"),
                                                      ),
                                                    ],
                                                    icon: const Icon(Icons.more_vert),
                                                  ),
                                                 )],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
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
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _commentFocusNode,
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: '댓글을 입력하세요',
                        fillColor: Colors.white, // 배경색을 하얀색으로 설정
                        filled: true, // 배경색 적용
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
                      onSubmitted: (content) {
                        _addComment(content);
                        _commentFocusNode.unfocus();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,color:Colors.blue),
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

  // 게시글 수정 다이얼로그 표시
  void _showEditPostDialog(String currentTitle, String currentContent) {
    final titleController = TextEditingController(text: currentTitle);
    final contentController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // 배경색을 흰색으로 설정
        title: const Text("게시글 수정"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "제목",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // 포커스 시 테두리 색상을 파란색으로 설정
                ),
              ),
            ),
            const SizedBox(height: 8), // 간격 추가
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: "내용",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // 포커스 시 테두리 색상을 파란색으로 설정
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // 텍스트 색상을 파란색으로 설정
            ),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              _editPost(titleController.text, contentController.text);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // 텍스트 색상을 파란색으로 설정
            ),
            child: const Text("저장"),
          ),
        ],
      ),
    );
  }
}
