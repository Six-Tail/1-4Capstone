import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '제출해 주신 피드백은 모두 정성스레 읽지만 하나하나 답변해 드리기 어렵습니다.',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '좋은 점, 나쁜 점, 개선을 위한 제안, 잘못된 번역 등',
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blueGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 취소 버튼 클릭 시 화면 닫기
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 피드백 전송 로직 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('보내기'),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '광고 제거 및 기능 잠금 해제',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  '표시되지 않는 일정이 있습니까?',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  '위젯 정보',
                  style: TextStyle(color: Colors.blue),
                ),
                SizedBox(height: 10),
                Text(
                  '도움말',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
