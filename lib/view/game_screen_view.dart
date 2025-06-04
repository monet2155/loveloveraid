import 'package:flutter/material.dart';
import 'package:loveloveraid/components/dot_pulse.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';
import 'package:loveloveraid/model/dialogue_line.dart';
import 'package:loveloveraid/screen/title_screen.dart';
import 'package:loveloveraid/services/resource_manager.dart';
import 'package:loveloveraid/view/history_popup_view.dart';

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
  static bool _alreadyOpenedPopup = false;

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
    // 전체 히스토리

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isHistoryPopupView && !_alreadyOpenedPopup) {
        _alreadyOpenedPopup = true;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => HistoryPopupView(
                logs: controller.dialogueHistory,
                onClose: () {
                  Navigator.of(context).pop();
                  controller.showHistoryPopup(); // 상태 false로 토글
                  _alreadyOpenedPopup = false;
                },
              ),
        ).then((_) {
          // 다이얼로그가 닫히면 플래그 초기화
          _alreadyOpenedPopup = false;
          if (controller.isHistoryPopupView) {
            controller.showHistoryPopup(); // 상태 false로 맞추기
          }
        });
      }
    });

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
              if (controller.isUIVisible) ...[
                _buildDialogAndInput(),
                if (controller.isInHistoryView) _buildHistoryIndicator(),
<<<<<<< HEAD
                Positioned(
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
                              child: Text(
                                '도움말',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'settings',
                              child: Text(
                                '설정',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'save',
                              child: Text(
                                '저장하기',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'load',
                              child: Text(
                                '불러오기',
                                style: TextStyle(color: Colors.white70),
                              ),
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
                              child: Text(
                                '홈으로',
                                style: TextStyle(color: Colors.white70),
                              ),
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
                                  backgroundColor: Colors.black.withOpacity(
                                    0.9,
                                  ),
                                  title: const Text(
                                    '도움말',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      onPressed:
                                          () => Navigator.of(context).pop(),
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
                              MaterialPageRoute(
                                builder: (context) => const TitleScreen(),
                              ),
                              (route) => false,
                            );
                            break;
                          case 'historyPopup':
                            controller.showHistoryPopup();
                            // if (controller.isHistoryPopupView) {
                            //   Future.microtask(() {
                            //     showDialog(
                            //       context: context,
                            //       barrierDismissible: true,
                            //       builder:
                            //           (context) => HistoryPopupView(
                            //             logs: controller.dialogueHistory,
                            //             onClose: () {
                            //               Navigator.of(
                            //                 context,
                            //               ).pop(); // 다이얼로그 닫기
                            //               controller
                            //                   .showHistoryPopup(); // 상태 변경
                            //             },
                            //           ),
                            //     );
                            //   });
                            // }
                            break;
                        }
                      },
                    ),
                  ),
                ),
=======
                buildMenu(context),
>>>>>>> d1009472817351aae0d9adf8423a54818c3d279d
              ],
            ],
          ),
        ),
      ),
    );
  }

  Positioned buildMenu(BuildContext context) {
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
            }
          },
        ),
      ),
    );
  }

  Widget _buildHistoryIndicator() {
    return Positioned(
      top: 20,
      left: 20,
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
      child: Image.memory(
        ResourceManager().imageCache['background.jpg']!,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCharacterImages() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appearedCharacters = List<String>.from(
          controller.appearedCharacters,
        );

        final orderedRenderedCharacters =
            appearedCharacters.map((character) => character).toList();
        // 이서아를 적절한 위치로 이동
        if (orderedRenderedCharacters.contains('이서아')) {
          orderedRenderedCharacters.remove('이서아');
          // 다른 캐릭터가 있을 때만 2번째 위치로 이동
          if (orderedRenderedCharacters.isNotEmpty) {
            orderedRenderedCharacters.insert(1, '이서아');
          } else {
            orderedRenderedCharacters.add('이서아');
          }
        }
        final newlyAppearedCharacters =
            controller.newlyAppearedCharacters.toList();
        return Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (orderedRenderedCharacters.contains('이서아')) ...[
                Builder(
                  builder: (context) {
                    final character = '이서아';
                    final index = orderedRenderedCharacters.indexOf(character);
                    final total = orderedRenderedCharacters.length;
                    final padding = constraints.maxWidth / total;
                    final offsetX = (index - (total - 1) / 2) * padding;
                    final isNew = newlyAppearedCharacters.contains(character);

                    final characterId =
                        ResourceManager().characterResources
                            .firstWhere((element) => element.name == character)
                            .id;

                    final currentFace =
                        controller.characterFaces[character] ?? '001';
                    final imageKey = '${characterId}_$currentFace.png';
                    final characterImage =
                        ResourceManager().imageCache[imageKey] ??
                        ResourceManager().imageCache['${characterId}_001.png']!;

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
                            child: Image.memory(
                              characterImage,
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
                  },
                ),
              ],
              ...orderedRenderedCharacters
                  .where((character) => character != '이서아')
                  .map((character) {
                    final index = orderedRenderedCharacters.indexOf(character);
                    final total = orderedRenderedCharacters.length;
                    final padding = constraints.maxWidth / total;
                    final offsetX = (index - (total - 1) / 2) * padding;
                    final isNew = newlyAppearedCharacters.contains(character);

                    final characterId =
                        ResourceManager().characterResources
                            .firstWhere((element) => element.name == character)
                            .id;
                    final currentFace =
                        controller.characterFaces[character] ?? '001';
                    final imageKey = '${characterId}_$currentFace.png';
                    final characterImage =
                        ResourceManager().imageCache[imageKey] ??
                        ResourceManager().imageCache['${characterId}_001.png']!;

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
                            child: Image.memory(
                              characterImage,
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
                  }),
            ],
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
