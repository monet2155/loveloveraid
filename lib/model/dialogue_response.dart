class DialogueResponse {
  final String npc;
  final String dialogue;

  DialogueResponse({required this.npc, required this.dialogue});

  factory DialogueResponse.fromJson(Map<String, dynamic> json) {
    return DialogueResponse(npc: json['npc'], dialogue: json['dialogue']);
  }
}
