import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? _currentPath; // ✅ Track current song

  Future<void> play(String path) async {
    try {
      if (_currentPath != path) {
        await audioPlayer.setFilePath(path);
        _currentPath = path;
      }
      await audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
  Future<void> resume() async {
  await audioPlayer.play(); // play without setting new path
}


  Future<void> pause() async => await audioPlayer.pause();
  Future<void> stop() async => await audioPlayer.stop();
  Future<void> seek(Duration position) async => await audioPlayer.seek(position);
  Future<void> next() async => await audioPlayer.seekToNext();
  Future<void> previous() async => await audioPlayer.seekToPrevious();
  Future<void> toggleShuffle(bool enable) async => await audioPlayer.setShuffleModeEnabled(enable);

  bool get isPlaying => audioPlayer.playing;
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<PlayerState> get playerStateStream => audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;
  Duration? get duration => audioPlayer.duration;
  bool get isShuffling => audioPlayer.shuffleModeEnabled;

  // ✅ Add this getter to expose current song path
  String? get currentPath => _currentPath;
}
