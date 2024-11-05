import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/User_Service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final UserService _userService = UserService();

  // 사용자 정보를 캐싱하기 위한 맵
  Map<String, Map<String, dynamic>> userCache = {};

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
        userCache[uid] = userInfo; // 사용자 정보를 캐시에 저장
      }
      return userInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
        backgroundColor: const Color(0xff73b1e7),
      ),
      body: Column(
        children: [
          // 메시지 리스트
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc('global_chat') // 글로벌 채팅방 ID
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

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getUserInfo(senderId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final user = userSnapshot.data!;
                        final userName = user['userName'] ?? 'Unknown';
                        final userImage = user['userImage'] ?? 'https://default-image-url.com/default.png';

                        return ListTile(
                          leading: isMe
                              ? null
                              : CircleAvatar(
                            backgroundImage: NetworkImage(userImage),
                            radius: 20,
                          ),
                          title: Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? '나' : userName,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(top: 5),
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
                              ],
                            ),
                          ),
                          trailing: isMe
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(userImage),
                            radius: 20,
                          )
                              : null,
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
