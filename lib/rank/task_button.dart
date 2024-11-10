import 'package:flutter/material.dart';

class TaskButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final IconData icon; // 아이콘 매개변수 추가

  const TaskButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.icon, // 아이콘 초기화
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 아이콘과 텍스트 중앙 정렬
        children: [
          Icon(
            icon, size: 30,
            color: const Color(0xff4496de)
          ), // 아이콘 추가
          const SizedBox(height: 8), // 아이콘과 텍스트 사이의 간격
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff4496de),
            ),
          ),
        ],
      ),
    );
  }
}
