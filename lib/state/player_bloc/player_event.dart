import 'package:equatable/equatable.dart';
import '../../core/models/song_model.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlaySong extends PlayerEvent {
  final SongModel song;
  final List<SongModel>? queue;
  final int? startIndex;

  const PlaySong(this.song, {this.queue, this.startIndex});

  @override
  List<Object?> get props => [song, queue, startIndex];
}

class PauseSong extends PlayerEvent {}

class StopSong extends PlayerEvent {}

class SeekSong extends PlayerEvent {
  final Duration position;

  const SeekSong(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayNext extends PlayerEvent {}

class PlayPrevious extends PlayerEvent {}

class ToggleShuffle extends PlayerEvent {}
