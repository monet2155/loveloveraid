const Map<String, String> faceMap = {
  '기본': '001',
  '분노': '002',
  '설렘': '003',
  '슬픔': '004',
  '웃음': '005',
};

class DialogueLine {
  final String character;
  final String text;
  final String face;

  DialogueLine({
    required this.character,
    required this.text,
    required this.face,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      character: json['npc'] as String,
      text: json['dialogue'] as String,
      face: faceMap[json['face'] as String] ?? '001',
    );
  }
}
