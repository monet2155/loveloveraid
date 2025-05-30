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
  String get visibleText => _state.visibleText;
  bool get canSendMessage =>
      !_state.isDialoguePlaying &&
      _state.dialogueQueue.isEmpty &&
      !_state.isWaitingForTap &&
      !_state.isInHistoryView &&
      !_state.isLoading;

  bool get isLoading => _state.isLoading;
  Set<String> get appearedCharacters => _state.appearedCharacters;
  Set<String> get newlyAppearedCharacters =>
      _state.appearedCharacters.difference(_state.animatedCharacters);
  bool get canGoToPreviousMessage => _state.currentHistoryIndex > 0;
  bool get canGoToNextMessage =>
      (_state.isInHistoryView &&
          (_state.currentHistoryIndex < _state.dialogueHistory.length - 1));
  bool get isInHistoryView => _state.isInHistoryView;
  bool get isUIVisible => _state.isUIVisible;

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

      // 대화 히스토리에 플레이어 메시지 추가
      final newHistory = [
        ..._state.dialogueHistory,
        DialogueLine(character: playerName, text: message),
      ];

      _updateState(
        _state.copyWith(
          dialogueHistory: newHistory,
          currentHistoryIndex: newHistory.length - 1,
        ),
      );

      for (var response in dialogueResponse.responses) {
        addDialogueQueue(response.npc, response.dialogue);
      }

      if (dialogueResponse.state == "ended") {
        addDialogueQueue(GameConstants.SYSTEM_CHARACTER, '대화가 종료되었습니다.');
      }
    } catch (e) {
      _handleError(NetworkException('서버와의 통신 중 오류가 발생했습니다.', originalError: e));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }

    _playNextLine();
  }

  void _playNextLine() {
    if (_state.dialogueQueue.isEmpty) {
      _updateState(
        _state.copyWith(isDialoguePlaying: false, isWaitingForTap: false),
      );
      return;
    }

    final currentLine = _state.dialogueQueue.first;
    final newQueue = List<DialogueLine>.from(_state.dialogueQueue)..removeAt(0);
    final fullText = currentLine.text;

    if (fullText == "대화가 종료되었습니다.") {
      onEndChapter();
      return;
    }

    // 대화 히스토리에 현재 라인 추가
    final newHistory = [..._state.dialogueHistory, currentLine];
    _updateState(
      _state.copyWith(
        dialogueQueue: newQueue,
        currentLine: currentLine,
        visibleText: '',
        dialogueHistory: newHistory,
        currentHistoryIndex: newHistory.length - 1,
      ),
    );

    if (currentCharacter != '시스템') {
      _updateState(
        _state.copyWith(
          appearedCharacters: {..._state.appearedCharacters, currentCharacter},
        ),
      );
      if (kDebugMode && GameConstants.USING_TTS) {
        if (player.playing) {
          player.stop();
        }
        playTTS(currentCharacter, fullText);
      }
    }

    int charIndex = 0;
    _textTimer?.cancel();
    _textTimer = Timer.periodic(textSpeed, (timer) {
      _updateState(
        _state.copyWith(visibleText: _state.visibleText + fullText[charIndex]),
      );
      charIndex++;
      if (charIndex >= fullText.length) {
        timer.cancel();
        _updateState(
          _state.copyWith(isWaitingForTap: true, isDialoguePlaying: false),
        );

        if (_state.dialogueQueue.isEmpty) {
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
    if (!canGoToPreviousMessage) return;

    _updateState(
      _state.copyWith(
        isInHistoryView: true,
        currentHistoryIndex: _state.currentHistoryIndex - 1,
      ),
    );
    _showHistoryMessage();
  }

  void goToNextMessage() {
    if (canGoToNextMessage) {
      _updateState(
        _state.copyWith(currentHistoryIndex: _state.currentHistoryIndex + 1),
      );
      _showHistoryMessage();

      if (_state.currentHistoryIndex >= _state.dialogueHistory.length - 1) {
        _updateState(_state.copyWith(isInHistoryView: false));
        skipOrNext();
      }
    } else if (_state.isInHistoryView) {
      _updateState(_state.copyWith(isInHistoryView: false));
      skipOrNext();
    }
  }

  void _showHistoryMessage() {
    if (_state.currentHistoryIndex < 0 ||
        _state.currentHistoryIndex >= _state.dialogueHistory.length) {
      return;
    }

    _textTimer?.cancel();
    final historyLine = _state.dialogueHistory[_state.currentHistoryIndex];
    _updateState(
      _state.copyWith(
        currentLine: historyLine,
        visibleText: historyLine.text,
        isWaitingForTap: false,
        isDialoguePlaying: false,
      ),
    );
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

        addDialogueQueue(character, text);
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

  void addDialogueQueue(String character, String text) {
    String currentMessage = text.replaceAll("player", playerName);
    final newQueue = [
      ..._state.dialogueQueue,
      DialogueLine(character: character, text: currentMessage),
    ];
    _updateState(_state.copyWith(dialogueQueue: newQueue));
  }

  void addErrorDialogueLine(String error) {
    addDialogueQueue(
      GameConstants.SYSTEM_CHARACTER,
      '${GameConstants.ERROR_PREFIX}$error',
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
