import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth에서 User 가져오기
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../rank/RankingScreen.dart'; // 사용자 정의 User 모델 임포트

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserIfNew(User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);

    // 사용자 정보가 없는 경우에만 저장
    if (!(await userDoc.get()).exists) {
      await userDoc.set({
        'userName': firebaseUser.displayName ?? 'Unknown', // displayName 사용
        'userImage': firebaseUser.photoURL ?? '',
        'email': firebaseUser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'currentExp': 0,
        'maxExp': 10,
      });
    }
  }

  // 사용자 정보를 업데이트하는 함수
  Future<void> updateUserLevelAndExp(String uid, int level, int currentExp,
      int maxExp) async {
    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({
      'level': level,
      'currentExp': currentExp,
      'maxExp': maxExp,
    });
  }

  // Firestore에서 사용자 정보를 불러오는 함수
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?; // 사용자 문서가 존재할 경우 데이터 반환
      } else {
        return null; // 문서가 존재하지 않으면 null 반환
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user info: $e");
      }
      return null; // 오류 발생 시 null 반환
    }
  }

  // 사용자 정보를 가져오는 함수
  Future<List<AppUser>> getAllUsers() async {
    List<AppUser> userList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        userList.add(AppUser(
          name: data['userName'] ?? 'Unknown',
          level: data['level'] ?? 1,
          currentExp: data['currentExp'] ?? 0, // 현재 경험치 추가
          rank: 0, // 초기 rank를 0으로 설정
        ));
      }

      // 사용자 데이터를 레벨과 경험치에 따라 내림차순으로 정렬
      userList.sort((a, b) {
        // 레벨 비교
        int levelComparison = b.level.compareTo(a.level);
        if (levelComparison != 0) return levelComparison;

        // 레벨이 같으면 경험치 비교
        return b.currentExp.compareTo(a.currentExp);
      });

      // 랭크 할당
      for (int i = 0; i < userList.length; i++) {
        userList[i] = userList[i].copyWith(rank: i + 1); // i + 1로 랭크 설정
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users: $e");
      }
    }
    return userList; // 사용자 목록 반환
  }
}