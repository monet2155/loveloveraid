class CharacterResourceDto {
  final String id;
  final String name;

  CharacterResourceDto({required this.id, required this.name});

  factory CharacterResourceDto.fromJson(Map<String, dynamic> json) {
    return CharacterResourceDto(id: json['id'], name: json['name']);
  }
}
