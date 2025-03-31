import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // 배경 이미지 경로
              fit: BoxFit.cover,
            ),
          ),

          /// 캐릭터 스탠딩 이미지 (중앙, 허벅지까지 자르기)
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.scale(
              scale: 1.5, // ✅ 먼저 확대
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.7, // 확대된 이미지의 상단만 보여줌
                  child: Image.asset(
                    'assets/images/character_standing.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          /// 대화 텍스트 박스
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '캐릭터 이름',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      '여기에 캐릭터의 대사가 들어갑니다. \n대화 내용은 여러 줄일 수 있습니다.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
