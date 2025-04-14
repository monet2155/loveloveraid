import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loveloveraid/view/title_screen_view.dart';
import 'package:loveloveraid/screen/game_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  @override
  Widget build(BuildContext context) {
    return TitleScreenView(
      onStartGame: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      },
      onOpenSettings: () {
        // TODO: 설정 화면으로 이동
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('설정'),
                content: const Text('설정 화면은 준비 중입니다'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      },
      onExitGame: () {
        if (Platform.isAndroid || Platform.isIOS) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('종료 확인'),
                  content: const Text('게임을 종료하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => exit(0),
                      child: const Text('종료'),
                    ),
                  ],
                ),
          );
        } else {
          exit(0);
        }
      },
    );
  }
}
