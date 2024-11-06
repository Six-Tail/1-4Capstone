import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';
import '../utils/UserInfoDialog.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final UserService _userService = UserService();
  late Timer _timer;

  // 사용자 정보를 캐싱하기 위한 맵
  Map<String, Map<String, dynamic>> userCache = {};

  @override
  void initState() {
    super.initState();
    _startAutoDeleteOldMessages();
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 해제
    super.dispose();
  }

  // 1시간마다 오래된 메시지 삭제
  void _startAutoDeleteOldMessages() {
    _timer = Timer.periodic(Duration(hours: 1), (timer) {
      _deleteOldMessages();
    });
  }

  // Firestore에서 1시간 이상 된 메시지 삭제
  Future<void> _deleteOldMessages() async {
    final cutoff = DateTime.now().subtract(Duration(hours: 1));
    final oldMessages = await _firestore
        .collection('chatRooms')
        .doc('global_chat')
        .collection('messages')
        .where('sentAt', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    for (var doc in oldMessages.docs) {
      await doc.reference.delete();
    }
  }

  // 메시지 전송 메서드
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    await _firestore.collection('chatRooms').doc('global_chat').collection('messages').add({
      'senderId': _currentUser?.uid,
      'messageText': _controller.text.trim(),
      'sentAt': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  // Firestore에서 사용자 정보를 가져오고 캐시합니다.
  Future<Map<String, dynamic>?> _getUserInfo(String uid) async {
    if (userCache.containsKey(uid)) {
      return userCache[uid];
    } else {
      final userInfo = await _userService.getUserInfo(uid);
      if (userInfo != null) {
        userCache[uid] = userInfo;
      }
      return userInfo;
    }
  }

  // 시간 형식을 변환하는 메서드
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  // 사용자 정보 팝업을 보여주는 메서드
  void _showUserInfoDialog(BuildContext context, Map<String, dynamic> userInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserInfoDialog(
          userName: userInfo['userName'] ?? 'Unknown',
          userImage: userInfo['userImage'] ?? 'https://default-image-url.com/default.png',
          userLevel: userInfo['level'] ?? 1,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: const Text('실시간 채팅방'),
        backgroundColor: const Color(0xff73b1e7),
      ),
      body: Column(
        children: [
          // 메시지 리스트
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc('global_chat')
                  .collection('messages')
                  .orderBy('sentAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final senderId = message['senderId'];
                    final isMe = senderId == _currentUser?.uid;
                    final sentAt = message['sentAt'] as Timestamp?;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserInfo(senderId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final user = userSnapshot.data!;
                        final userName = user['userName'] ?? 'Unknown';
                        final userImage = user['userImage'] ?? 'https://default-image-url.com/default.png';
                        final formattedTime = sentAt != null ? _formatTimestamp(sentAt) : '';

                        return Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              GestureDetector(
                                onTap: () => _showUserInfoDialog(context, user),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(userImage),
                                  radius: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Column(
                              crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? '나' : userName,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blueAccent : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    message['messageText'] ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _showUserInfoDialog(context, user),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(userImage),
                                  radius: 20,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // 메시지 입력창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '메세지 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xff73b1e7)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
