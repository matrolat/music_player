import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPath; // ✅ Track current song

  Future<void> play(String path) async {
    try {
      if (_currentPath != path) {
        await _audioPlayer.setFilePath(path);
        _currentPath = path;
      }
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
  Future<void> resume() async {
  await _audioPlayer.play(); // play without setting new path
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

  // ✅ Add this getter to expose current song path
  String? get currentPath => _currentPath;
}
