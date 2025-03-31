import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:loveloveraid/model/dialogue_line.dart';
import 'package:http/http.dart' as http;

class GameScreenController {
  final Function onUpdate;
  GameScreenController({required this.onUpdate});

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

  Future<void> sendPlayerMessage(String message) async {
    if (!canSendMessage) return;

    _isDialoguePlaying = true;
    onUpdate();

    // _dialogueQueue.add(DialogueLine(character: '나', text: message));

    if (kReleaseMode) {
      final response = await http.post(
        Uri.parse('https://api.liveloveraid.dev/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _dialogueQueue.addAll(
          data.map((e) => DialogueLine.fromJson(e)).toList(),
        );
      } else {
        _dialogueQueue.add(
          DialogueLine(character: '시스템', text: '서버 오류가 발생했습니다.'),
        );
      }
    } else {
      _dialogueQueue.add(DialogueLine(character: '샘플', text: '샘플입니다.'));
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
}
