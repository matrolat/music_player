
import 'package:just_audio/just_audio.dart' as audio;
import '../models/song_model.dart';

class AudioPlayerService {
  final audio.AudioPlayer audioPlayer = audio.AudioPlayer();

  String? _currentPath;
  List<SongModel> _queue = [];
  int _currentIndex = 0;
  bool _isManualSkip = false;

  // 🔥 New: Callback when song changes
  void Function(SongModel)? onSongChanged;

  AudioPlayerService() {
    _listenForCompletion();
  }

  void _listenForCompletion() {
    audioPlayer.playerStateStream.listen((audio.PlayerState state) async {
      if (state.processingState == audio.ProcessingState.completed) {
        if (_isManualSkip) {
          _isManualSkip = false;
        } else {
          if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
            _currentIndex++;
            await playCurrent();
            final song = currentSong;
            if (song != null) {
              onSongChanged?.call(song);
            }
          }
        }
      }
    });
  }

 void setQueue(List<SongModel> songs, {int startIndex = 0}) {
  _queue = List.from(songs); // Copy new queue
  _currentIndex = startIndex.clamp(0, _queue.length - 1);
  _currentPath = _queue[_currentIndex].path;
}


Future<void> playCurrent() async {
  if (_queue.isEmpty) return;

  final currentSong = _queue[_currentIndex];

  // 🔥 Always set the file path again, because queue changed!
  await audioPlayer.setFilePath(currentSong.path);
  _currentPath = currentSong.path;

  await audioPlayer.play();
}


  Future<void> play(String path) async {
    try {
      if (_currentPath != path) {
        await audioPlayer.setFilePath(path);
        _currentPath = path;
      }
      await audioPlayer.play();
    } catch (e) {
      print('Error playing audio: \$e');
    }
  }

  Future<void> resume() async => await audioPlayer.play();
  Future<void> pause() async => await audioPlayer.pause();
  Future<void> stop() async => await audioPlayer.stop();
  Future<void> seek(Duration position) async => await audioPlayer.seek(position);

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      _isManualSkip = true;
      await playCurrent();
      final song = currentSong;
      if (song != null) {
        onSongChanged?.call(song);
      }
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      _isManualSkip = true;
      await playCurrent();
      final song = currentSong;
      if (song != null) {
        onSongChanged?.call(song);
      }
    }
  }

  bool get isPlaying => audioPlayer.playing;
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<audio.PlayerState> get playerStateStream => audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;
  Duration? get duration => audioPlayer.duration;
  bool get isShuffling => audioPlayer.shuffleModeEnabled;
  String? get currentPath => _currentPath;
  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong => (_queue.isNotEmpty && _currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;
}