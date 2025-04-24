import 'package:flutter_bloc/flutter_bloc.dart';
import 'music_event.dart';
import 'music_state.dart';
import '../../core/services/music_service.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final MusicService musicService;

  MusicBloc(this.musicService) : super(MusicInitial()) {
    on<LoadMusicEvent>(_onLoadMusic);
    on<RefreshRecentlyPlayedEvent>(_onRefreshRecentlyPlayed); // ✅ NEW
  }

  Future<void> _onLoadMusic(LoadMusicEvent event, Emitter<MusicState> emit) async {
    emit(MusicLoading());
    try {
      final songs = await musicService.fetchSongs(forceRefresh: event.forceRefresh);
      final albums = await musicService.fetchAlbums(forceRefresh: event.forceRefresh);
      final artists = await musicService.fetchArtists(forceRefresh: event.forceRefresh);
      final recentlyPlayed = await musicService.getRecentlyPlayedSongs();

      emit(MusicLoaded(
        songs: songs,
        albums: albums,
        artists: artists,
        recentlyPlayed: recentlyPlayed,
        refreshed: event.forceRefresh,
      ));
    } catch (e) {
      emit(MusicError('Failed to load music: $e'));
    }
  }

  Future<void> _onRefreshRecentlyPlayed(
    RefreshRecentlyPlayedEvent event,
    Emitter<MusicState> emit,
  ) async {
    if (state is MusicLoaded) {
      final current = state as MusicLoaded;
      final updatedRecent = await musicService.getRecentlyPlayedSongs();

      emit(MusicLoaded(
        songs: current.songs,
        albums: current.albums,
        artists: current.artists,
        recentlyPlayed: updatedRecent,
        refreshed: false,
      ));
    }
  }
}
