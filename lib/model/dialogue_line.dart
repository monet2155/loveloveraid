class DialogueLine {
  final String character;
  final String text;

  DialogueLine({required this.character, required this.text});

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      character: json['npc'] as String,
      text: json['dialogue'] as String,
    );
  }
}
