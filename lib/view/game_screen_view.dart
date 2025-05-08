import 'package:flutter/material.dart';
import 'package:loveloveraid/components/dot_pulse.dart';
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
              _buildBackground(),
              _buildCharacterImages(),
              _buildDialogAndInput(),
              if (controller.isInHistoryView) _buildHistoryIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryIndicator() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '히스토리 모드',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
    );
  }

  Widget _buildCharacterImages() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appearedCharacters = List<String>.from(
          controller.appearedCharacters,
        );

        if (appearedCharacters.length == 2 || appearedCharacters.length == 3) {
          appearedCharacters.remove('이서아');
          appearedCharacters.insert(1, '이서아');
        }

        final newlyAppearedCharacters =
            controller.newlyAppearedCharacters.toList();
        final orderedRenderedCharacters =
            appearedCharacters.map((character) => character).toList();
        orderedRenderedCharacters.sort((a, b) {
          if (a == '이서아') return -1;
          if (b == '이서아') return 1;
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
                  final padding = constraints.maxWidth / total;
                  final offsetX = (index - (total - 1) / 2) * padding;
                  final isNew = newlyAppearedCharacters.contains(character);

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
                          () => controller.markCharacterAsAnimated(character),
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
    );
  }

  Widget _buildDialogAndInput() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogBox(),
          controller.canSendMessage
              ? _buildInputBox()
              : Container(margin: const EdgeInsets.only(top: 16)),
        ],
      ),
    );
  }

  Widget _buildDialogBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                controller.isLoading
                    ? Container()
                    : Text(
                      controller.currentCharacter,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                controller.isLoading ? Container() : SizedBox(height: 8),
                controller.isLoading
                    ? _buildThreeDotsAnimation()
                    : Text(
                      controller.visibleText,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
              ],
            ),
          ),
          (controller.isLoading ||
                  (!controller.canSendMessage && !controller.isInHistoryView))
              ? Container()
              : _buildHistoryButtonMenu(),
        ],
      ),
    );
  }

  Positioned _buildHistoryButtonMenu() {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_upward,
              color:
                  controller.canGoToPreviousMessage
                      ? Colors.white
                      : Colors.white30,
              size: 20,
            ),
            onPressed:
                controller.canGoToPreviousMessage
                    ? controller.goToPreviousMessage
                    : null,
            tooltip: '이전 대화 (위쪽 방향키)',
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_downward,
              color:
                  controller.canSendMessage
                      ? Colors.white30
                      : controller.isInHistoryView
                      ? Colors.white
                      : Colors.white30,
              size: 20,
            ),
            onPressed:
                controller.canSendMessage
                    ? null
                    : controller.isInHistoryView
                    ? controller.goToNextMessage
                    : controller.skipOrNext,
            tooltip: '다음 대화 (아래쪽 방향키)',
          ),
        ],
      ),
    );
  }

  Widget _buildThreeDotsAnimation() {
    return Flexible(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DotPulse(delay: const Duration(milliseconds: 0)),
            const SizedBox(width: 8),
            DotPulse(delay: const Duration(milliseconds: 300)),
            const SizedBox(width: 8),
            DotPulse(delay: const Duration(milliseconds: 600)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
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
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
