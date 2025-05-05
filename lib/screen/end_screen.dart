import 'package:flutter/material.dart';
import 'package:loveloveraid/screen/title_screen.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 반투명 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/title_background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white),
            ),
          ),

          // 콘텐츠 영역
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 티저 텍스트
                  Text(
                    '정모 이후의 이야기가 궁금하다면?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 정식 출시 안내
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                  Text(
                    '2025년 4분기 출시 예정',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.pink.shade300,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 버튼
                  SizedBox(
                    width: 220,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.of(context).pushAndRemoveUntil(
                            // 처음 화면으로 돌아가기
                            MaterialPageRoute(
                              builder: (context) => const TitleScreen(),
                            ),
                            (route) => false,
                          ),
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shadowColor: Colors.pinkAccent.withOpacity(0.4),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.pink.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.pink.shade200,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        '처음으로 돌아가기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
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
