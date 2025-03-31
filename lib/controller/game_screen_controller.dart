import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:loveloveraid/model/dialogue_line.dart';

class GameScreenController {
  final Function onUpdate;
  GameScreenController({required this.onUpdate});

  final List<DialogueLine> _dialogue = [];
  int _currentIndex = 0;
  String _visibleText = '';
  Timer? _textTimer;

  static const Duration textSpeed = Duration(milliseconds: 40);

  String get currentCharacter =>
      _dialogue.isNotEmpty ? _dialogue[_currentIndex].character : '';
  String get visibleText => _visibleText;

  Future<void> loadDialogue() async {
    final String jsonString = await rootBundle.loadString(
      'assets/dialogue.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    _dialogue.addAll(jsonData.map((e) => DialogueLine.fromJson(e)));
    _showNextLine();
  }

  void _showNextLine() {
    if (_currentIndex >= _dialogue.length) return;
    _visibleText = '';
    final fullText = _dialogue[_currentIndex].text;
    int charIndex = 0;
    _textTimer?.cancel();
    _textTimer = Timer.periodic(textSpeed, (timer) {
      _visibleText += fullText[charIndex];
      onUpdate();
      charIndex++;
      if (charIndex >= fullText.length) {
        timer.cancel();
      }
    });
  }

  void onTap() {
    if (_textTimer?.isActive ?? false) {
      _textTimer?.cancel();
      _visibleText = _dialogue[_currentIndex].text;
      onUpdate();
    } else {
      if (_currentIndex < _dialogue.length - 1) {
        _currentIndex++;
        _showNextLine();
      }
    }
  }
}
