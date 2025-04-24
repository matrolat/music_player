import 'package:equatable/equatable.dart';
import '../../core/models/song_model.dart';

abstract class PlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlaySong extends PlayerEvent {
  final SongModel song;

  PlaySong(this.song);

  @override
  List<Object?> get props => [song];
}

class PauseSong extends PlayerEvent {}

class StopSong extends PlayerEvent {}

class SeekSong extends PlayerEvent {
  final Duration position;

  SeekSong(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayNext extends PlayerEvent {}

class PlayPrevious extends PlayerEvent {}

class ToggleShuffle extends PlayerEvent {}
