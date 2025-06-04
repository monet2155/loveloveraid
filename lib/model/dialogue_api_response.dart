import 'dialogue_line.dart';

class DialogueApiResponse {
  final List<DialogueLine> responses;
  final String state;

  DialogueApiResponse({required this.responses, required this.state});

  factory DialogueApiResponse.fromJson(Map<String, dynamic> json) {
    return DialogueApiResponse(
      responses:
          (json['responses'] as List)
              .map((response) => DialogueLine.fromJson(response))
              .toList(),
      state: json['state'],
    );
  }
}
