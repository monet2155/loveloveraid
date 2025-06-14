import 'package:flutter/material.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';
import 'package:loveloveraid/screen/title_screen.dart';

/// A reusable popup‑menu button that mirrors the main menu in `GameScreenView`.
///
/// Place it anywhere in your UI (typically top‑right) to provide quick access to
/// help, settings, save/load, and home navigation.
class GameMenuButtonScreen extends StatelessWidget {
   final GameScreenController controller;
   
  const GameMenuButtonScreen({super.key,  required this.controller,});

  @override
  Widget build(BuildContext context) {
     return Positioned(
      top: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white70),
          tooltip: '메뉴',
          color: Colors.black.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'help',
                  child: Text('도움말', style: TextStyle(color: Colors.white70)),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('설정', style: TextStyle(color: Colors.white70)),
                ),
                const PopupMenuItem<String>(
                  value: 'save',
                  child: Text('저장하기', style: TextStyle(color: Colors.white70)),
                ),
                const PopupMenuItem<String>(
                  value: 'load',
                  child: Text('불러오기', style: TextStyle(color: Colors.white70)),
                ),
                const PopupMenuItem<String>(
                  value: 'historyPopup',
                  child: Text(
                    '전체 히스토리 보기',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'home',
                  child: Text('홈으로', style: TextStyle(color: Colors.white70)),
                ),
              ],
          onSelected: (String value) {
            switch (value) {
              case 'settings':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('준비중입니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
                break;
              case 'save':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('준비중입니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
                break;
              case 'load':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('준비중입니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
                break;
              case 'help':
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.black.withOpacity(0.9),
                      title: const Text(
                        '도움말',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '스페이스바 또는 엔터 : 진행',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '위아래 방향키 : 대화 기록 보기',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "'Ctrl + V' 키 : UI 숨기기/숨기기 해제",
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "'Ctrl + H' 키 : 전체 히스토리 보기",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            '확인',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    );
                  },
                );
                break;
              case 'home':
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const TitleScreen()),
                  (route) => false,
                );
                break;
              case 'historyPopup':
                controller.showHistoryPopup();
                break;
            }
          },
        ),
      ),
    );
  }
}