import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';
import 'package:loveloveraid/model/npc.dart';
import 'package:loveloveraid/screen/end_screen.dart';
import 'package:loveloveraid/view/game_screen_view.dart';

class GameScreen extends StatefulWidget {
  final List<Npc> npcs;
  final String playerName;

  const GameScreen({super.key, required this.npcs, required this.playerName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameScreenController _controller;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = GameScreenController(
      onUpdate: () => setState(() {}),
      onEndChapter: () {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen()));
      },
      playerName: widget.playerName,
      npcs: widget.npcs,
    );

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
    _keyboardFocusNode.requestFocus();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _controller.handleKeyEvent(event);
      } else if (!_textFieldFocusNode.hasFocus) {
        _controller.handleKeyEvent(event);
      }
    }
    _textFieldFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenView(
      controller: _controller,
      textController: _textController,
      keyboardFocusNode: _keyboardFocusNode,
      textFieldFocusNode: _textFieldFocusNode,
      onSend: _handleSend,
      onKeyEvent: _handleKeyEvent,
    );
  }
}
