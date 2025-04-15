class Npc {
  String id;
  String universeId;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  String bio;
  String gender;
  String race;
  String species;

  Npc({
    required this.id,
    required this.universeId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.bio,
    required this.gender,
    required this.race,
    required this.species,
  });

  factory Npc.fromJson(Map<String, dynamic> json) {
    return Npc(
      id: json['id'],
      universeId: json['universeId'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      bio: json['bio'],
      gender: json['gender'],
      race: json['race'],
      species: json['species'],
    );
  }
}
