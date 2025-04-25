import 'package:flutter_bloc/flutter_bloc.dart';
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


Future<void> _onPlay(PlaySong event, Emitter<PlayerState> emit) async {
  final song = event.song;

      emit(PlayerPlaying(song: song)); // ✅ Emit BEFORE playing
  try {
    if (_player.currentPath != song.path) {
      await _player.play(song.path);
    } else {
      await _player.resume();
      // emit(PlayerPlaying(song: song)); // ✅ Even for resume, emit after
    }
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
  } else if (state is PlayerPaused) {
    emit(PlayerPaused(song: (state as PlayerPaused).song));
  } else {
    emit(PlayerPaused(song: SongModel(
      id: 'unknown',
      title: 'Unknown',
      artist: 'Unknown',
      path: _player.currentPath ?? '',
    )));
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
    await _player.next();
    emit(PlayerPlaying(song: SongModel(
      id: 'next',
      title: 'Next Song',
      artist: 'Unknown',
      path: _player.currentPath!,
    )));
  }

  Future<void> _onPrevious(PlayPrevious event, Emitter<PlayerState> emit) async {
    await _player.previous();
    emit(PlayerPlaying(song: SongModel(
      id: 'prev',
      title: 'Previous Song',
      artist: 'Unknown',
      path: _player.currentPath!,
    )));
  }
}
