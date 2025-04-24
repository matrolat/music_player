import 'package:equatable/equatable.dart';
import '../../core/models/song_model.dart';

abstract class PlayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final SongModel song;

  PlayerPlaying({required this.song});

  @override
  List<Object?> get props => [song];
}

class PlayerPaused extends PlayerState {
  final SongModel song;

  PlayerPaused({required this.song});

  @override
  List<Object?> get props => [song];
}

class PlayerStopped extends PlayerState {}

class PlayerError extends PlayerState {
  final String message;

  PlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
