import 'package:flutter/material.dart';

class TitleScreenView extends StatelessWidget {
  final VoidCallback onStartNewGame;
  final VoidCallback onContinue;
  final VoidCallback onOpenSettings;
  final VoidCallback onExitGame;

  const TitleScreenView({
    super.key,
    required this.onStartNewGame,
    required this.onContinue,
    required this.onOpenSettings,
    required this.onExitGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 변경
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/title_background.png', // 타이틀용 배경 이미지 필요
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // 이미지가 없을 경우 색상으로 대체
                return Container(
                  color: Colors.white, // 배경색을 흰색으로 변경
                );
              },
            ),
          ),

          // 타이틀 및 버튼 레이아웃
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 게임 로고/타이틀 (이미지로 교체)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Image.asset(
                    'assets/images/title.png',
                    width: 300, // 이미지 크기 조정 (필요에 따라 변경)
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        '타이틀 이미지를 찾을 수 없습니다',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      );
                    },
                  ),
                ),

                // 간격 조정
                const SizedBox(height: 30),

                // 버튼 그룹
                _buildMenuButton('새 게임', onStartNewGame),
                const SizedBox(height: 16),
                _buildMenuButton('이어하기', onContinue),
                const SizedBox(height: 16),
                _buildMenuButton('환경 설정', onOpenSettings),
                const SizedBox(height: 16),
                _buildMenuButton('게임 종료', onExitGame),
              ],
            ),
          ),

          // 하단 저작권 정보
          const Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Text(
                '© 2025 러브러브 레이드',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ), // 텍스트 색상 변경
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 240,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.pink.shade200,
          side: BorderSide(color: Colors.pink.shade200, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink.shade400,
          ),
        ),
      ),
    );
  }
}
