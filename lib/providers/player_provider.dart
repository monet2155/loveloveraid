import 'package:flutter/foundation.dart';
import '../model/player.dart';

class PlayerProvider with ChangeNotifier {
  Player _player = Player();

  Player get player => _player;

  // 플레이어 ID 설정
  void setId(String id) {
    _player.id = id;
    notifyListeners();
  }

  // 플레이어 이름 설정
  void setName(String name) {
    _player.name = name;
    notifyListeners();
  }

  // 플레이어 데이터 초기화
  void resetPlayer() {
    _player = Player();
    notifyListeners();
  }
}
