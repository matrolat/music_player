import 'audio_player_service.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  late AudioPlayerService _audioPlayerService;

  factory AudioPlayerManager() {
    return _instance;
  }

  AudioPlayerManager._internal() {
    _audioPlayerService = AudioPlayerService();
  }

  AudioPlayerService get player => _audioPlayerService;
}
