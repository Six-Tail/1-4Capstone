// lib/services/user_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore에 사용자 정보를 저장하는 함수
  Future<void> saveUserIfNew(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    // 이미 사용자 정보가 저장되어 있는지 확인
    if (!(await userDoc.get()).exists) {
      await userDoc.set({
        'userName': user.displayName ?? 'Unknown',
        'userImage': user.photoURL ?? '',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Firestore에서 사용자 정보를 불러오는 함수
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }
}
