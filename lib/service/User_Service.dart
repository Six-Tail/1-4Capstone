import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../rank/RankingScreen.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String defaultProfileImageUrl = 'https://drive.google.com/file/d/18KGbC7T_zNG-k2bWodK5cmUcRQ9b8xDE/';

  // 새로운 사용자를 Firestore에 저장하는 함수
  Future<void> saveUserIfNew(User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    if (!(await userDoc.get()).exists) {
      await userDoc.set({
        'userName': firebaseUser.displayName ?? 'Unknown',
        'userImage': firebaseUser.photoURL ?? defaultProfileImageUrl,
        'email': firebaseUser.email,
        'createdAt': FieldValue.serverTimestamp(),
        'level': 1,
        'currentExp': 0,
        'maxExp': 10,
        'phoneNumber': '', // 초기 전화번호 필드 추가
      });
    }
  }

  // 전화번호 업데이트 메서드
  Future<void> updateUserPhoneNumber(String uid, String phoneNumber) async {
    await _firestore.collection('users').doc(uid).update({
      'phoneNumber': phoneNumber,
    });
  }

  // 사용자 정보를 불러오는 함수 (전화번호 포함)
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user info: $e");
      }
      return null;
    }
  }

  // 사용자 경험치와 레벨을 업데이트하는 함수
  Future<void> updateUserLevelAndExp(String uid, int level, int currentExp, int maxExp) async {
    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({
      'level': level,
      'currentExp': currentExp,
      'maxExp': maxExp,
    });
  }

  // 사용자 레벨을 업데이트하는 유틸리티 함수
  Map<String, int> updateLevel(int currentExp, int level, int maxExp) {
    while (currentExp >= maxExp) {
      level += 1;
      currentExp -= maxExp;
      maxExp = (100 * pow(1.05, level - 1)).round(); // 다음 레벨 경험치 증가
    }
    return {'level': level, 'currentExp': currentExp, 'maxExp': maxExp};
  }

  // 모든 사용자 목록을 가져와 정렬 및 랭크 할당
  Future<List<AppUser>> getAllUsers() async {
    List<AppUser> userList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        userList.add(AppUser(
          name: data['userName'] ?? 'Unknown',
          level: data['level'] ?? 1,
          currentExp: data['currentExp'] ?? 0,
          rank: 0,
          profileImageUrl: data['userImage'] ?? defaultProfileImageUrl,
        ));
      }

      // 사용자 목록을 레벨과 경험치로 정렬
      userList.sort((a, b) {
        int levelComparison = b.level.compareTo(a.level);
        return levelComparison != 0 ? levelComparison : b.currentExp.compareTo(a.currentExp);
      });

      // 랭크 할당
      for (int i = 0; i < userList.length; i++) {
        userList[i] = userList[i].copyWith(rank: i + 1);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching users: $e");
      }
    }
    return userList;
  }

  // 태스크 상태 업데이트
  Future<void> updateTaskStatus(String uid, String taskName, DateTime? lastClaimedTime, {bool isCompleted = false, bool hasClaimedXP = false}) async {
    await _firestore.collection('users').doc(uid).collection('day tasks').doc(taskName).set({
      'hasClaimedXP': hasClaimedXP,
      'lastClaimedTime': lastClaimedTime,
      'isCompleted': isCompleted,
    }, SetOptions(merge: true));
  }

  // 태스크 상태 불러오기
  Future<Map<String, dynamic>?> getTaskStatus(String uid, String taskName) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).collection('day tasks').doc(taskName).get();
    return doc.data() as Map<String, dynamic>?;
  }
}
