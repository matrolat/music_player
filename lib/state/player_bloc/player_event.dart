import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Play a specific song (by path)
class PlaySong extends PlayerEvent {
  final String path;

  PlaySong(this.path);

  @override
  List<Object?> get props => [path];
}

/// Pause the current song
class PauseSong extends PlayerEvent {}

/// Stop the player
class StopSong extends PlayerEvent {}

/// Seek to a specific duration
class SeekSong extends PlayerEvent {
  final Duration position;

  SeekSong(this.position);

  @override
  List<Object?> get props => [position];
}

/// Go to next song in the playlist
class PlayNext extends PlayerEvent {}

/// Go to previous song in the playlist
class PlayPrevious extends PlayerEvent {}

/// Toggle shuffle mode
class ToggleShuffle extends PlayerEvent {}
