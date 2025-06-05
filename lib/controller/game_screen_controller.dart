import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:loveloveraid/model/dialogue_line.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loveloveraid/model/npc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loveloveraid/constants/game_constants.dart';
import 'package:loveloveraid/exceptions/game_exception.dart';
import 'package:loveloveraid/services/game_api_service.dart';
import 'package:loveloveraid/services/tts_service.dart' as tts;
import 'package:loveloveraid/model/game_screen_state.dart';
import 'package:loveloveraid/view/history_popup_view.dart';

class GameScreenController {
  final String playerName;
  final Function onUpdate;
  final Function onEndChapter;
  final List<Npc> npcs;
  final GameApiService _apiService;
  final tts.TTSService _ttsService;

  GameScreenState _state = GameScreenState();
  Timer? _textTimer;
  final player = AudioPlayer();

  static const Duration textSpeed = Duration(
    milliseconds: GameConstants.TEXT_SPEED_MS,
  );

  String get currentCharacter => _state.currentLine?.character ?? '';
  String get currentFace {
    if (_state.currentLine == null) return '001';
    final character = _state.currentLine!.character;
    return _state.characterFaces[character] ?? '001';
  }

  String get visibleText => _state.visibleText;
  Map<String, String> get characterFaces => _state.characterFaces;
  bool get canSendMessage =>
      !_state.isDialoguePlaying &&
      !_state.isWaitingForTap &&
      !_state.isInHistoryView &&
      !_state.isLoading;

  bool get isLoading => _state.isLoading;
  Set<String> get appearedCharacters => _state.appearedCharacters;
  Set<String> get newlyAppearedCharacters =>
      _state.appearedCharacters.difference(_state.animatedCharacters);
  bool get canGoToPreviousMessage =>
      _state.isInHistoryView
          ? _state.currentHistoryIndex > 0
          : _state.currentDialogueIndex > 0;
  bool get canGoToNextMessage =>
      _state.isInHistoryView
          ? _state.currentHistoryIndex < _state.dialogues.length - 1
          : _state.currentDialogueIndex < _state.dialogues.length - 1;
  bool get isInHistoryView => _state.isInHistoryView;
  bool get isUIVisible => _state.isUIVisible;
  bool get isHistoryPopupView => _state.isHistoryPopupView;
  List<DialogueLine> get dialogueHistory => _state.dialogues;
  int get currentDialogueIndex => _state.currentDialogueIndex;

  bool isEnd = false;

  GameScreenController({
    required this.playerName,
    required this.onUpdate,
    required this.onEndChapter,
    required this.npcs,
  }) : _apiService = GameApiService(),
       _ttsService = tts.TTSService();

  void _updateState(GameScreenState newState) {
    _state = newState;
    onUpdate();
  }

  void markCharacterAsAnimated(String character) {
    _updateState(
      _state.copyWith(
        animatedCharacters: {..._state.animatedCharacters, character},
      ),
    );
  }

  Future<void> init() async {
    _updateState(_state.copyWith(isLoading: true));
    await initSession();
    _updateState(_state.copyWith(appearedCharacters: {}, isLoading: false));
  }

  Future<void> sendPlayerMessage(String message) async {
    if (!canSendMessage || _state.sessionId == null) return;

    _updateState(_state.copyWith(isDialoguePlaying: true, isLoading: true));

    try {
      final dialogueResponse = await _apiService.sendDialogue(
        _state.sessionId!,
        message,
      );

      if (dialogueResponse.state == "ended") {
        isEnd = true;
      }

      // 대화 히스토리에 플레이어 메시지 추가
      final newHistory = [
        ..._state.dialogues,
        DialogueLine(character: playerName, text: message, face: ''),
      ];

      _updateState(
        _state.copyWith(
          dialogues: newHistory,
          currentDialogueIndex: newHistory.length - 1,
          currentHistoryIndex: newHistory.length - 1,
          isInHistoryView: false,
        ),
      );

      for (var response in dialogueResponse.responses) {
        addDialogue(response.character, response.text, response.face);
      }
    } catch (e) {
      _handleError(NetworkException('서버와의 통신 중 오류가 발생했습니다.', originalError: e));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }

    _playNextLine();
  }

