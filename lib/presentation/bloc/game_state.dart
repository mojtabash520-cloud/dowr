part of 'game_bloc.dart';

enum GameStatus { initial, playing, teamEliminated, turnFinished, gameFinished }

class Team extends Equatable {
  final String id;
  final String name;
  final int score;
  final int remainingTime;
  final int totalTime;
  final bool isEliminated;
  final Color color;

  const Team({
    required this.id,
    required this.name,
    required this.color,
    this.score = 0,
    this.remainingTime = 0,
    this.totalTime = 0,
    this.isEliminated = false,
  });

  Team copyWith({int? score, int? remainingTime, bool? isEliminated}) {
    return Team(
      id: id,
      name: name,
      color: color,
      totalTime: totalTime,
      score: score ?? this.score,
      remainingTime: remainingTime ?? this.remainingTime,
      isEliminated: isEliminated ?? this.isEliminated,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, score, remainingTime, totalTime, isEliminated, color];
}

class GameState extends Equatable {
  final GameStatus status;
  final Word? currentWord;
  final List<Team> teams;
  final int currentTeamIndex;
  final int currentRound;
  final int roundRemainingTime;
  final List<Team> ranking;
  final Team? justEliminatedTeam;
  final Team? winnerTeam;

  const GameState({
    this.status = GameStatus.initial,
    this.currentWord,
    this.teams = const [],
    this.currentTeamIndex = 0,
    this.currentRound = 1,
    this.roundRemainingTime = 0,
    this.ranking = const [],
    this.justEliminatedTeam,
    this.winnerTeam,
  });

  GameState copyWith({
    GameStatus? status,
    Word? currentWord,
    List<Team>? teams,
    int? currentTeamIndex,
    int? currentRound,
    int? roundRemainingTime,
    List<Team>? ranking,
    Team? justEliminatedTeam,
    Team? winnerTeam,
  }) {
    return GameState(
      status: status ?? this.status,
      currentWord: currentWord ?? this.currentWord,
      teams: teams ?? this.teams,
      currentTeamIndex: currentTeamIndex ?? this.currentTeamIndex,
      currentRound: currentRound ?? this.currentRound,
      roundRemainingTime: roundRemainingTime ?? this.roundRemainingTime,
      ranking: ranking ?? this.ranking,
      justEliminatedTeam: justEliminatedTeam ?? this.justEliminatedTeam,
      winnerTeam: winnerTeam ?? this.winnerTeam,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentWord,
        teams,
        currentTeamIndex,
        currentRound,
        roundRemainingTime,
        ranking,
        justEliminatedTeam,
        winnerTeam
      ];
}
