import 'package:flutter_bloc/flutter_bloc.dart';
import 'player_event.dart';
import 'player_state.dart';
import '../../core/audio_player/audio_player_manager.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final _player = AudioPlayerManager().player;

PlayerBloc() : super(PlayerInitial()) {
  on<PlaySong>(_onPlay);
  on<PauseSong>(_onPause);
  on<StopSong>(_onStop);
  on<SeekSong>(_onSeek);
  on<PlayNext>(_onNext);       // ✅ Add this
  on<PlayPrevious>(_onPrevious); // ✅ Add this
}

Future<void> _onNext(PlayNext event, Emitter<PlayerState> emit) async {
  try {
    await _player.next();
    emit(PlayerPlaying(songPath: _player.currentPath));
  } catch (e) {
    emit(PlayerError('Failed to skip to next: $e'));
  }
}

Future<void> _onPrevious(PlayPrevious event, Emitter<PlayerState> emit) async {
  try {
    await _player.previous();
    emit(PlayerPlaying(songPath: _player.currentPath));
  } catch (e) {
    emit(PlayerError('Failed to go to previous: $e'));
  }
}


Future<void> _onPlay(PlaySong event, Emitter<PlayerState> emit) async {
  try {
    if (_player.currentPath != event.path) {
      // New song
      await _player.play(event.path);
      emit(PlayerPlaying(songPath: event.path));
    } else {
      // Same song – resume if paused
      await _player.resume();

      // 🔁 Always emit new PlayerPlaying to trigger UI update
      emit(PlayerInitial());
      emit(PlayerPlaying(songPath: event.path));
    }
  } catch (e) {
    emit(PlayerError('Failed to play song: $e'));
  }
}


Future<void> _onPause(PauseSong event, Emitter<PlayerState> emit) async {
  await _player.pause();
  emit(PlayerPaused(songPath: _player.currentPath));
}


  Future<void> _onStop(StopSong event, Emitter<PlayerState> emit) async {
    await _player.stop();
    emit(PlayerStopped());
  }

  Future<void> _onSeek(SeekSong event, Emitter<PlayerState> emit) async {
    await _player.seek(event.position);
  }
}
