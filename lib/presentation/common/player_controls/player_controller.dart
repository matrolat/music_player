import 'package:music_player/core/audio_player/audio_player_manager.dart';
import 'package:just_audio/just_audio.dart';

class PlayerController {
  final _audioService = AudioPlayerManager().player; // AudioPlayerService
  AudioPlayer get _player => _audioService.audioPlayer;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Duration get currentPosition => _player.position;
  Duration get totalDuration => _player.duration ?? Duration.zero;

  bool get isPlaying => _player.playing;

  Future<void> seekTo(Duration position) => _player.seek(position);
}
