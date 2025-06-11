class Player {
  String id;
  String name;
  Map<String, int> affectionScore = {};

  Player({this.id = '', this.name = ''});

  void addAffectionScore(String npcId, int score) {
    affectionScore[npcId] = (affectionScore[npcId] ?? 0) + score;
  }
}
