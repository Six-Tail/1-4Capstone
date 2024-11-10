import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 화면 탭 시 키보드 숨김
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '피드백',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context); // 뒤로 가기
            },
          ),
        ),
        backgroundColor: const Color(0xffffffff),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제출해 주신 피드백은 모두 정성스레 읽지만 하나하나 답변해 드리기 어렵습니다.',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 20),
              // 피드백 입력 창
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '좋은 점, 나쁜 점, 개선을 위한 제안, 잘못된 번역 등',
                  hintStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 취소 및 보내기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // 취소 버튼 클릭 시 화면 닫기
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.068,
                      width: screenWidth * 0.4,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 3, color: Colors.blue),
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 피드백 전송 로직 추가
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.068,
                      width: screenWidth * 0.4,
                      decoration: ShapeDecoration(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      child: const Text(
                        '보내기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '광고 제거 및 기능 잠금 해제',
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 10),
              const Text(
                '표시되지 않는 일정이 있습니까?',
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 10),
              const Text(
                '위젯 정보',
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(height: 10),
              const Text(
                '도움말',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
