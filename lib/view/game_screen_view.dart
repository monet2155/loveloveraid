import 'package:flutter/material.dart';
import 'package:google_speech/endless_streaming_service.dart';
import 'package:google_speech/google_speech.dart';
import 'package:loveloveraid/controller/game_screen_controller.dart';
import 'package:record/record.dart';
import 'package:flutter/services.dart' show rootBundle;

final alignments = [
  Alignment.bottomCenter,
  Alignment.bottomLeft,
  Alignment.bottomRight,
];

class GameScreenView extends StatefulWidget {
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
  State<GameScreenView> createState() => _GameScreenViewState();
}

class _GameScreenViewState extends State<GameScreenView> {
  bool isVoiceMode = false; // ✨ 모드 상태 추가

  Stream<List<int>> micStream = Stream.empty(); // ✨ 음성 인식 스트림 초기화
  AudioRecorder audioRecorder = AudioRecorder();

  void _toggleVoiceMode() {
    setState(() {
      isVoiceMode = !isVoiceMode;
      if (isVoiceMode) {
        _startVoiceRecognition();
      } else {
        _stopVoiceRecognition();
      }
    });
  }

  void _startVoiceRecognition() async {
    print('🎤 음성 인식 시작');

    if (!(await audioRecorder.hasPermission())) {
      print('🛑 음성 인식 권한 없음');
      return;
    }

    micStream = await audioRecorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    final json = await rootBundle.loadString('assets/service_account.json');
    final serviceAccount = ServiceAccount.fromString(json);

    final speechToText = EndlessStreamingService.viaServiceAccount(
      serviceAccount,
    );

    final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'ko-KR',
    );

    final responseStream = speechToText.endlessStream;

    speechToText.endlessStreamingRecognize(
      StreamingRecognitionConfig(config: config, interimResults: true),
      micStream,
    );

    responseStream.listen((data) {
      // https://github.com/felixjunghans/google_speech/blob/master/example/endless_streaming_example/lib/main.dart
      final currentText = data.results
          .where((e) => e.alternatives.isNotEmpty)
          .map((e) => e.alternatives.first.transcript)
          .join('\n');

      if (data.results.first.isFinal) {
        widget.textController.text += currentText;
      }
    }, onDone: () {});
  }

  void _stopVoiceRecognition() {
    print('🛑 음성 인식 종료');
    // 여기 STT 종료 코드 연결
    audioRecorder.stop();
  }

  @override
  void dispose() {
    super.dispose();
    audioRecorder.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.keyboardFocusNode,
      onKeyEvent: widget.onKeyEvent,
      autofocus: true,
      child: GestureDetector(
        onTap: widget.controller.skipOrNext,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              _buildBackground(),
              _buildCharacterImages(),
              _buildDialogAndInput(),
            ],
          ),
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
          widget.controller.appearedCharacters,
        );

        if (appearedCharacters.length == 2 || appearedCharacters.length == 3) {
          appearedCharacters.remove('이서아');
          appearedCharacters.insert(1, '이서아');
        }

        final newlyAppearedCharacters =
            widget.controller.newlyAppearedCharacters.toList();
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
                          () => widget.controller.markCharacterAsAnimated(
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
          widget.controller.canSendMessage
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
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.controller.currentCharacter,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.controller.visibleText,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
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
              controller: widget.textController,
              focusNode: widget.textFieldFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.mic,
              color:
                  isVoiceMode ? Colors.redAccent : Colors.white, // ✨ 활성화 시 빨간색
            ),
            onPressed: _toggleVoiceMode,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: widget.onSend,
          ),
        ],
      ),
    );
  }
}
