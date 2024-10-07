import 'package:flutter/material.dart';

import '../../utils/Themes.Colors.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final bool isExpanded;
  final double rotationAngle;
  final Function() toggleMenu;
  final Function() addEvent;

  const CustomFloatingActionButton({
    super.key,
    required this.isExpanded,
    required this.rotationAngle,
    required this.toggleMenu,
    required this.addEvent,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Positioned(
          bottom: 80,
          right: 16,
          child: IgnorePointer(
            ignoring: !isExpanded,
            child: AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'AddTask',
                    onPressed: addEvent,
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
          child: AnimatedRotation(
            turns: rotationAngle,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              onPressed: toggleMenu,
              backgroundColor: Theme1Colors.textColor,
              child: Icon(isExpanded ? Icons.close : Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
