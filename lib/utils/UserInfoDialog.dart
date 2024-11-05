// UserInfoDialog.dart
import 'package:flutter/material.dart';

class UserInfoDialog extends StatelessWidget {
  final String userName;
  final String userImage;
  final int userLevel;

  UserInfoDialog({
    required this.userName,
    required this.userImage,
    required this.userLevel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(userImage),
            radius: 40,
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Level: $userLevel',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
