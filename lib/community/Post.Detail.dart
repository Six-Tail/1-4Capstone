import 'package:flutter/material.dart';
import '../utils/Themes.Colors.dart'; // Theme1Colors를 사용하기 위해 import

class PostDetail extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetail({super.key, required this.post});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final Map<int, bool> _isReplying = {}; // 각 댓글에 대해 답글 입력창 표시 여부 저장
  final Map<int, TextEditingController> _replyControllers = {}; // 각 댓글에 대해 별도의 컨트롤러 사용
  final ScrollController _scrollController = ScrollController(); // 스크롤을 제어하기 위한 컨트롤러
  final FocusNode _commentFocusNode = FocusNode(); // 댓글 입력에 포커스를 주기 위한 FocusNode
  final TextEditingController _commentController = TextEditingController(); // 댓글 입력 컨트롤러

  // 글의 좋아요 기능
  void _togglePostLike() {
    setState(() {
      widget.post['isLiked'] = !(widget.post['isLiked'] ?? false); // null이면 false로 처리
      if (widget.post['isLiked'] == true) {
        widget.post['likes']++;
      } else {
        widget.post['likes']--;
      }
    });
  }

  // 댓글 추가 기능
  void _addComment(String comment) {
    final newComment = {
      'userName': '사용자닉네임', // 여기에 실제 유저 닉네임
      'userImage': 'https://example.com/user_image.png', // 여기에 실제 유저 이미지
      'content': comment,
      'timeStamp': DateTime.now(),
      'likes': 0, // 댓글 좋아요 수
      'isLiked': false, // 사용자가 좋아요를 눌렀는지 여부
      'replies': [] // 댓글에 달린 답글 리스트
    };

    setState(() {
      widget.post['comments'].add(newComment);
      _commentController.clear(); // 댓글 입력 필드 초기화
      _scrollToBottom(); // 댓글 추가 후 스크롤을 하단으로 이동
    });
  }

  // 댓글에 좋아요 기능 추가
  void _toggleCommentLike(int commentIndex) {
    setState(() {
      final comment = widget.post['comments'][commentIndex];
      comment['isLiked'] = !(comment['isLiked'] ?? false); // null이면 false로 처리
      if (comment['isLiked'] == true) {
        comment['likes']++;
      } else {
        comment['likes']--;
      }
    });
  }

  // 답글 추가 기능
  void _addReply(String reply, int commentIndex) {
    final newReply = {
      'userName': '사용자닉네임',
      'userImage': 'https://example.com/user_image.png', // 답글에도 유저 이미지 추가
      'content': reply,
      'timeStamp': DateTime.now(),
    };

    setState(() {
      widget.post['comments'][commentIndex]['replies'].add(newReply);
      _isReplying[commentIndex] = false; // 답글 입력창 닫기
      _replyControllers[commentIndex]?.clear(); // 입력 필드 초기화
    });
  }

  // 시간 표시 함수
  String _timeAgo(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  // 댓글 입력란으로 자동 스크롤
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          widget.post['title'],
          style: TextStyle(color: Theme1Colors.textColor),
        ),
        backgroundColor: Theme1Colors.mainColor,
        centerTitle: true,
        leading: BackButton(color: Theme1Colors.textColor),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 화면을 터치하면 키보드를 숨김
        },
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController, // 스크롤 컨트롤러 설정
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.post['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.post['content'],
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              (widget.post['isLiked'] ?? false) // null이면 false로 처리
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_off_alt,
                              color: Colors.black,
                            ),
                            onPressed: _togglePostLike, // 글의 좋아요 기능 연결
                          ),
                          Text(
                            widget.post['likes'].toString(),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment, color: Colors.black),
                          Text(
                            widget.post['comments'].length.toString(),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.post['comments'].length,
                        itemBuilder: (context, index) {
                          final comment = widget.post['comments'][index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(comment['userImage']),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['userName'],
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          comment['content'],
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          _timeAgo(comment['timeStamp']),
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                (comment['isLiked'] ?? false) // null이면 false로 처리
                                                    ? Icons.thumb_up
                                                    : Icons.thumb_up_off_alt,
                                                color: Colors.black,
                                              ),
                                              onPressed: () =>
                                                  _toggleCommentLike(index),
                                            ),
                                            Text(
                                              comment['likes'].toString(),
                                              style: const TextStyle(color: Colors.black),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isReplying[index] =
                                                  !(_isReplying[index] ?? false);
                                                });
                                              },
                                              child: const Text('답글 달기'),
                                            ),
                                          ],
                                        ),
                                        // 답글 입력창 표시
                                        if (_isReplying[index] ?? false)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16.0),
                                            child: Column(
                                              children: [
                                                TextField(
                                                  controller: _replyControllers[index] ??=
                                                      TextEditingController(),
                                                  decoration: const InputDecoration(
                                                    labelText: '답글을 입력하세요',
                                                  ),
                                                  onSubmitted: (reply) =>
                                                      _addReply(reply, index),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _addReply(
                                                        _replyControllers[index]?.text ??
                                                            '',
                                                        index);
                                                  },
                                                  child: const Text('답글 달기'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // 답글 목록 표시 (들여쓰기 적용)
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: comment['replies'].length,
                                          itemBuilder: (context, replyIndex) {
                                            final reply =
                                            comment['replies'][replyIndex];
                                            return Padding(
                                              padding:
                                              const EdgeInsets.only(left: 40.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        reply['userImage']),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          reply['userName'],
                                                          style: const TextStyle(
                                                              color: Colors.black),
                                                        ),
                                                        Text(
                                                          reply['content'],
                                                          style: const TextStyle(
                                                              color: Colors.black),
                                                        ),
                                                        Text(
                                                          _timeAgo(reply['timeStamp']),
                                                          style: const TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 댓글 입력 칸을 화면 하단에 고정
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _commentFocusNode,
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: '댓글을 입력하세요',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      onTap: _scrollToBottom, // 댓글 입력 클릭 시 하단으로 스크롤
                      onSubmitted: (comment) {
                        _addComment(comment);
                        _commentFocusNode.unfocus(); // 댓글 입력 후 키보드 숨김
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _addComment(_commentController.text);
                      _commentFocusNode.unfocus(); // 댓글 입력 후 키보드 숨김
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
