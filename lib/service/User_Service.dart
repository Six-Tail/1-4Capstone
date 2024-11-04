import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../rank/RankingScreen.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String defaultProfileImageUrl = 'https://yourfirebaseapp.appspot.com/default_profile.jpg'; // Firebase Storage의 URL로 설정

  // Firestore에 사용자 기본 정보를 설정하는 공통 메서드
  Map<String, dynamic> _defaultUserData(User firebaseUser) {
    return {
      'userName': firebaseUser.displayName ?? 'Unknown',
      'userImage': firebaseUser.photoURL ?? defaultProfileImageUrl,
      'email': firebaseUser.email,
      'createdAt': FieldValue.serverTimestamp(),
      'level': 1,
      'currentExp': 0,
      'maxExp': 10,
      'phoneNumber': '',
      'birthday': '',
      'gender': '',
    };
  }

  // 새로운 사용자를 Firestore에 저장
  Future<void> saveUserIfNew(User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    if (!(await userDoc.get()).exists) {
      await userDoc.set(_defaultUserData(firebaseUser));
    }
  }

  // 사용자 전화번호 업데이트
  Future<void> updateUserPhoneNumber(String uid, String phoneNumber) async {
    await _firestore.collection('users').doc(uid).update({
      'phoneNumber': phoneNumber,
    });
  }

  // 프로필 이미지 업로드 및 URL 반환
  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      final storageRef = _storage.ref().child('user_images/$uid.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading profile image: $e");
      }
      return null;
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserInfo(String uid, {String? userName, String? birthday, String? gender, String? profileImageUrl}) async {
    Map<String, dynamic> updates = {};
    if (userName != null) updates['userName'] = userName;
    if (birthday != null) updates['birthday'] = birthday;
    if (gender != null) updates['gender'] = gender;
    if (profileImageUrl != null) updates['userImage'] = profileImageUrl;
    await _firestore.collection('users').doc(uid).update(updates);
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user info: $e");
      }
      return null;
    }
  }

  // 사용자 경험치와 레벨 업데이트
  Future<void> updateUserLevelAndExp(String uid, int level, int currentExp, int maxExp) async {
    await _firestore.collection('users').doc(uid).update({
      'level': level,
      'currentExp': currentExp,
      'maxExp': maxExp,
    });
  }

  // 레벨 계산 함수
  Map<String, int> updateLevel(int currentExp, int level, int maxExp) {
    while (currentExp >= maxExp) {
      level += 1;
      currentExp -= maxExp;
      maxExp = (100 * pow(1.05, level - 1)).round();
    }
    return {'level': level, 'currentExp': currentExp, 'maxExp': maxExp};
  }

  // 모든 사용자 목록 가져오기 및 정렬
  Future<List<AppUser>> getAllUsers() async {
    List<AppUser> userList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        userList.add(AppUser(
          uid: doc.id,
          name: data['userName'] ?? 'Unknown',
          level: data['level'] ?? 1,
          currentExp: data['currentExp'] ?? 0,
          rank: 0,
          profileImageUrl: data['userImage'] ?? defaultProfileImageUrl,
        ));
      }

      // 정렬 및 랭크 할당
      userList.sort((a, b) => b.level.compareTo(a.level) != 0 ? b.level.compareTo(a.level) : b.currentExp.compareTo(a.currentExp));
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
  Future<void> updateDailyTaskStatus(String uid, String taskName, DateTime? lastClaimedTime, {bool isCompleted = false, bool hasClaimedXP = false}) async {
    await _firestore.collection('users').doc(uid).collection('daily tasks').doc(taskName).set({
      'hasClaimedXP': hasClaimedXP,
      'lastClaimedTime': lastClaimedTime,
      'isCompleted': isCompleted,
    }, SetOptions(merge: true));
  }

  // 태스크 상태 가져오기
  Future<Map<String, dynamic>?> getDailyTaskStatus(String uid, String taskName) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).collection('daily tasks').doc(taskName).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // 태스크 상태 업데이트
  Future<void> updateWeeklyTaskStatus(String uid, String taskName, DateTime? lastClaimedTime, {bool isCompleted = false, bool hasClaimedXP = false, required int currentAttendance}) async {
    await _firestore.collection('users').doc(uid).collection('weekly tasks').doc(taskName).set({
      'hasClaimedXP': hasClaimedXP,
      'lastClaimedTime': lastClaimedTime,
      'isCompleted': isCompleted,
    }, SetOptions(merge: true));
  }

  // 태스크 상태 가져오기
  Future<Map<String, dynamic>?> getWeeklyTaskStatus(String uid, String taskName) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).collection('weekly tasks').doc(taskName).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // 태스크 상태 업데이트
  Future<void> updateChallengeTaskStatus(String uid, String taskName, DateTime? lastClaimedTime, {bool isCompleted = false, bool hasClaimedXP = false, required int currentAttendance}) async {
    await _firestore.collection('users').doc(uid).collection('challenge tasks').doc(taskName).set({
      'hasClaimedXP': hasClaimedXP,
      'lastClaimedTime': lastClaimedTime,
      'isCompleted': isCompleted,
    }, SetOptions(merge: true));
  }

  // 태스크 상태 가져오기
  Future<Map<String, dynamic>?> getChallengeTaskStatus(String uid, String taskName) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).collection('challenge tasks').doc(taskName).get();
    return doc.data() as Map<String, dynamic>?;
  }
}
