import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/game_settings.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final List<Word> _allWords;
  final GameSettings settings;
  List<Word> _roundWordsPool = [];
  StreamSubscription<int>? _timerSubscription;
  final Random _random = Random();

  final List<Color> _teamColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.green,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent
  ];

  GameBloc({required List<Word> words, required this.settings})
      : _allWords = words,
        super(const GameState()) {
    final initialTeams = List.generate(settings.numberOfTeams, (index) {
      String teamName =
          (settings.teamNames != null && index < settings.teamNames!.length)
              ? settings.teamNames![index]
              : 'تیم ${index + 1}';

      int initialTime =
          settings.mode == GameMode.survival ? settings.timePerTeam : 0;

      return Team(
        id: '$index',
        name: teamName,
        score: 0,
        remainingTime: initialTime,
        totalTime: initialTime,
        color: _teamColors[index % _teamColors.length],
      );
    });

    emit(state.copyWith(
      teams: initialTeams,
      roundRemainingTime:
          settings.mode == GameMode.rounds ? settings.turnDuration : 0,
      currentRound: 1,
    ));

    on<StartGame>(_onStartGame);
    on<TickTimer>(_onTickTimer);
    on<UserAction>(_onUserAction);
    on<DismissElimination>(_onNextTurnOrResume);
    on<ResumeTurn>(_onResumeTurn);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    _roundWordsPool = List.from(_allWords);
    _nextWord(emit);
    emit(state.copyWith(status: GameStatus.playing));
    
    _startTicker();
    // ✅ تایمر در ابتدای بازی متوقف می‌ماند تا دکمه "آماده‌ایم" زده شود
    _timerSubscription?.pause(); 
  }

  void _onResumeTurn(ResumeTurn event, Emitter<GameState> emit) {
    _timerSubscription?.resume();
  }

  void _onTickTimer(TickTimer event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;

    if (settings.mode == GameMode.survival) {
      List<Team> updatedTeams = List.from(state.teams);
      Team currentTeam = updatedTeams[state.currentTeamIndex];
      int newTime = currentTeam.remainingTime - 1;

      if (newTime <= 0) {
        updatedTeams[state.currentTeamIndex] =
            currentTeam.copyWith(remainingTime: 0, isEliminated: true);
        List<Team> newRanking = List.from(state.ranking)
          ..add(updatedTeams[state.currentTeamIndex]);
        _timerSubscription?.pause();
        
        _nextWord(emit); // تعویض کلمه سوخته برای تیم بعدی
        
        emit(state.copyWith(
            teams: updatedTeams,
            status: GameStatus.teamEliminated,
            justEliminatedTeam: updatedTeams[state.currentTeamIndex],
            ranking: newRanking));
      } else {
        updatedTeams[state.currentTeamIndex] =
            currentTeam.copyWith(remainingTime: newTime);
        emit(state.copyWith(teams: updatedTeams));
      }
    } else {
      int newTime = state.roundRemainingTime - 1;
      if (newTime <= 0) {
        _timerSubscription?.pause();
        _nextWord(emit); // تعویض کلمه سوخته
        emit(state.copyWith(
            status: GameStatus.turnFinished, roundRemainingTime: 0));
      } else {
        emit(state.copyWith(roundRemainingTime: newTime));
      }
    }
  }

  void _onNextTurnOrResume(DismissElimination event, Emitter<GameState> emit) {
    if (settings.mode == GameMode.survival) {
      int activeTeamsCount = state.teams.where((t) => !t.isEliminated).length;
      if (activeTeamsCount <= 1) {
        Team winner = state.teams.firstWhere((t) => !t.isEliminated,
            orElse: () => state.teams.first);
        List<Team> finalRanking = List.from(state.ranking)..add(winner);
        emit(state.copyWith(
            status: GameStatus.gameFinished,
            ranking: finalRanking.reversed.toList(),
            winnerTeam: winner));
        _timerSubscription?.cancel();
      } else {
        _passTurnToNextAliveTeam(emit);
        emit(state.copyWith(status: GameStatus.playing));
        // ✅ شروع بلافاصله نوبت تیم بعدی بدون صفحه آماده‌باش
        _timerSubscription?.resume(); 
      }
    } else {
      int nextTeamIndex = state.currentTeamIndex + 1;
      int nextRound = state.currentRound;

      if (nextTeamIndex >= state.teams.length) {
        nextTeamIndex = 0;
        nextRound++;
      }

      if (nextRound > settings.roundsCount) {
        List<Team> finalRanking = List.from(state.teams);
        finalRanking.sort((a, b) => b.score.compareTo(a.score));
        emit(state.copyWith(
            status: GameStatus.gameFinished,
            ranking: finalRanking,
            winnerTeam: finalRanking.first));
        _timerSubscription?.cancel();
      } else {
        emit(state.copyWith(
            status: GameStatus.playing,
            currentTeamIndex: nextTeamIndex,
            currentRound: nextRound,
            roundRemainingTime: settings.turnDuration));
        // ✅ شروع بلافاصله نوبت
        _timerSubscription?.resume();
      }
    }
  }

  void _onUserAction(UserAction event, Emitter<GameState> emit) {
    if (state.status != GameStatus.playing) return;
    List<Team> updatedTeams = List.from(state.teams);
    Team currentTeam = updatedTeams[state.currentTeamIndex];

    if (settings.mode == GameMode.rounds) {
      int scoreChange = 0;
      if (event.actionType == GameActionType.correct) scoreChange = 1;
      if (event.actionType == GameActionType.foul) scoreChange = -1;
      updatedTeams[state.currentTeamIndex] =
          currentTeam.copyWith(score: currentTeam.score + scoreChange);
    } else {
      if (event.actionType == GameActionType.foul) {
        int penalty = max(0, currentTeam.remainingTime - 10);
        updatedTeams[state.currentTeamIndex] =
            currentTeam.copyWith(remainingTime: penalty);
      } else if (event.actionType == GameActionType.pass) {
        int penalty = max(0, currentTeam.remainingTime - 5);
        updatedTeams[state.currentTeamIndex] =
            currentTeam.copyWith(remainingTime: penalty);
      }
      if (event.actionType == GameActionType.correct) {
        updatedTeams[state.currentTeamIndex] =
            currentTeam.copyWith(score: currentTeam.score + 1);
      }
    }

    emit(state.copyWith(teams: updatedTeams));

    if (settings.mode == GameMode.survival &&
        event.actionType == GameActionType.correct) {
      _nextWord(emit);
      _passTurnToNextAliveTeam(emit);
    } else {
      _nextWord(emit);
    }
  }

  void _passTurnToNextAliveTeam(Emitter<GameState> emit) {
    int nextIndex = state.currentTeamIndex;
    int loopSafety = 0;
    do {
      nextIndex = (nextIndex + 1) % state.teams.length;
      loopSafety++;
    } while (state.teams[nextIndex].isEliminated &&
        loopSafety < state.teams.length * 2);
    emit(state.copyWith(currentTeamIndex: nextIndex));
  }

  void _nextWord(Emitter<GameState> emit) {
    if (_roundWordsPool.isEmpty) _roundWordsPool = List.from(_allWords);
    int index = _random.nextInt(_roundWordsPool.length);
    emit(state.copyWith(currentWord: _roundWordsPool.removeAt(index)));
  }

  void _startTicker() {
    _timerSubscription?.cancel();
    _timerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x)
        .listen((_) => add(TickTimer()));
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}
