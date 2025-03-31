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
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = GameScreenController(onUpdate: () => setState(() {}));
  }

  void _handleSend() {
    final message = _textController.text.trim();
    if (message.isEmpty) return;
    _textController.clear();
    _controller.sendPlayerMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenView(
      characterName: _controller.currentCharacter,
      visibleText: _controller.visibleText,
      canSendMessage: _controller.canSendMessage,
      textController: _textController,
      onSend: _handleSend,
      onTap: _controller.skipOrNext,
    );
  }
}
