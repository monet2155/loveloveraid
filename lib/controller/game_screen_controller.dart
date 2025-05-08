import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:loveloveraid/model/dialogue_line.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loveloveraid/model/npc.dart';
import 'package:loveloveraid/model/step.dart';
import 'package:just_audio/just_audio.dart';

const USING_TTS = false;

class GameScreenState {
  final List<DialogueLine> dialogueQueue;
  final bool isDialoguePlaying;
  final bool isWaitingForTap;
  final String visibleText;
  final DialogueLine? currentLine;
  final bool isLoading;
  final String? sessionId;
  final Set<String> appearedCharacters;
  final Set<String> animatedCharacters;
  final List<DialogueLine> dialogueHistory;
  final int currentHistoryIndex;
  final bool isInHistoryView;

  GameScreenState({
    this.dialogueQueue = const [],
    this.isDialoguePlaying = false,
    this.isWaitingForTap = false,
    this.visibleText = '',
    this.currentLine,
    this.isLoading = false,
    this.sessionId,
    this.appearedCharacters = const {},
    this.animatedCharacters = const {},
    this.dialogueHistory = const [],
    this.currentHistoryIndex = -1,
    this.isInHistoryView = false,
  });

  GameScreenState copyWith({
    List<DialogueLine>? dialogueQueue,
    bool? isDialoguePlaying,
    bool? isWaitingForTap,
    String? visibleText,
    DialogueLine? currentLine,
    bool? isLoading,
    String? sessionId,
    Set<String>? appearedCharacters,
    Set<String>? animatedCharacters,
    List<DialogueLine>? dialogueHistory,
    int? currentHistoryIndex,
    bool? isInHistoryView,
  }) {
    return GameScreenState(
      dialogueQueue: dialogueQueue ?? this.dialogueQueue,
      isDialoguePlaying: isDialoguePlaying ?? this.isDialoguePlaying,
      isWaitingForTap: isWaitingForTap ?? this.isWaitingForTap,
      visibleText: visibleText ?? this.visibleText,
      currentLine: currentLine ?? this.currentLine,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      appearedCharacters: appearedCharacters ?? this.appearedCharacters,
      animatedCharacters: animatedCharacters ?? this.animatedCharacters,
      dialogueHistory: dialogueHistory ?? this.dialogueHistory,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      isInHistoryView: isInHistoryView ?? this.isInHistoryView,
    );
  }
}

class GameScreenController {
  final String playerName;
  final Function onUpdate;
  final Function onEndChapter;
  final List<Npc> npcs;

  GameScreenState _state = GameScreenState();
  Timer? _textTimer;
  final player = AudioPlayer();

  static const Duration textSpeed = Duration(milliseconds: 40);

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

  GameScreenController({
    required this.playerName,
    required this.onUpdate,
    required this.onEndChapter,
    required this.npcs,
  });

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

    final apiUrl = dotenv.env['API_URL'];
    final provider = dotenv.env['LLM_PROVIDER'];

    try {
      final response = await http.post(
        Uri.parse(
          '$apiUrl/npc/${_state.sessionId}/dialogue${provider != null ? "?provider=$provider" : ""}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'player_input': message}),
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic> data = decodedBody;
        if (data['dialogue'] == null) {
          addErrorDialogueLine('서버에서 대화 내용을 가져오지 못했습니다.');
          return;
        }

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

        List<String> dialogueList = data['dialogue'].split("\n\n");
        for (var text in dialogueList) {
          if (text == "**!!END!!**") {
            addDialogueQueue('시스템', '대화가 종료되었습니다.');
            break;
          }

          String character = text.split(':')[0];
          String message = text.split(':')[1].trim();

          if (message.contains('\n')) {
            List<String> splitMessage = message.split('\n');
            for (var i = 0; i < splitMessage.length; i++) {
              addDialogueQueue(character, splitMessage[i]);
            }
          } else {
            addDialogueQueue(character, message);
          }
        }
      } else {
        print(utf8.decode(response.bodyBytes));
        addErrorDialogueLine('서버와의 통신 중 오류가 발생했습니다.');
      }
    } catch (e) {
      print('서버와의 통신 중 오류 발생: $e');
      addErrorDialogueLine('서버와의 통신 중 오류가 발생했습니다.');
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }

    _playNextLine();
  }

