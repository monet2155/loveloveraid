import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loveloveraid/constants/game_constants.dart';
import 'package:loveloveraid/exceptions/game_exception.dart';

class TTSException extends GameException {
  TTSException(String message, {String? details, dynamic originalError})
    : super(message, details: details, originalError: originalError);
}

class TTSService {
  final String baseUrl;
  final String apiKey;

  TTSService()
    : baseUrl = dotenv.env[GameConstants.SUPERTONE_API_URL] ?? '',
      apiKey = dotenv.env[GameConstants.SUPERTONE_API_KEY] ?? '';

  Future<List<int>> generateSpeech(String character, String text) async {
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      throw TTSException('TTS API 설정이 누락되었습니다.');
    }

    final voice = GameConstants.TTS_VOICE_IDS.firstWhere(
      (v) => v['name'] == character,
      orElse: () => throw TTSException('해당 캐릭터의 음성을 찾을 수 없습니다: $character'),
    );

    final response = await http.post(
      Uri.parse("$baseUrl/text-to-speech/${voice['id']}"),
      headers: {'x-sup-api-key': apiKey, ...GameConstants.JSON_HEADERS},
      body: jsonEncode({
        "language": GameConstants.TTS_LANGUAGE,
        "text": text,
        "model": GameConstants.TTS_MODEL,
        "voice_settings": GameConstants.TTS_VOICE_SETTINGS,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw TTSException(
        'TTS 요청에 실패했습니다.',
        details: 'Status code: ${response.statusCode}',
        originalError: response.body,
      );
    }
  }
}
