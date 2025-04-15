import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';
import 'package:loveloveraid/model/npc.dart';
import 'package:loveloveraid/view/game_screen_view.dart';

class GameScreen extends StatefulWidget {
  List<Npc> npcs;

  GameScreen({super.key, required this.npcs});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameScreenController _controller;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode(); // TextField 전용 FocusNode
  final FocusNode _keyboardFocusNode =
      FocusNode(); // KeyboardListener 전용 FocusNode

  @override
  void initState() {
    super.initState();
    _controller = GameScreenController(
      onUpdate: () => setState(() {}),
      npcs: widget.npcs,
    );

    // 키보드 이벤트를 계속 받기 위해 항상 포커스 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
      _keyboardFocusNode.requestFocus();
    });
  }

  void _handleSend() {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    _textController.clear();
    _controller.sendPlayerMessage(message);

    // 입력 후 다시 입력창 포커스
    _keyboardFocusNode.requestFocus();
  }

  void _handleKeyEvent(KeyEvent event) {
    // 입력창이 활성화된 경우 키보드 이벤트 무시 (TextField에서 처리)
    if (_textFieldFocusNode.hasFocus) return;

    // 입력창 외부에서는 전체 키 처리
    if (event is KeyDownEvent) {
      _controller.handleKeyEvent(event);
    }
    _textFieldFocusNode.requestFocus();
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
      onKeyEvent: _handleKeyEvent, // 키 이벤트 처리
      keyboardFocusNode: _keyboardFocusNode, // KeyboardListener 전용 FocusNode 전달
      textFieldFocusNode: _textFieldFocusNode, // TextField 전용 FocusNode 전달
    );
  }
}
