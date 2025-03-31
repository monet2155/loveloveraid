import 'package:flutter/material.dart';

class GameScreenView extends StatelessWidget {
  final String characterName;
  final String visibleText;
  final bool canSendMessage;
  final TextEditingController textController;
  final VoidCallback onSend;
  final VoidCallback onTap;
  final Function(KeyEvent) onKeyEvent;
  final FocusNode keyboardFocusNode; // KeyboardListener 전용 FocusNode
  final FocusNode textFieldFocusNode; // TextField 전용 FocusNode

  const GameScreenView({
    super.key,
    required this.characterName,
    required this.visibleText,
    required this.canSendMessage,
    required this.textController,
    required this.onSend,
    required this.onTap,
    required this.onKeyEvent,
    required this.keyboardFocusNode,
    required this.textFieldFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: keyboardFocusNode,
      onKeyEvent: onKeyEvent,
      autofocus: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent, // 텍스트필드 외부 탭 감지
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 배경
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              // 캐릭터 이미지
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.scale(
                  scale: 1.5,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.7,
                      child: Image.asset(
                        'assets/images/character_standing.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // 대화창/입력창
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child:
                      canSendMessage
                          ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: textController,
                                  focusNode: textFieldFocusNode,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: '메시지를 입력하세요',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => onSend(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: onSend,
                              ),
                            ],
                          )
                          : SizedBox(
                            height: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  characterName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  visibleText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
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
