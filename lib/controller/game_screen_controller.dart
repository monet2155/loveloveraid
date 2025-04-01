import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:loveloveraid/model/dialogue_line.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GameScreenController {
  final Function onUpdate;

  final List<DialogueLine> _dialogueQueue = [];
  bool _isDialoguePlaying = false;
  bool _isWaitingForTap = false;
  String _visibleText = '';
  Timer? _textTimer;
  DialogueLine? _currentLine;

  static const Duration textSpeed = Duration(milliseconds: 40);

  String get currentCharacter => _currentLine?.character ?? '';
  String get visibleText => _visibleText;
  bool get canSendMessage => !_isDialoguePlaying && !_isWaitingForTap;

  String? _sessionId;

  GameScreenController({required this.onUpdate}) {
    initSession(); // ✅ 세션 자동 시작
  }

  Future<void> sendPlayerMessage(String message) async {
    if (!canSendMessage || _sessionId == null) return;

    _isDialoguePlaying = true;
    onUpdate();

    final apiUrl = dotenv.env['API_URL'];

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/npc/$_sessionId/dialogue'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'player_input': message}),
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        print('서버 응답: ${decodedBody}');
        final Map<String, dynamic> data = decodedBody;
        if (data['dialogue'] == null) {
          _dialogueQueue.add(
            DialogueLine(character: '시스템', text: '대화 중 오류가 발생했습니다.'),
          );
          return;
        }

        String character = data['dialogue'].split(':')[0];
        String text = data['dialogue'].split(':')[1].trim();

        if (character == '시스템') {
          _dialogueQueue.add(DialogueLine(character: character, text: text));
        } else {
          _dialogueQueue.add(DialogueLine(character: character, text: text));
        }
      } else {
        _dialogueQueue.add(
          DialogueLine(character: '시스템', text: '대화 중 오류가 발생했습니다.'),
        );
      }
    } catch (e) {
      print('서버와의 통신 중 오류 발생: $e');

      _dialogueQueue.add(
        DialogueLine(character: '시스템', text: '서버에 연결할 수 없습니다.'),
      );
    }

    _playNextLine();
  }

  void _playNextLine() {
    if (_dialogueQueue.isEmpty) {
      _isDialoguePlaying = false;
      _isWaitingForTap = false;
      onUpdate();
      return;
    }

    _currentLine = _dialogueQueue.removeAt(0);
    _visibleText = '';
    final fullText = _currentLine!.text;
    int charIndex = 0;

    _textTimer?.cancel();
    _textTimer = Timer.periodic(textSpeed, (timer) {
      _visibleText += fullText[charIndex];
      onUpdate();
      charIndex++;
      if (charIndex >= fullText.length) {
        timer.cancel();
        _isWaitingForTap = true;
        _isDialoguePlaying = false;
        onUpdate();
      }
    });
  }

  void skipOrNext() {
    if (_textTimer?.isActive ?? false) {
      _textTimer?.cancel();
      _visibleText = _currentLine?.text ?? '';
      onUpdate();
      _isWaitingForTap = true;
      _isDialoguePlaying = false;
    } else if (_isWaitingForTap) {
      _isWaitingForTap = false;
      _isDialoguePlaying = true;
      onUpdate();
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
    }
  }

  Future<void> initSession() async {
    final universeId = dotenv.env['UNIVERSE_ID'];
    final npcId = dotenv.env['NPC_ID'];
    final apiUrl = dotenv.env['API_URL'];

    if (universeId == null || npcId == null || apiUrl == null) {
      _dialogueQueue.add(
        DialogueLine(character: '시스템', text: '환경변수가 누락되었습니다.'),
      );
      _playNextLine();
      return;
    }

    final playerId =
        '1e4f9c78-8b6a-4a29-9c64-9e2d3cb3b6e1'; // 이후 실제 사용자 ID 연동 가능

    final res = await http.post(
      Uri.parse('$apiUrl/npc/$universeId/$npcId/start-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'player_id': playerId}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _sessionId = data['session_id'];
      // _dialogueQueue.add(DialogueLine(character: '시스템', text: '세션이 시작되었습니다.'));
    } else {
      print('세션 시작 실패: ${res.statusCode}');
      print('응답 본문: ${res.body}');
      _dialogueQueue.add(
        DialogueLine(character: '시스템', text: '세션 시작에 실패했습니다.'),
      );
    }

    _playNextLine();
  }
}
