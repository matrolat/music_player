import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/audio_player/audio_player_service.dart';
import 'package:music_player/core/services/music_service.dart';
import 'package:music_player/state/music_bloc/music_bloc.dart';
import 'package:music_player/state/music_bloc/music_event.dart';
import 'player_event.dart';
import 'player_state.dart';
import '../../core/audio_player/audio_player_manager.dart';
import '../../core/models/song_model.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final _player = AudioPlayerManager().player;
  final MusicService musicService;
  final MusicBloc musicBloc;

  PlayerBloc(this.musicService, this.musicBloc) : super(PlayerInitial()) {
    on<PlaySong>(_onPlay);
    on<PauseSong>(_onPause);
    on<StopSong>(_onStop);
    on<SeekSong>(_onSeek);
    on<PlayNext>(_onNext);
    on<PlayPrevious>(_onPrevious);
  }

  AudioPlayerService get player => _player;

  bool areSongsSame(SongModel a, SongModel b) {
    return a.id == b.id && a.title == b.title && a.artist == b.artist && a.path == b.path;
  }

  Future<void> _onPlay(PlaySong event, Emitter<PlayerState> emit) async {
    final song = event.song;
    emit(PlayerPlaying(song: song));

    try {
      if (event.queue != null) {
        await _player.setQueue(event.queue!);
      }
      await _player.playSong(song);

      musicService.recordPlayed(song);
      musicBloc.add(RefreshRecentlyPlayedEvent());
    } catch (e) {
      emit(PlayerError('Failed to play song: $e'));
    }
  }

  Future<void> _onPause(PauseSong event, Emitter<PlayerState> emit) async {
    await _player.pause();
    if (state is PlayerPlaying) {
      emit(PlayerPaused(song: (state as PlayerPlaying).song));
    }
  }

  Future<void> _onStop(StopSong event, Emitter<PlayerState> emit) async {
    await _player.stop();
    emit(PlayerStopped());
  }

  Future<void> _onSeek(SeekSong event, Emitter<PlayerState> emit) async {
    await _player.seek(event.position);
  }

  Future<void> _onNext(PlayNext event, Emitter<PlayerState> emit) async {
    final queue = _player.queue;
    final current = _player.currentSong;

    if (queue.isEmpty || current == null) return;

    final currentIndex = queue.indexWhere((s) => areSongsSame(s, current));
    if (currentIndex != -1 && currentIndex < queue.length - 1) {
      final nextSong = queue[currentIndex + 1];
      add(PlaySong(nextSong));
    }
  }

  Future<void> _onPrevious(PlayPrevious event, Emitter<PlayerState> emit) async {
    final queue = _player.queue;
    final current = _player.currentSong;

    if (queue.isEmpty || current == null) return;

    final currentIndex = queue.indexWhere((s) => areSongsSame(s, current));
    if (currentIndex > 0) {
      final previousSong = queue[currentIndex - 1];
      add(PlaySong(previousSong));
    }
  }
}
