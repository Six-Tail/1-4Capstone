import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/Themes.Colors.dart';

class CustomFloatingActionButton extends StatefulWidget {
  final Function() toggleMenu;
  final Function() addEvent;
  final bool isExpanded;
  final double rotationAngle;


  const CustomFloatingActionButton({
    super.key,
    required this.isExpanded,
    required this.rotationAngle,
    required this.toggleMenu,
    required this.addEvent,
  });

  @override
  _CustomFloatingActionButtonState createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton> {
  double _opacity = 1.0;  // 초기 투명도는 1.0 (완전히 불투명)
  Timer? _fadeTimer;
  Timer? _collapseTimer;
  bool _isExpanded = false;  // 버튼 확장 상태
  double _rotationAngle = 0.0;  // 아이콘 회전 상태

  @override
  void initState() {
    super.initState();
    _startFadeTimer();  // 타이머 시작
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();  // 위젯 종료 시 타이머 취소
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();  // 기존 타이머 취소
    _fadeTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _opacity = 0.3;  // 3초 후 투명도를 50%로 감소
      });
    });
  }

  void _resetButtonState() {
    setState(() {
      _opacity = 1.0;  // 버튼 상태 초기화 (투명도를 원래 상태로)
    });
    _startFadeTimer();  // 타이머 재시작
  }

  void _startCollapseTimer() {
    _collapseTimer?.cancel();  // 기존 타이머 취소
    _collapseTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isExpanded = false;  // 3초 후 확장 상태 풀기
        _rotationAngle = 0.0;  // 회전 상태 초기화
      });
    });
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;  // 확장 상태 토글
      _rotationAngle = _isExpanded ? 0.25 : 0.0;  // 아이콘 회전 (0.25 turns == 90도 회전)
    });
    _resetButtonState();  // 버튼 상태 초기화
    if (_isExpanded) {
      _startCollapseTimer();  // 확장되면 타이머 시작
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Positioned(
          bottom: 80,
          right: 16,
          child: IgnorePointer(
            ignoring: !_isExpanded,
            child: AnimatedOpacity(
              opacity: _isExpanded ? _opacity : 0.0,  // 투명도 적용
              duration: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'AddTask',
                    onPressed: () {
                      widget.addEvent();
                      _resetButtonState();  // 일정 추가 후 상태 초기화
                    },
                    label: const Text('일정 추가'),
                    icon: const Icon(Icons.add),
                    backgroundColor: Theme1Colors.textColor,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: AnimatedOpacity(
            opacity: _opacity,  // 투명도 적용
            duration: const Duration(milliseconds: 300),
            child: AnimatedRotation(
              turns: _rotationAngle,  // 회전 애니메이션
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: _toggleMenu,  // 토글 동작 수정
                backgroundColor: Color(0xff73b1e7),
                child: Icon(_isExpanded ? Icons.close : Icons.add),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
