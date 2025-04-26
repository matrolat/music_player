import 'package:just_audio/just_audio.dart' as audio;
import '../models/song_model.dart';

class AudioPlayerService {
  final audio.AudioPlayer _audioPlayer = audio.AudioPlayer();

  List<SongModel> _queue = [];
  SongModel? _currentSong;

  void Function(SongModel)? onSongChanged;
  void Function()? onSongEnded; // New callback

 AudioPlayerService() {
  _audioPlayer.playerStateStream.listen((audio.PlayerState state) async {
    if (state.processingState == audio.ProcessingState.completed) {
      // Instead of firing immediately, wait until song is actually completed and paused
      await Future.delayed(const Duration(milliseconds: 200)); // optional small delay
      if (onSongEnded != null) {
        onSongEnded!(); // ✅ This will now be stable
      }
    }
  });
}

  Future<void> setQueue(List<SongModel> songs) async {
    _queue = List.from(songs);
  }

  Future<void> playSong(SongModel song) async {
    try {
    //      if (_audioPlayer.playing || _audioPlayer.processingState == audio.ProcessingState.buffering) {
      await _audioPlayer.stop();
    // }
      _currentSong = song;
      await _audioPlayer.setFilePath(song.path);
      await _audioPlayer.play();
      onSongChanged?.call(song);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> resume() async => await _audioPlayer.play();
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> stop() async => await _audioPlayer.stop();
  Future<void> seek(Duration position) async => await _audioPlayer.seek(position);

  bool get isPlaying => _audioPlayer.playing;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<audio.PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Duration? get duration => _audioPlayer.duration;

  List<SongModel> get queue => _queue;
  SongModel? get currentSong => _currentSong;

  bool areSongsSame(SongModel a, SongModel b) {
    return a.id == b.id && a.title == b.title && a.artist == b.artist && a.path == b.path;
  }
}
