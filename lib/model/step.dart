class Step {
  String id;
  int order;
  String message;
  String speakerType;
  String? speakerId; // Player ID 또는 NPC ID 저장 (system은 null)

  Step({
    required this.id,
    required this.order,
    required this.message,
    required this.speakerType,
    this.speakerId,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      id: json['id'],
      order: json['order'],
      message: json['message'],
      speakerType: json['speakerType'],
      speakerId: json['speakerId'],
    );
  }
}
