part of 'game_bloc.dart';

// ✅ این همون خطی هست که جا مونده بود و ارور می‌داد!
enum GameActionType { correct, foul, pass }

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class StartGame extends GameEvent {}

class TickTimer extends GameEvent {}

class UserAction extends GameEvent {
  final GameActionType actionType;
  const UserAction(this.actionType);

  @override
  List<Object> get props => [actionType];
}

class DismissElimination extends GameEvent {}

// ✅ اضافه شده برای کنترل دستی زمان با دکمه آماده‌باش
class ResumeTurn extends GameEvent {
  const ResumeTurn();
  @override
  List<Object> get props => [];
}
