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
              // Positioned.fill(child: Container(color: Colors.white)),
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // 캐릭터 이미지
              LayoutBuilder(
                builder: (context, constraints) {
                  final appearedCharacters = List<String>.from(
                    controller.appearedCharacters,
                  ); // 복사본

                  if (appearedCharacters.length == 2) {
                    // 이서아를 가운데로 배치
                    appearedCharacters.remove('이서아');
                    appearedCharacters.insert(1, '이서아');
                  } else if (appearedCharacters.length == 3) {
                    // 이서아를 가운데로 배치
                    appearedCharacters.remove('이서아');
                    appearedCharacters.insert(1, '이서아');
                  }

                  final newlyAppearedCharacters =
                      controller.newlyAppearedCharacters.toList();

                  final orderedRenderedCharacters =
                      appearedCharacters.map((character) => character).toList();
                  orderedRenderedCharacters.sort((a, b) {
                    // 이서아를 항상 처음으로
                    if (a == '이서아') return -1;
                    if (b == '이서아') return 1;
                    // 그 외 캐릭터는 알아서 렌더링
                    return a.compareTo(b);
                  });

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children:
                          orderedRenderedCharacters.map((character) {
                            final index = appearedCharacters.indexOf(character);
                            final total = appearedCharacters.length;
                            // 1명일땐 0, 2명일땐 조금 넓게, 3명일땐 좁게
                            final padding = constraints.maxWidth / total;
                            final offsetX = (index - (total - 1) / 2) * padding;
                            final isNew = newlyAppearedCharacters.contains(
                              character,
                            );

                            final baseContent = Transform.translate(
                              offset: Offset(offsetX, 0),
                              child: Transform.scale(
                                scale: 3.0,
                                child: SizedBox(
                                  key: ValueKey('char_$character'),
                                  width: 450,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 0.5,
                                    child: Image.asset(
                                      'assets/images/${character}_color.png',
                                      fit: BoxFit.contain,
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
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 50 * (1 - value)),
                                      child: baseContent,
                                    ),
                                  );
                                },
                              );
                            } else {
                              return baseContent;
                            }
                          }).toList(),
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
