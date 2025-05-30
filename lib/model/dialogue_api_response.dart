import 'dialogue_response.dart';

class DialogueApiResponse {
  final List<DialogueResponse> responses;
  final String state;

  DialogueApiResponse({required this.responses, required this.state});

  factory DialogueApiResponse.fromJson(Map<String, dynamic> json) {
    return DialogueApiResponse(
      responses:
          (json['responses'] as List)
              .map((response) => DialogueResponse.fromJson(response))
              .toList(),
      state: json['state'],
    );
  }
}
