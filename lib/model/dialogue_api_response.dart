import 'dialogue_line.dart';

class DialogueApiResponse {
  final List<DialogueLine> responses;
  final String state;
  final Map<String, int> affectionScore;

  DialogueApiResponse({
    required this.responses,
    required this.state,
    required this.affectionScore,
  });

  factory DialogueApiResponse.fromJson(Map<String, dynamic> json) {
    return DialogueApiResponse(
      responses:
          (json['responses'] as List)
              .map((response) => DialogueLine.fromJson(response))
              .toList(),
      state: json['state'],
      affectionScore: Map<String, int>.from(json['affection_score']),
    );
  }
}
