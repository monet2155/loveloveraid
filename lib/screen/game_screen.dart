import 'package:flutter/material.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';
import 'package:loveloveraid/view/game_screen_view.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameScreenController(onUpdate: () => setState(() {}));
    _controller.loadDialogue();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _controller.onTap,
      child: GameScreenView(
        characterName: _controller.currentCharacter,
        visibleText: _controller.visibleText,
      ),
    );
  }
}
