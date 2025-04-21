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
  }

  Future<void> _onPlay(PlaySong event, Emitter<PlayerState> emit) async {
    try {
      await _player.play(event.path);
      emit(PlayerPlaying());
    } catch (e) {
      emit(PlayerError('Failed to play song: $e'));
    }
  }

  Future<void> _onPause(PauseSong event, Emitter<PlayerState> emit) async {
    await _player.pause();
    emit(PlayerPaused());
  }

  Future<void> _onStop(StopSong event, Emitter<PlayerState> emit) async {
    await _player.stop();
    emit(PlayerStopped());
  }

  Future<void> _onSeek(SeekSong event, Emitter<PlayerState> emit) async {
    await _player.seek(event.position);
  }
}