  void _playNextLine() {
    if (_state.currentDialogueIndex + 1 >= _state.dialogues.length) {
      _updateState(
        _state.copyWith(isDialoguePlaying: false, isWaitingForTap: false),
      );
      if (isEnd) {
        onEndChapter();
      }
      return;
    }

    final nextIndex = _state.currentDialogueIndex + 1;
    final currentLine = _state.dialogues[nextIndex];

    // 캐릭터 표정 업데이트
    final newCharacterFaces = Map<String, String>.from(_state.characterFaces);
    if (currentLine.face.isNotEmpty) {
      newCharacterFaces[currentLine.character] = currentLine.face;
    }

    // 등장 캐릭터 집합 업데이트
    final newAppeared = {..._state.appearedCharacters, currentLine.character};

    _updateState(
      _state.copyWith(
        currentDialogueIndex: nextIndex,
        currentLine: currentLine,
        visibleText: '',
        isDialoguePlaying: true,
        isWaitingForTap: false,
        characterFaces: newCharacterFaces,
        appearedCharacters: newAppeared,
      ),
    );

    if (currentCharacter != '시스템') {
      if (kDebugMode && GameConstants.USING_TTS) {
        if (player.playing) player.stop();
        playTTS(currentCharacter, currentLine.text);
      }
    }

    int charIndex = 0;
    _textTimer?.cancel();
    _textTimer = Timer.periodic(textSpeed, (timer) {
      _updateState(
        _state.copyWith(
          visibleText: _state.visibleText + currentLine.text[charIndex],
        ),
      );
      charIndex++;
      if (charIndex >= currentLine.text.length) {
        timer.cancel();
        _updateState(
          _state.copyWith(isWaitingForTap: true, isDialoguePlaying: false),
        );
        if (_state.currentDialogueIndex + 1 >= _state.dialogues.length) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_state.isWaitingForTap) {
              skipOrNext();
            }
          });
        }
      }
    });
  }

  void goToPreviousMessage() {
    // 로딩중에 이벤트 처리 return
    if (_state.isLoading) return;

    if (_state.isInHistoryView) {
      if (_state.currentHistoryIndex > 0) {
        final prevIndex = _state.currentHistoryIndex - 1;
        _updateState(_state.copyWith(currentHistoryIndex: prevIndex));
        _showHistoryMessage(index: prevIndex);
      }
    } else {
      // 처음 히스토리 진입 시, currentDialogueIndex를 기준으로 시작
      final currentIndex = _state.currentDialogueIndex;

      if (currentIndex > 0) {
        _updateState(
          _state.copyWith(
            isInHistoryView: true,
            //
            currentHistoryIndex: currentIndex - 1,
          ),
        );
        _showHistoryMessage(index: currentIndex - 1);
      }
    }
  }

  void goToNextMessage() {
    // 로딩중에 이벤트 처리 return
    if (_state.isLoading) return;

    if (_state.isInHistoryView) {
      final current = _state.currentHistoryIndex;
      final target = _state.currentDialogueIndex;

      if (current < target) {
        final nextIndex = current + 1;
        final isLast = nextIndex == target;

        _updateState(
          _state.copyWith(
            currentHistoryIndex: nextIndex,
            isInHistoryView: !isLast, // 마지막이면 히스토리 모드 종료
          ),
        );

        _showHistoryMessage(index: nextIndex);

        if (isLast) {
          // 마지막 메시지 본 직후 대화 상태 전환
          if (_state.currentDialogueIndex < _state.dialogues.length - 1) {
            _updateState(
              _state.copyWith(isDialoguePlaying: true, isWaitingForTap: true),
            );
          } else {
            skipOrNext();
          }
        }
      }
    } else {
      skipOrNext();
    }
  }

  void _showHistoryMessage({required int index}) {
    if (index < 0 || index >= _state.dialogues.length) return;

    _textTimer?.cancel();
    final historyLine = _state.dialogues[index];
    _updateState(
      _state.copyWith(
        currentLine: historyLine,
        visibleText: historyLine.text,
        isWaitingForTap: false,
        isDialoguePlaying: false,
      ),
    );
  }

  void showHistoryPopup() {
    if (_state.isLoading) return;

    //히스토리 팝업 이벤트 처리
    _updateState(
      _state.copyWith(isHistoryPopupView: !_state.isHistoryPopupView),
    );

    print("showHistoryPopup");
  }

  void skipOrNext() {
    if (_state.isInHistoryView) {
      goToNextMessage();
      return;
    }

    if (_textTimer?.isActive ?? false) {
      _textTimer?.cancel();
      _updateState(
        _state.copyWith(
          visibleText: _state.currentLine?.text ?? '',
          isWaitingForTap: true,
          isDialoguePlaying: false,
        ),
      );
    } else if (_state.isWaitingForTap) {
      _updateState(
        _state.copyWith(isWaitingForTap: false, isDialoguePlaying: true),
      );
      _playNextLine();
    }
  }

  void toggleUI() {
    _updateState(_state.copyWith(isUIVisible: !_state.isUIVisible));
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (canSendMessage) {
          onUpdate();
        } else {
          skipOrNext();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        skipOrNext();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        goToPreviousMessage();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        goToNextMessage();
      } else if (event.logicalKey == LogicalKeyboardKey.keyV &&
          HardwareKeyboard.instance.isControlPressed) {
        toggleUI();
      }

      if (event.logicalKey == LogicalKeyboardKey.keyH &&
          HardwareKeyboard.instance.isControlPressed) {
        showHistoryPopup();
      }
    }
  }

  Future<void> initSession() async {
    final universeId = dotenv.env[GameConstants.UNIVERSE_ID];
    final eventId = dotenv.env[GameConstants.EVENT_ID];

    if (universeId == null || eventId == null) {
      throw SessionException('환경변수가 누락되었습니다.');
    }

    try {
      final sessionId = await _apiService.startSession(
        universeId,
        GameConstants.PLAYER_ID,
        eventId,
        npcs.map((npc) => npc.id).toList(),
      );
      _updateState(_state.copyWith(sessionId: sessionId));
      await getInitialEvent(eventId);
    } on SessionException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(SessionException('세션 초기화 중 오류가 발생했습니다.', originalError: e));
    }
  }

  Future<void> getInitialEvent(String eventId) async {
    try {
      final steps = await _apiService.getInitialEvent(eventId);

      for (var stepData in steps) {
        String text = stepData.message;
        String speakerType = stepData.speakerType;
        String character = "";

        if (speakerType == 'PLAYER') {
          character = GameConstants.PLAYER_CHARACTER;
        } else if (speakerType == 'NPC') {
          character = npcs.firstWhere((c) => c.id == stepData.speakerId).name;
        } else if (speakerType == 'SYSTEM') {
          character = GameConstants.SYSTEM_CHARACTER;
        }

        addDialogue(character, text, '');
      }
      _playNextLine();
    } on NetworkException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(
        NetworkException('초기 이벤트 로딩 중 오류가 발생했습니다.', originalError: e),
      );
    }
  }

  void addDialogue(String character, String text, String face) {
    final currentMessage = text.replaceAll("player", playerName);
    final newDialogues = List<DialogueLine>.from(_state.dialogues)..add(
      DialogueLine(
        character: character,
        text: currentMessage,
        face: face.isEmpty ? '001' : face,
      ),
    );
    _updateState(_state.copyWith(dialogues: newDialogues));
  }

  void addErrorDialogueLine(String error) {
    addDialogue(
      GameConstants.SYSTEM_CHARACTER,
      '${GameConstants.ERROR_PREFIX}$error',
      '',
    );
  }

  Future<void> playTTS(String character, String text) async {
    if (!GameConstants.USING_TTS) return;

    try {
      final bytes = await _ttsService.generateSpeech(character, text);
      await player.setAudioSource(MyCustomSource(bytes));
      await player.play();
    } on tts.TTSException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(tts.TTSException('TTS 처리 중 오류가 발생했습니다.', originalError: e));
    }
  }

  void _handleError(GameException error) {
    print('Error: ${error.toString()}');
    if (error.originalError != null) {
      print('Original error: ${error.originalError}');
    }
    addErrorDialogueLine(error.message);
    _playNextLine();
  }
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}
