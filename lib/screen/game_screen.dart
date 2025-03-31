import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<DialogueLine> _dialogue = [];
  int _currentIndex = 0;
  String _visibleText = '';
  Timer? _textTimer;

  static const Duration textSpeed = Duration(milliseconds: 40);
  @override
  void initState() {
    super.initState();
    _loadDialogue();
  }

  Future<void> _loadDialogue() async {
    final String jsonString = await rootBundle.loadString(
      'assets/dialogue.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _dialogue.addAll(jsonData.map((e) => DialogueLine.fromJson(e)));
    });
    _showNextLine();
  }

  void _showNextLine() {
    if (_currentIndex >= _dialogue.length) return;
    _visibleText = '';
    final fullText = _dialogue[_currentIndex].text;
    int charIndex = 0;
    _textTimer?.cancel();
    _textTimer = Timer.periodic(textSpeed, (timer) {
      setState(() {
        _visibleText += fullText[charIndex];
      });
      charIndex++;
      if (charIndex >= fullText.length) {
        timer.cancel();
      }
    });
  }

  void _onTap() {
    if (_textTimer?.isActive ?? false) {
      _textTimer?.cancel();
      setState(() {
        _visibleText = _dialogue[_currentIndex].text;
      });
    } else {
      if (_currentIndex < _dialogue.length - 1) {
        _currentIndex++;
        _showNextLine();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final characterName =
        _dialogue.isNotEmpty ? _dialogue[_currentIndex].character : '';
    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.black,
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
                margin: const EdgeInsets.all(16), // 좌우 여백 제거
                padding: const EdgeInsets.all(16),
                height: 150,
                width: double.infinity, // 너비를 화면 전체로 설정
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      characterName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        _visibleText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogueLine {
  final String character;
  final String text;

  DialogueLine({required this.character, required this.text});

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      character: json['character'] as String,
      text: json['text'] as String,
    );
  }
}
