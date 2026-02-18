enum GameMode { survival, rounds }

class GameSettings {
  final GameMode mode;
  final int numberOfTeams;
  final int timePerTeam; // برای حالت بقا
  final int turnDuration; // برای حالت امتیازی
  final int roundsCount; // تعداد دور
  final List<String>? teamNames;

  const GameSettings({
    required this.mode,
    this.numberOfTeams = 2,
    this.timePerTeam = 180,
    this.turnDuration = 60,
    this.roundsCount = 3,
    this.teamNames,
  });
}
