import 'dart:ui';

import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final bool isStudyMode;
  final Duration remainingTime;

  const TimerDisplay({
    required this.isStudyMode,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 20,
        ),
        children: [
          TextSpan(
            text: isStudyMode ? '休憩まで　' : '休憩中　',
          ),
          TextSpan(
            text: '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

