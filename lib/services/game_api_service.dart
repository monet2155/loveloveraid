import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loveloveraid/constants/game_constants.dart';
import 'package:loveloveraid/exceptions/game_exception.dart';
import 'package:loveloveraid/model/step.dart';

class GameApiService {
  final String baseUrl;
  final String? provider;

  GameApiService()
    : baseUrl = dotenv.env[GameConstants.API_BASE_URL] ?? '',
      provider = dotenv.env[GameConstants.API_PROVIDER];

  Future<String> startSession(
    String universeId,
    String playerId,
    String eventId,
    List<String> npcIds,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/npc/$universeId/start-session'),
      headers: GameConstants.JSON_HEADERS,
      body: jsonEncode({
        'player_id': playerId,
        'event_id': eventId,
        "npcs": npcIds,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['session_id'];
    } else {
      throw SessionException(
        '세션 시작에 실패했습니다.',
        details: 'Status code: ${response.statusCode}',
        originalError: utf8.decode(response.bodyBytes),
      );
    }
  }

  Future<List<Step>> getInitialEvent(String eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/event/$eventId'),
      headers: GameConstants.JSON_HEADERS,
    );

    if (response.statusCode == 200) {
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      final Map<String, dynamic> data = decodedBody;
      List steps = data["steps"];
      return steps.map((step) => Step.fromJson(step)).toList();
    } else {
      throw NetworkException(
        '초기 이벤트 로딩에 실패했습니다.',
        details: 'Status code: ${response.statusCode}',
        originalError: response.body,
      );
    }
  }

  Future<List<String>> sendDialogue(String sessionId, String message) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/npc/$sessionId/dialogue${provider != null ? "?provider=$provider" : ""}',
      ),
      headers: GameConstants.JSON_HEADERS,
      body: jsonEncode({'player_input': message}),
    );

    if (response.statusCode == 200) {
      final decodedBody = json.decode(utf8.decode(response.bodyBytes));
      final Map<String, dynamic> data = decodedBody;
      if (data['dialogue'] == null) {
        throw NetworkException('서버에서 대화 내용을 가져오지 못했습니다.');
      }

      return data['dialogue'].split("\n\n");
    } else {
      throw NetworkException(
        '서버와의 통신 중 오류가 발생했습니다.',
        details: 'Status code: ${response.statusCode}',
        originalError: utf8.decode(response.bodyBytes),
      );
    }
  }
}
