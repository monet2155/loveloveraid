import 'package:flutter/material.dart';

class PlayerNameInputScreen extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onSubmit;

  const PlayerNameInputScreen({
    super.key,
    required this.nameController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 변경
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // 패딩 조정
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '플레이어 이름을 입력하세요',
                style: TextStyle(
                  color: Colors.pink.shade400, // 텍스트 색상 변경
                  fontSize: 28, // 폰트 크기 증가
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24), // 간격 조정
              SizedBox(
                width: 300,
                child: TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.pink.shade400), // 텍스트 색상 변경
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    hintText: '김겜돌',
                    hintStyle: TextStyle(color: Colors.pink.shade200),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // 둥근 테두리
                      borderSide: BorderSide(color: Colors.pink.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pink.shade200),
                    ),
                    fillColor: Colors.white, // 배경색 추가
                  ),
                ),
              ),
              const SizedBox(height: 24), // 간격 조정
              SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: onSubmit,
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
                    "확인",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
