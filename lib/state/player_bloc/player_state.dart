import 'package:equatable/equatable.dart';

abstract class PlayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final String? songPath;

  PlayerPlaying({this.songPath});

  @override
  List<Object?> get props => [songPath];
}

class PlayerPaused extends PlayerState {}

class PlayerStopped extends PlayerState {}

class PlayerError extends PlayerState {
  final String message;

  PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
