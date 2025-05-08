class GameConstants {
  // API 관련 상수
  static const String API_BASE_URL = 'API_URL';
  static const String API_PROVIDER = 'LLM_PROVIDER';
  static const String UNIVERSE_ID = 'UNIVERSE_ID';
  static const String EVENT_ID = 'EVENT_ID';
  static const String SUPERTONE_API_URL = 'SUPERTONE_API_URL';
  static const String SUPERTONE_API_KEY = 'SUPERTONE_API_KEY';

  // TTS 관련 상수
  static const bool USING_TTS = false;
  static const String TTS_LANGUAGE = 'ko';
  static const String TTS_MODEL = 'turbo';
  static const Map<String, dynamic> TTS_VOICE_SETTINGS = {
    "pitch_shift": 0,
    "pitch_variance": 1,
    "speed": 1,
  };

  // TTS 음성 ID
  static const List<Map<String, String>> TTS_VOICE_IDS = [
    {"name": "이서아", "id": "hkzbhWknLqbwz8Jw8RYVyV"},
    {"name": "강지연", "id": "c1fEJ6TaHYha7ACMr7Cj3r"},
    {"name": "윤하린", "id": "gdvdX3oHN69chfYqyro9UE"},
  ];

  // 게임 관련 상수
  static const String PLAYER_ID = '1e4f9c78-8b6a-4a29-9c64-9e2d3cb3b6e1';
  static const String SYSTEM_CHARACTER = '시스템';
  static const String PLAYER_CHARACTER = '플레이어';
  static const String END_DIALOGUE_MARKER = '**!!END!!**';
  static const String ERROR_PREFIX = '오류 발생: ';

  // 타이밍 관련 상수
  static const int TEXT_SPEED_MS = 40;
  static const int AUTO_NEXT_DELAY_MS = 300;

  // HTTP 관련 상수
  static const Map<String, String> JSON_HEADERS = {
    'Content-Type': 'application/json',
  };
}
