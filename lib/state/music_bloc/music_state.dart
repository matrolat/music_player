import 'package:equatable/equatable.dart';
import '../../core/models/song_model.dart';
import '../../core/models/album_model.dart';
import '../../core/models/artist_model.dart';

abstract class MusicState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MusicInitial extends MusicState {}

class MusicLoading extends MusicState {}

class MusicLoaded extends MusicState {
  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;
  final List<SongModel> recentlyPlayed;
  final bool refreshed;

  MusicLoaded({
    required this.songs,
    required this.albums,
    required this.artists,
    required this.recentlyPlayed,
    this.refreshed = false,
  });

  @override
  List<Object?> get props => [songs, albums, artists, recentlyPlayed, refreshed];
}

class MusicError extends MusicState {
  final String message;

  MusicError(this.message);

  @override
  List<Object?> get props => [message];
}
