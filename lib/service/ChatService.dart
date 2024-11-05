import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 채팅방 생성 또는 기존 채팅방 가져오기
  Future<DocumentReference> createOrGetChatRoom(List<String> userIds) async {
    // 이미 존재하는 채팅방이 있는지 확인
    final existingRoom = await _firestore.collection('chatRooms')
        .where('users', arrayContainsAny: userIds)
        .limit(1)
        .get();

    if (existingRoom.docs.isNotEmpty) {
      return existingRoom.docs.first.reference;
    } else {
      // 새 채팅방 생성
      final newRoom = await _firestore.collection('chatRooms').add({
        'users': userIds,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return newRoom;
    }
  }

  // 메시지 전송
  Future<void> sendMessage(String chatRoomId, String senderId, String messageText) async {
    await _firestore.collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'messageText': messageText,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  // 채팅방의 모든 메시지 가져오기 (실시간 업데이트 지원)
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore.collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots();
  }
}
