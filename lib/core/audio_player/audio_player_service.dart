// 📁 core/audio_player/audio_player_service.dart (ensure durationStream is available)

import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> play(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: \$e');
    }
  }

  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> stop() async => await _audioPlayer.stop();
  Future<void> seek(Duration position) async => await _audioPlayer.seek(position);
  Future<void> next() async => await _audioPlayer.seekToNext();
  Future<void> previous() async => await _audioPlayer.seekToPrevious();
  Future<void> toggleShuffle(bool enable) async => await _audioPlayer.setShuffleModeEnabled(enable);

  bool get isPlaying => _audioPlayer.playing;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Duration? get duration => _audioPlayer.duration;
  bool get isShuffling => _audioPlayer.shuffleModeEnabled;
}

class AudioPlayerManager {
  static final AudioPlayerService _instance = AudioPlayerService();
  static AudioPlayerService get instance => _instance;
  AudioPlayerService get player => _instance;
}
