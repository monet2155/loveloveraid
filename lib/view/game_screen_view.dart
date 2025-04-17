import 'package:flutter/material.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';

final alignments = [
  Alignment.bottomCenter,
  Alignment.bottomLeft,
  Alignment.bottomRight,
];

class GameScreenView extends StatelessWidget {
  final GameScreenController controller;
  final TextEditingController textController;
  final FocusNode keyboardFocusNode;
  final FocusNode textFieldFocusNode;
  final VoidCallback onSend;
  final Function(KeyEvent) onKeyEvent;

  const GameScreenView({
    super.key,
    required this.controller,
    required this.textController,
    required this.keyboardFocusNode,
    required this.textFieldFocusNode,
    required this.onSend,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: keyboardFocusNode,
      onKeyEvent: onKeyEvent,
      autofocus: true,
      child: GestureDetector(
        onTap: controller.skipOrNext,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 배경
              Positioned.fill(child: Container(color: Colors.white)),
              // 캐릭터 이미지
              LayoutBuilder(
                builder: (context, constraints) {
                  final appearedCharacters =
                      controller.appearedCharacters.toList();
                  final newlyAppearedCharacters =
                      controller.newlyAppearedCharacters.toList();

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeInOut,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: Row(
                        key: ValueKey(
                          controller.appearedCharacters.join(','),
                        ), // 위치 변화를 감지
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children:
                            appearedCharacters.map((character) {
                              final isCurrent =
                                  character == controller.currentCharacter;
                              final isNew = newlyAppearedCharacters.contains(
                                character,
                              );

                              final content = SizedBox(
                                key: ValueKey('char_$character'),
                                width: 400,
                                child: Opacity(
                                  opacity: isCurrent ? 1.0 : 0.5,
                                  child: Transform.scale(
                                    scale: 1.5,
                                    child: ClipRect(
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        heightFactor: 0.7,
                                        child: Image.asset(
                                          'assets/images/${character}_color.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              if (isNew) {
                                return TweenAnimationBuilder<double>(
                                  key: ValueKey('anim_$character'),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  onEnd:
                                      () => controller.markCharacterAsAnimated(
                                        character,
                                      ),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 50 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: content,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return content;
                              }
                            }).toList(),
                      ),
                    ),
                  );
                },
              ),

              // 대화창/입력창
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.currentCharacter,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.visibleText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    controller.canSendMessage
                        ? Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: Row(
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
                          ),
                        )
                        : Container(margin: const EdgeInsets.only(top: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