  void _playNextLine() {
    print("play next");
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
      if (kDebugMode && USING_TTS) {
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

  void handleKeyEvent(KeyEvent event) {
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
    }
  }

  Future<void> initSession() async {
    final universeId = dotenv.env['UNIVERSE_ID'];
    final apiUrl = dotenv.env['API_URL'];
    final eventId = dotenv.env['EVENT_ID'];

    if (universeId == null || apiUrl == null || eventId == null) {
      addDialogueQueue('시스템', '환경변수가 누락되었습니다.');
      _playNextLine();
      return;
    }

    final playerId =
        '1e4f9c78-8b6a-4a29-9c64-9e2d3cb3b6e1'; // 이후 실제 사용자 ID 연동 가능

    try {
      final res = await http.post(
        Uri.parse('$apiUrl/npc/$universeId/start-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'player_id': playerId,
          'event_id': eventId,
          "npcs": npcs.map((npc) => npc.id).toList(),
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _updateState(_state.copyWith(sessionId: data['session_id']));
        await getInitialEvent(eventId);
      } else {
        print('세션 시작 실패: ${res.statusCode}');
        print('응답 본문: ${utf8.decode(res.bodyBytes)}');
        addErrorDialogueLine('세션 시작에 실패했습니다.');
        _playNextLine();
      }
    } catch (e) {
      print('세션 초기화 오류: $e');
      addErrorDialogueLine('세션 초기화 중 오류가 발생했습니다.');
      _playNextLine();
    }
  }

  Future<void> getInitialEvent(String eventId) async {
    final apiUrl = dotenv.env['API_URL'];
    try {
      final res = await http.get(
        Uri.parse('$apiUrl/event/$eventId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(res.bodyBytes));
        final Map<String, dynamic> data = decodedBody;
        List steps = data["steps"];

        for (var step in steps) {
          Step stepData = Step.fromJson(step);
          String text = stepData.message;
          String speakerType = stepData.speakerType;
          String character = "";

          if (speakerType == 'PLAYER') {
            character = '플레이어';
          } else if (speakerType == 'NPC') {
            character = npcs.firstWhere((c) => c.id == stepData.speakerId).name;
          } else if (speakerType == 'SYSTEM') {
            character = '시스템';
          }

          addDialogueQueue(character, text);
        }
        _playNextLine(); // 모든 스텝을 큐에 추가한 후 한 번만 호출
      } else {
        print('세션 시작 실패: ${res.statusCode}');
        print('응답 본문: ${res.body}');
        addErrorDialogueLine('세션 시작에 실패했습니다.');
        _playNextLine();
      }
    } catch (e) {
      print('초기 이벤트 로딩 오류: $e');
      addErrorDialogueLine('초기 이벤트 로딩 중 오류가 발생했습니다.');
      _playNextLine();
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
    addDialogueQueue('시스템', '오류 발생: $error');
  }

  void playTTS(String character, String text) async {
    List<Map> voiceId = [
      {"name": "이서아", "id": "hkzbhWknLqbwz8Jw8RYVyV"},
      {"name": "강지연", "id": "c1fEJ6TaHYha7ACMr7Cj3r"},
      {"name": "윤하린", "id": "gdvdX3oHN69chfYqyro9UE"},
    ];

    final apiUrl = dotenv.env['SUPERTONE_API_URL'];
    final res = await http.post(
      Uri.parse(
        "$apiUrl/text-to-speech/${voiceId.firstWhere((v) => v['name'] == character)['id']}",
      ),
      headers: {
        'x-sup-api-key': dotenv.env['SUPERTONE_API_KEY']!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "language": "ko",
        "text": text,
        "model": "turbo",
        "voice_settings": {"pitch_shift": 0, "pitch_variance": 1, "speed": 1},
      }),
    );

    if (res.statusCode == 200) {
      try {
        final bytes = res.bodyBytes;

        await player.setAudioSource(MyCustomSource(bytes));
        await player.play();
      } catch (e) {
        print("오디오 재생 실패: $e");
      }
    } else {
      print('TTS 요청 실패: ${res.statusCode}');
      print('응답 본문: ${res.body}');
    }
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
